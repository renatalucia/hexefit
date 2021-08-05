//
//  WorkoutPlanViewController.swift
//  hexefit
//
//  Created by Renata Rego on 27/07/2021.
//

import UIKit
import CoreData

class WorkoutPlanViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    var workoutPlan: WorkoutPlan?
    var workout: Workout?
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
    
    var workoutSets: [SetWorkout]?
    var exercises: [[Exercise]]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSetsAndExercises()
        tableView.register(UINib(nibName: "WorkoutPlanTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseReusableCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        setEditMode(isEdit: false)
        
        workoutName.text = workout?.name
        workoutDescription.text = workout?.desc
        
        let changePlanTitleTap = UITapGestureRecognizer(target: self, action: #selector(changePlanTapFunction))
        workoutName.isUserInteractionEnabled = true
        workoutDescription.isUserInteractionEnabled = true
        workoutName.addGestureRecognizer(changePlanTitleTap)
        workoutDescription.addGestureRecognizer(changePlanTitleTap)

    }
    
    func loadSetsAndExercises(){
        workoutSets = workout?.hasSets?.allObjects as? [SetWorkout]
        exercises = []
        if let safeWorkoutSets = workoutSets{
            for wSet in safeWorkoutSets{
                if let setExercises = wSet.hasExercises?.allObjects as? [Exercise]{
                exercises?.append(setExercises)
                }
            }
        }
    }
    
    func addExerciseToSet(exercise: Exercise, wSet: SetWorkout){
        exercise.belongsToSet = wSet
        saveCDContext()
    }
    func deleteExerciseFromSet(exercise: Exercise, wSet: SetWorkout){
        exercise.belongsToSet = nil
        saveCDContext()
    }
    
    func deleteExercise(at indexPath: IndexPath){
        if let deleteObject = exercises?[indexPath.section][indexPath.row]{
            context.delete(deleteObject)
            saveCDContext()
            loadSetsAndExercises()
            tableView.reloadData()
        }
    }
    
    func saveCDContext() {
        do{
            try
                self.context.save()
        } catch {
                print("Error saving to core data")
        }
    }

    
    @IBAction func editButtonClicked(_ sender: UIBarButtonItem) {
        isEdit.toggle()
        setEditMode(isEdit: isEdit)
        print(isEdit)
        
    }
    
    @IBAction func addSetClicked(_ sender: UIButton) {
        let newSet = SetWorkout(context: context)
        newSet.belongsToWorkout = workout
        saveCDContext()
        loadSetsAndExercises()
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
               let exerciseName = self.exercises?[path.section][path.row].name {
                textField.text = exerciseName
            }
            
        }
        
        alert.addTextField { (textField) in
            let placeholderText = "Exercise details. Ex. 3x 10-12 5kg"
            textField.placeholder = placeholderText
            if let path = indexPath,
               let exerciseDetails = self.exercises?[path.section][path.row].details {
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
                    self.exercises?[path.section][path.row].name = exerciseName
                    self.exercises?[path.section][path.row].details = exerciseDetails
                } else if let button = sectionButton {
                    let newExercise = Exercise(context: self.context)
                    newExercise.name = exerciseName
                    newExercise.details = exerciseDetails
                    newExercise.belongsToSet = self.workoutSets?[button.tag]
                }
                self.saveCDContext()
                self.loadSetsAndExercises()
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
            textField.text = self.workout?.name
            
        }
        
        alert.addTextField { (textField) in
            let placeholderText = "Write here a description for your plan"
            textField.placeholder = placeholderText
            textField.text = self.workout?.desc
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { action in
            
            if let textFieldName = alert.textFields?[0],
               let planName = textFieldName.text,
               let textFieldDescription = alert.textFields?[1],
               let planDescription = textFieldDescription.text{
                
                // Update DataBase
                self.workout?.name = planName
                self.workout?.desc = planDescription
                self.saveCDContext()
                
                // Update UI
                self.workoutName.text = self.workout?.name
                self.workoutDescription.text = self.workout?.desc
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    

    
    
}


// MARK: - TableView Data Source Methods.

extension WorkoutPlanViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.workoutSets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exercises?[section].count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = (section < romans.count) ? romans[section] : String(section+1)
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseReusableCell") as! WorkoutPlanTableViewCell
        
        cell.exerciseName.text = self.exercises?[indexPath.section][indexPath.row].name
        
        cell.exerciseData.text = self.exercises?[indexPath.section][indexPath.row].details
        
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
        if let movedObject =  self.exercises?[sourceIndexPath.section][sourceIndexPath.row],
           let targetSet = self.workoutSets?[sourceIndexPath.section]{
            
            self.addExerciseToSet(exercise: movedObject, wSet: targetSet)
        }
        self.loadSetsAndExercises()
        tableView.reloadData()
    }
    
    
    
    
    
}
