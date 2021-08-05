//
//  PlansViewController.swift
//  hexefit
//
//  Created by Renata Rego on 27/07/2021.
//

import UIKit
import CoreData

class PlansViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var addPlanButton: UIButton!
    
    var isEdit = false
    
    var selectedWorkoutPlan: Workout?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    
    var workouts : [Workout] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        
        tableView.register(UINib(nibName: "PlanCell", bundle: nil), forCellReuseIdentifier: "PlanReusableCell")
        
        loadWorkouts()

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toWorkouPlan" {
            if let destinationVC = segue.destination as? WorkoutPlanViewController {
                destinationVC.workout =  selectedWorkoutPlan
            }
        }
    }
    
    func loadWorkouts(){
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        do{
            try workouts = context.fetch(request)
        } catch {
            print("Error Loading Data")
        }
        tableView.reloadData()
    }
    
    func saveCDContext() {
        do{
            try
                self.context.save()
        } catch {
                print("Error saving to core data")
        }
    }
    
    func deleteWorkout(at indexPath: IndexPath){
        print("deleteWorkout")
        let w = self.workouts[indexPath.row]
        context.delete(w)
        loadWorkouts()
    }
    
    func setEditMode(isEdit: Bool){
        self.tableView.isEditing = isEdit
        addPlanButton.isHidden = !isEdit
        if isEdit {
            editButton.title = "Done"
        } else {
            editButton.title = "Edit"
        }
        tableView.reloadData()
    }
    
    func enterPlanData(at indexPath: IndexPath?=nil, alertTitle: String) {
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Write here the title of your plan"
            if let path = indexPath{
                textField.text = self.workouts[path.row].name
            }
            
        }
        
        alert.addTextField { (textField) in
            let placeholderText = "Write here a short description for your plan"
            textField.placeholder = placeholderText
            if let path = indexPath{
                textField.text =  self.workouts[path.row].description
            }
            
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { action in
            // What will happen when user presses "Add Plan"
            
            if let textFieldName = alert.textFields?[0],
               let planName = textFieldName.text,
               let textFieldDescription = alert.textFields?[1],
               let planDescription = textFieldDescription.text{
               
                
                if let path = indexPath{
                    self.workouts[path.row].name = planName
                    self.workouts[path.row].desc = planDescription
                } else {
                    let newWorkout = Workout(context: self.context)
                    newWorkout.name = planName
                    newWorkout.desc = planDescription
                }
                self.saveCDContext()
                self.loadWorkouts()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func addPlanButtonClicked(_ sender: UIButton) {
        enterPlanData(alertTitle: "Add Workout Plan")
    }
    
    
    @IBAction func editButtonClicked(_ sender: UIBarButtonItem) {
        isEdit.toggle()
        setEditMode(isEdit: isEdit)
    }
}

extension PlansViewController: UITableViewDelegate{
    
    // Method called when table view cell is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        selectedWorkoutPlan = workouts[indexPath.row] as Workout
        performSegue(withIdentifier: "toWorkouPlan", sender: self)

    }
    
    // Method called when delete button is pressed
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteWorkout(at: indexPath)
        }
    }
}

extension PlansViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanReusableCell", for: indexPath) as! PlanCell
        cell.planName.text = workouts[indexPath.row].name
        cell.planDescription.text = workouts[indexPath.row].desc
        return cell
    }
    
}
