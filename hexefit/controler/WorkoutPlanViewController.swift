//
//  WorkoutPlanViewController.swift
//  hexefit
//
//  Created by Renata Rego on 27/07/2021.
//

import UIKit

class WorkoutPlanViewController: UIViewController {
    
    var workoutPlan: WorkoutPlan?
    var isEdit = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var workoutName: UILabel!
    
    @IBOutlet weak var workoutDescription: UILabel!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var addSetButton: UIButton!
    
    let romans = ["I", "II", "III", "IV", "V",
                  "VI", "VII", "VIII", "IX", "X",
                  "XI", "XII", "XIII", "XIV", "XV",
                  "XVI", "XVII", "XVIII", "XIX", "XX"]
    
    let ws = [
        WorkoutSet(exercises: [
                    WorkoutExercise(name: "Agachamento", details: "3x 8-12"),
                    WorkoutExercise(name: "Agachamento isometrico", details: "3x 20 segundos")]),
        WorkoutSet(exercises: [
                    WorkoutExercise(name: "Agachamento com bola", details: "3x 8-12"),
                    WorkoutExercise(name: "Agachamento isometrico com bola", details: "3x 20 segundos")]),
        WorkoutSet(exercises: [
                    WorkoutExercise(name: "Pernada", details: "3x 8-12")])
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workoutPlan?.sets = ws
        tableView.register(UINib(nibName: "WorkoutPlanTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseReusableCell")
        print(workoutPlan?.name as Any)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        setEditMode(isEdit: false)
        
        workoutName.text = workoutPlan?.name
        workoutDescription.text = workoutPlan?.description
        
        let changePlanTitleTap = UITapGestureRecognizer(target: self, action: #selector(changePlanTapFunction))
        workoutName.isUserInteractionEnabled = true
        workoutDescription.isUserInteractionEnabled = true
        workoutName.addGestureRecognizer(changePlanTitleTap)
        workoutDescription.addGestureRecognizer(changePlanTitleTap)

    }
    
    @IBAction func editButtonClicked(_ sender: UIBarButtonItem) {
        isEdit.toggle()
        setEditMode(isEdit: isEdit)
        print(isEdit)
        
    }
    
    @IBAction func addSetClicked(_ sender: UIButton) {
        workoutPlan?.sets?.append(WorkoutSet(exercises: []))
        tableView.reloadData()
    }
    
    func setEditMode(isEdit: Bool){
        if isEdit {
            self.tableView.isEditing = true
            tableView.allowsSelection = true
            tableView.allowsSelectionDuringEditing = true
            addSetButton.isHidden = false
            editButton.title = "Done"
            
        } else {
            self.tableView.isEditing = false
            tableView.allowsSelection = false
            tableView.allowsSelectionDuringEditing = false
            addSetButton.isHidden = true
            editButton.title = "Edit"
        }
        tableView.reloadData()
    }
    
    @objc func changePlanTapFunction(sender:UITapGestureRecognizer) {
        enterWorkoutTitle()
    }
    
    
    // method called when the add exercise button inside the section header is pressed
    @objc func addExerciseToSection(button: UIButton) {
        addExercise(sectionButton: button)
    }
    
    
    func addExercise(sectionButton button: UIButton){
        enterExerciseData(sectionButton: button, alertTitle: "Add Exercise")
    }
    
    func editExercise(at indexPath: IndexPath){
        enterExerciseData(at: indexPath, alertTitle: "Edit Exercise")
    }
    
    // Method called when an exercise is being edited (need to Pass the indexPass parameter)
    // or inserted (need to Pass the Button parameter)
    // Shoud be called only inside methods addNewExercise and EditExercise
    func enterExerciseData(at indexPath: IndexPath? = nil, sectionButton: UIButton? = nil, alertTitle: String){
        
        let alert = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Write here your exercise name"
            if let path = indexPath,
               let exerciseName = self.workoutPlan?.sets?[path.section].exercises[path.row].name {
                textField.text = exerciseName
            }
            
        }
        
        alert.addTextField { (textField) in
            let placeholderText = "Exercise details. Ex. 3x 10-12 5kg"
            textField.placeholder = placeholderText
            if let path = indexPath,
               let exerciseDetails = self.workoutPlan?.sets?[path.section].exercises[path.row].details{
                textField.text =  exerciseDetails
            }
            
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { action in
            // What will happen when user presses "Add Item"
            
            if let textFieldName = alert.textFields?[0],
               let exerciseName = textFieldName.text,
               let textFieldDetails = alert.textFields?[1],
               let exerciseDetails = textFieldDetails.text{
               
                
                if let path = indexPath{
                    self.workoutPlan?.sets?[path.section].exercises[path.row].name = exerciseName
                    self.workoutPlan?.sets?[path.section].exercises[path.row].details = exerciseDetails
                } else if let button = sectionButton {
                    let w = WorkoutExercise(name: exerciseName, details: exerciseDetails)
                    self.workoutPlan?.sets?[button.tag].exercises.append(w)
                }
                self.tableView.reloadData()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func enterWorkoutTitle(){
        let alert = UIAlertController(title: "Edit Plan", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Write here the name of your plan"
            textField.text = self.workoutPlan?.name
            
        }
        
        alert.addTextField { (textField) in
            let placeholderText = "Write here a description for your plan"
            textField.placeholder = placeholderText
            textField.text = self.workoutPlan?.description
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { action in
            
            if let textFieldName = alert.textFields?[0],
               let planName = textFieldName.text,
               let textFieldDescription = alert.textFields?[1],
               let planDescription = textFieldDescription.text{
                self.workoutPlan?.name = planName
                self.workoutPlan?.description = planDescription
                self.workoutName.text = self.workoutPlan?.name
                self.workoutDescription.text = self.workoutPlan?.description
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func deleteExercise(at indexPath: IndexPath){
        self.workoutPlan?.sets?[indexPath.section].exercises.remove(at: indexPath.row)
        if self.workoutPlan?.sets?[indexPath.section].exercises.count == 0{
            self.workoutPlan?.sets?.remove(at: indexPath.section)
        }
    }
    
    
}


// MARK: - TableView Data Source Methods.

extension WorkoutPlanViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.workoutPlan?.sets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.workoutPlan?.sets?[section].exercises.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = (section < romans.count) ? romans[section] : String(section+1)
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseReusableCell") as! WorkoutPlanTableViewCell
        let exercixeName = self.workoutPlan?.sets?[indexPath.section].exercises[indexPath.row].name
        
        cell.exerciseName.text = exercixeName
        
        cell.exerciseData.text = self.workoutPlan?.sets?[indexPath.section].exercises[indexPath.row].details
        
        return cell
    }
    
}


// MARK: - TableView Delegate Methods.
extension WorkoutPlanViewController:  UITableViewDelegate {
    
    
    // Method called when delete button is pressed
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteExercise(at: indexPath)
            tableView.reloadData()
        }
    }
    
    // Method called when a row is selected
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)   {
        editExercise(at: indexPath)
        
    }
    
    
    // Method called to configure the header of the sections
    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int){
        
        
        if isEdit {
            let button = UIButton(type: .system)
            button.setTitle("add exercise", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center // There is no left
            button.setTitleColor(.systemBlue, for: .normal)
            button.tag = section
            button.addTarget(self, action: #selector(addExerciseToSection), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            let margins = view.layoutMarginsGuide
            button.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 10).isActive = true
            
            
        }
    }
    
    // Asks the delegate whether the background of the specified row should be indented while the table view is in editing mode.
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Method called when exercise is moved in the table
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let movedObject =  self.workoutPlan?.sets?[sourceIndexPath.section].exercises[sourceIndexPath.row]{
            
            self.workoutPlan?.sets?[destinationIndexPath.section].exercises.insert(movedObject, at: destinationIndexPath.row)
            
            deleteExercise(at: sourceIndexPath)
        }
        tableView.reloadData()
        
    }
    
    
    
}
