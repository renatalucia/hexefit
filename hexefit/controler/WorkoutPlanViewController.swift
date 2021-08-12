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
        tableView.rowHeight = 70
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
        workoutSets?.sort{ $0.order < $1.order}
        exercises = []
        if let safeWorkoutSets = workoutSets{
            for wSet in safeWorkoutSets{
                if var setExercises = wSet.hasExercises?.allObjects as? [Exercise]{
                    setExercises.sort { $0.order < $1.order }
                exercises?.append(setExercises)
                }
            }
        }
    }
    

    func deleteExerciseFromSet(exercise: Exercise, wSet: SetWorkout){
        let currentSet = exercise.belongsToSet
        exercise.belongsToSet = nil
        if let cSet = currentSet, let setExercises = currentSet?.hasExercises {
            if setExercises.count == 0{
                context.delete(cSet)
            }
        }
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
        if let order = workoutSets?.count{
            newSet.order = Int16(order)
        }
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
        // loadSetsAndExercises()
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
                    newExercise.order = Int16(self.exercises?[button.tag].count ?? 1)
                        newExercise.belongsToSet =  self.workoutSets?[button.tag]
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
    
    
 //    Method called to configure the header of the sections
    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int){
//    func tableView(_ tableView: UITableView,
//                   viewForHeaderInSection section: Int) -> UIView?{
        

        var buttonAddExercise: UIButton? = nil
        var buttonRemoveSet: UIButton? = nil
        if view.subviews.count > 0{
            for subview in view.subviews{
                if let btn = subview as? UIButton{
                    btn.isHidden = !isEdit
                    if btn.tag == 1{
                        buttonAddExercise = btn
                    }
                    if btn.tag == 2{
                        buttonRemoveSet = btn
                    }
                }
            }
        }
        if isEdit {
            if buttonAddExercise == nil{
                let buttonAddExercise = UIButton(type: .system)
                buttonAddExercise.tag = 1
                buttonAddExercise.setTitle("add exercise", for: .normal)
                buttonAddExercise.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                buttonAddExercise.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center // There is no left
                buttonAddExercise.setTitleColor(.systemBlue, for: .normal)
                buttonAddExercise.tag = section
                buttonAddExercise.addTarget(self, action: #selector(addExerciseToSection), for: .touchUpInside)
                buttonAddExercise.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(buttonAddExercise)
                let margins = view.layoutMarginsGuide
                buttonAddExercise.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 10).isActive = true
            }
            if buttonRemoveSet == nil{
                let buttonRemoveSet = UIButton(type: .system)
                buttonRemoveSet.tag = 1
                buttonRemoveSet.setTitle("-", for: .normal)
                buttonRemoveSet.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                buttonRemoveSet.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center // There is no left
                buttonRemoveSet.setTitleColor(.systemBlue, for: .normal)
                buttonRemoveSet.tag = section
                buttonRemoveSet.addTarget(self, action: #selector(addExerciseToSection), for: .touchUpInside)
                buttonRemoveSet.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(buttonRemoveSet)
                let margins = view.layoutMarginsGuide
                buttonRemoveSet.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
            }
        }
    }
    
    // Asks the delegate whether the background of the specified row should be indented while the table view is in editing mode.
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Method called when exercise is moved in the table
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let movedObject =  self.exercises?[sourceIndexPath.section][sourceIndexPath.row],
           let targetSet = self.workoutSets?[destinationIndexPath.section]{
            
            // move the object to get new indexes
            exercises?[sourceIndexPath.section].remove(at: sourceIndexPath.row)
            exercises?[destinationIndexPath.section].insert(movedObject, at: destinationIndexPath.row)
            
            // update attribute order based on new indexes
            if exercises![sourceIndexPath.section].count > 0{
                for i in 0...exercises![sourceIndexPath.section].count-1{
                    exercises![sourceIndexPath.section][i].order = Int16(i)
                }
            }
            if exercises![destinationIndexPath.section].count > 0{
                for i in 0...exercises![destinationIndexPath.section].count-1{
                    exercises![destinationIndexPath.section][i].order = Int16(i)
                }
            }
            
            // Update DataBase
            movedObject.belongsToSet = targetSet
            
            if let wset = workoutSets?[sourceIndexPath.section]{
                if wset.hasExercises?.count == 0{
                    context.delete(wset)
                }
            }
            
            saveCDContext()
        }
        self.loadSetsAndExercises()
        tableView.reloadData()
    }
    
    
    
    
    
}
