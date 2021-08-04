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
    
//    var workoutPlans = [
//        WorkoutPlan(name: "Lower Body Workout", description: "Created at 29.07.2021", sets: nil),
//        WorkoutPlan(name: "Upper Body Workout", description: "Created at 27.07.2021", sets: nil)
//    ]
    
    var workoutPlans : [Workout] = []
    
    
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
    
    func enterPlanData(at indexPath: IndexPath?=nil, alertTitle: String) {
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Write here the title of your plan"
            if let path = indexPath{
                textField.text = self.workoutPlans[path.row].name
            }
            
        }
        
        alert.addTextField { (textField) in
            let placeholderText = "Write here a short description for your plan"
            textField.placeholder = placeholderText
            if let path = indexPath{
                textField.text =  self.workoutPlans[path.row].description
            }
            
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { action in
            // What will happen when user presses "Add Plan"
            
            if let textFieldName = alert.textFields?[0],
               let planName = textFieldName.text,
               let textFieldDescription = alert.textFields?[1],
               let planDescription = textFieldDescription.text{
               
                
                if let path = indexPath{
                    self.workoutPlans[path.row].name = planName
//                    self.workoutPlans[path.row].description = planDescription
                } else {
//                    let newPlan = WorkoutPlan(name: planName, description: planDescription, sets: [])
//                    self.workoutPlans.append(newPlan)
                    let newWorkout = Workout(context: self.context)
                    newWorkout.name = planName
                    newWorkout.desc = planDescription
                    do{
                        try
                            self.context.save()
                    } catch {
                            print("Error saving to core data")
                    }
                        
                }
                self.tableView.reloadData()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadWorkouts(){
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        do{
            try workoutPlans = context.fetch(request)
        } catch {
            print("Error Loading Data")
        }
        tableView.reloadData()
    }
    

    
    @IBAction func addPlanButtonClicked(_ sender: UIButton) {
        enterPlanData(alertTitle: "Add Workout Plan")
        loadWorkouts()
    }
    
    
    @IBAction func editButtonClicked(_ sender: UIBarButtonItem) {
        isEdit.toggle()
        setEditMode(isEdit: isEdit)
    }
        
    func setEditMode(isEdit: Bool){
        self.tableView.isEditing = isEdit
        tableView.allowsSelection = isEdit
        tableView.allowsSelectionDuringEditing = isEdit
        addPlanButton.isHidden = !isEdit
        if isEdit {
            editButton.title = "Done"
        } else {
            editButton.title = "Edit"
        }
        tableView.reloadData()
    }
}

extension PlansViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        selectedWorkoutPlan = workoutPlans[indexPath.row] as! Workout
        performSegue(withIdentifier: "toWorkouPlan", sender: self)

    }
    
    
}

extension PlansViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutPlans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanReusableCell", for: indexPath) as! PlanCell
        cell.planName.text = workoutPlans[indexPath.row].name
        cell.planDescription.text = workoutPlans[indexPath.row].desc
        return cell
    }
    
}
