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
    
    var itemsInSections: Array<Array<String>> = [["Agachamento", "Agachamento isometrico com bola"], ["Agachamento isometrico com bola", "Agachamento com bola"], ["Pernada Alternada"]]
        var sections: Array<String> = ["I", "II", "III"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "WorkoutPlanTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseReusableCell")
        print(workoutPlan?.name as Any)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.isEditing = true
        tableView.allowsSelection = true
        tableView.allowsSelectionDuringEditing = true
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        print("number of sections: \(sections.count)")
//        return self.sections.count
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsInSections[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseReusableCell") as! WorkoutPlanTableViewCell
        let exercixeName = self.itemsInSections[indexPath.section][indexPath.row]
        
        cell.exerciseName.text = exercixeName
        
        cell.exerciseData.text = "3x 8-12"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                            willDisplayHeaderView view: UIView,
                            forSection section: Int){


        let button = UIButton(type: .system)

        button.setTitle("add", for: .normal)
        //button.setImage(UIImage(named:"Plus"), for: .normal)

        button.setTitleColor(.systemBlue, for: .normal)
        
        button.tag = section
        

        button.addTarget(self, action: #selector(addExerciseToSection), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(button)
        let margins = view.layoutMarginsGuide
        button.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 10).isActive = true
//        button.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0).isActive = true
    }
    
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.itemsInSections[sourceIndexPath.section][sourceIndexPath.row]
        itemsInSections[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        itemsInSections[sourceIndexPath.section].insert(movedObject, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            itemsInSections[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
  
   
        print(itemsInSections[indexPath.section])
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
                
                self.itemsInSections[indexPath.section][indexPath.row] = newText
     
                self.tableView.reloadData()
            }
            
            
        }))
        
        present(alert, animated: true, completion: nil)
    }
    


    
    
    
    
    @objc func addExerciseToSection(button: UIButton) {
        
        let alert = UIAlertController(title:"Add new Exercise", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Write here your exercise name"
        }
        
        
        alert.addAction(UIAlertAction(title: "Add Exercise", style: UIAlertAction.Style.default, handler: { action in
            // What will happen when user presses "Add Item"
            
            if let textField = alert.textFields?[0],
               let newText = textField.text{
                
                self.itemsInSections[button.tag].append(newText)
                self.tableView.reloadData()
            }
            
            
        }))
        
        present(alert, animated: true, completion: nil)

    }
    

}
