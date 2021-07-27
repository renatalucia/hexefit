//
//  PlansViewController.swift
//  hexefit
//
//  Created by Renata Rego on 27/07/2021.
//

import UIKit

class PlansViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var wokoutPlans = [
        WorkoutPlan(name: "Lower Body Workout", description: "Created at 29.07.2021", sets: nil),
        WorkoutPlan(name: "Upper Body Workout", description: "Created at 27.07.2021", sets: nil)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        
        tableView.register(UINib(nibName: "PlanCell", bundle: nil), forCellReuseIdentifier: "PlanReusableCell")

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PlansViewController: UITableViewDelegate{
}

extension PlansViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wokoutPlans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanReusableCell", for: indexPath) as! PlanCell
        cell.planName.text = wokoutPlans[indexPath.row].name
        cell.planDescription.text = wokoutPlans[indexPath.row].description
        return cell
    }
    
}
