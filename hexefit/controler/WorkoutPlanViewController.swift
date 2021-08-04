//
//  WorkoutPlanViewController.swift
//  hexefit
//
//  Created by Renata Rego on 27/07/2021.
//

import UIKit

class WorkoutPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var workoutPlan: WorkoutPlan?
    var isEdit = false
    
    @IBOutlet weak var workoutName: UILabel!
    
    @IBOutlet weak var workoutDescription: UILabel!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var addSetButton: UIButton!
    
    let romans = ["I", "II", "III", "IV", "V",
                  "VI", "VII", "VIII", "IX", "X",
                  "XI", "XII", "XIII", "XIV", "XV",
                  "XVI", "XVII", "XVIII", "XIX", "XX"]
    


    let ws = [
        WorkoutSet(seqNumber: 1, exercises: [
                                    WorkoutExercise(name: "Agachamento", details: "3x 8-12"),
                                    WorkoutExercise(name: "Agachamento isometrico", details: "3x 20 segundos")]),
        WorkoutSet(seqNumber: 2, exercises: [
                                        WorkoutExercise(name: "Agachamento com bola", details: "3x 8-12"),
                                        WorkoutExercise(name: "Agachamento isometrico com bola", details: "3x 20 segundos")]),
        WorkoutSet(seqNumber: 3, exercises: [
                                    WorkoutExercise(name: "Pernada", details: "3x 8-12")])
    ]
    
    

//
//    var itemsInSections: Array<Array<String>> = [["Agachamento", "Agachamento isometrico com bola"], ["Agachamento isometrico com bola", "Agachamento com bola"], ["Pernada Alternada"]]
//    
//    var sections: Array<String> = ["I", "II", "III"]
    
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
    }
    
    @IBAction func editButtonClicked(_ sender: UIBarButtonItem) {
        isEdit.toggle()
        setEditMode(isEdit: isEdit)
        print(isEdit)

    }
    
    
    @IBAction func addSetButtonClicked(_ sender: UIButton) {
        workoutPlan?.sets?.append(WorkoutSet(seqNumber: 1, exercises: [WorkoutExercise(name: "New exercise", details: "3x 8-12")]))
        
        
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.workoutPlan?.sets?.count ?? 0
    }
    
    //    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    //        print("number of sections: \(sections.count)")
    //        return self.sections.count
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.workoutPlan?.sets?[section].exercises.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseReusableCell") as! WorkoutPlanTableViewCell
        let exercixeName = self.workoutPlan?.sets?[indexPath.section].exercises[indexPath.row].name
        
        cell.exerciseName.text = exercixeName
        
        cell.exerciseData.text = self.workoutPlan?.sets?[indexPath.section].exercises[indexPath.row].details
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   willDisplayHeaderView view: UIView,
                   forSection section: Int){
        
        
        if isEdit {
            let button = UIButton(type: .system)
            button.setTitle("+", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            button.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center // There is no left
            button.setTitleColor(.systemBlue, for: .normal)
            button.tag = section
            button.addTarget(self, action: #selector(addExerciseToSection), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(button)
//            let margins = view.layoutMarginsGuide
//            button.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 10).isActive = true
            
            let buttonRemove = UIButton(type: .system)
            buttonRemove.setTitle("-", for: .normal)
            buttonRemove.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            buttonRemove.setTitleColor(.systemBlue, for: .normal)
            buttonRemove.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center // There is
            buttonRemove.tag = section
            buttonRemove.addTarget(self, action: #selector(addExerciseToSection), for: .touchUpInside)
            buttonRemove.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(buttonRemove)
//            let marginsRemove = button.layoutMarginsGuide
//            buttonRemove.trailingAnchor.constraint(equalTo: marginsRemove.trailingAnchor, constant: 50).isActive = true
            
            let stackView   = UIStackView()
            stackView.axis  = NSLayoutConstraint.Axis.horizontal
            stackView.distribution  = UIStackView.Distribution.equalSpacing

            stackView.alignment = UIStackView.Alignment.top

            stackView.spacing   = 3.0

            stackView.addArrangedSubview(button)
            stackView.addArrangedSubview(buttonRemove)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            



            view.addSubview(stackView)
            
            stackView.alignment = .center
            
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            
            let margins = view.layoutMarginsGuide
            stackView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
            
        }
    }
    
    
    //    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    //        return .none
    //    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject =  self.workoutPlan?.sets?[sourceIndexPath.section].exercises[sourceIndexPath.row] ??
            WorkoutExercise(name: "Exercise name", details: "Number of series and repetitions")
        
        //let movedObject = self.itemsInSections[sourceIndexPath.section][sourceIndexPath.row]
        
        self.workoutPlan?.sets?[sourceIndexPath.section].exercises.remove(at: sourceIndexPath.row)
        self.workoutPlan?.sets?[destinationIndexPath.section].exercises.insert(movedObject, at: destinationIndexPath.row)
        
        print("After moving")
        print(workoutPlan?.sets!)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.workoutPlan?.sets?[indexPath.section].exercises.remove(at: indexPath.row)
            if self.workoutPlan?.sets?[indexPath.section].exercises.count == 0{
                self.workoutPlan?.sets?.remove(at: indexPath.section)
  
            }
            tableView.reloadData()
        }
        
            }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)   {
        
        let alert = UIAlertController(title:"Edit Exercise", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Write here your exercise name"
        }
        
        
        alert.addAction(UIAlertAction(title: "Edit Exercise", style: UIAlertAction.Style.default, handler: { action in
            // What will happen when user presses "Add Item"
            
            if let textField = alert.textFields?[0],
               let newText = textField.text{
                
                self.workoutPlan?.sets?[indexPath.section].exercises[indexPath.row].name = newText
                
                self.tableView.reloadData()
            }
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          }))
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
//    self.workoutPlan?.sets?[sourceIndexPath.section].exercises.remove(at: sourceIndexPath.row)
    
    
    
    @objc func addExerciseToSection(button: UIButton) {
        
        let alert = UIAlertController(title:"Add new Exercise", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Write here your exercise name"
        }
        
        
        alert.addAction(UIAlertAction(title: "Add Exercise", style: UIAlertAction.Style.default, handler: { action in
            // What will happen when user presses "Add Item"
            
            if let textField = alert.textFields?[0],
               let newText = textField.text{
                
                let w = WorkoutExercise(name: newText, details: "3x 8-12")
                self.workoutPlan?.sets?[button.tag].exercises.append(w)
                self.tableView.reloadData()
            }
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
