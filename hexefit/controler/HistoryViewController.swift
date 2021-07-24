//
//  HistoryViewController.swift
//  hexefit
//
//  Created by Renata Rego on 17/07/2021.
//

import UIKit
import HealthKit


class HistoryViewController: UIViewController {
    
    var userId: String?
    var hexWorkouts: [HexWorkout]?
    var hkWorkouts: [HKWorkout]?
    
    var hkAssistant = HealthKitAssistant()
    
    let loadstep = 400
    var loadcurr = 0
    var tableViewCount = 0
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - HealthKit Methods
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    
    
    func loadWorkouts(completionHandler: @escaping CompletionHandler){
        print("loadWorkouts()")
        
        if hexWorkouts == nil{
            hexWorkouts = []
        }
        
        guard self.hexWorkouts != nil else {fatalError("HexWorkouts is nill")}
        
        let hkGroup = DispatchGroup()
        
        if  hkWorkouts == nil {
            hkGroup.enter()
            hkAssistant.loadWorkouts { (workouts, error) in
                print("N. of workouts: \(workouts!.count)")
                self.tableViewCount = workouts!.count
                if error == nil{
                    self.hkWorkouts = workouts!
                }
                else{
                    print("load workouts error")
                }
                hkGroup.leave()
            }
        }
        
        hkGroup.notify(queue: .main) {
            let group = DispatchGroup()
            //for workout in workouts!{
            let lastIdx = min((self.loadcurr + self.loadstep - 1), self.hkWorkouts!.count)
//            print(self.loadcurr)
            print(lastIdx)
            
            for i in self.loadcurr...lastIdx-1{
                group.enter()
                let workout = self.hkWorkouts![i]
                print(workout.workoutActivityType.name)
                self.loadcurr += 1
                
                print("loadcurr = \(self.loadcurr)")
                self.hkAssistant.loadHeartRates(for: workout) { samples, error in
                    print("error: \(String(describing: error))")
                    if error == nil{
                        let hexWorkout = HexWorkout(hkWorkout: workout, heartRates: samples!)
                        print("append to hexworkouts")
                        self.hexWorkouts!.append(hexWorkout)
                    }
                    else{
                        print("error loading heart rates. Error: \(String(describing: error))")
                    }
                    group.leave()
                }
            }
            
            
            //                self.hexWorkouts = self.hexWorkouts?.sorted(by: { ($0.hkWorkout.endDate) > ($1.hkWorkout.endDate) })
            group.notify(queue: .main) {
                completionHandler(true)
                print("N. of hexworkouts: \(self.hexWorkouts!.count)")
                print("loadcurr: \(self.loadcurr)")
                self.hexWorkouts = self.hexWorkouts?.sorted(by: { ($0.hkWorkout.endDate) > ($1.hkWorkout.endDate) })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

        }
//        completionHandler(true)
    
}



func authorizeHealthKit(){
    HealthKitAssistant.authorizeHealthKit { (authorized, error) in
        
        guard authorized else {
            
            let baseMessage = "HealthKit Authorization Failed"
            
            if let error = error {
                print("\(baseMessage). Reason: \(error.localizedDescription)")
            } else {
                print(baseMessage)
            }
            
            
            
            return
        }
        
        self.loadWorkouts { success in
            print("in authorize")
            print(success)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        print("HealthKit Successfully Authorized.")
    }
}




// MARK: - LifeCycle Methods



override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    self.hexWorkouts = []
    
    tableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "historyReusableCell")
    tableView.rowHeight = 120;
    tableView.separatorStyle = .none
    
    authorizeHealthKit()
    
    
    
}

}

extension HistoryViewController: UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return max(workouts?.count ?? 0, 5)
        //                return hexWorkouts?.count ?? 0
        return tableViewCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        //1. Get a cell to display the workout in
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyReusableCell", for: indexPath) as! HistoryCell
        
        let tvgroup = DispatchGroup()
        
        if indexPath.row >= self.loadcurr {
            tvgroup.enter()
            print("indexPath.row >= self.loadcurr")
            self.loadWorkouts { success in
                if (!success){
                    print("workouts not loaded")
                } else {
                    print("success")
                }
                tvgroup.leave()
            }
            
        }
        
        
        // does not wait. But the code in notify() gets run
        // after enter() and leave() calls are balanced
        
        tvgroup.notify(queue: .main) {
            guard self.hexWorkouts != nil else {
                fatalError("no workouts to load")
            }
            
            //2. Get the workout corresponding to this row
            if let safeHexWorkouts = self.hexWorkouts{
                let hexworkout = safeHexWorkouts[indexPath.row]
                let workout = hexworkout.hkWorkout
                let heartRates = hexworkout.heartRates
                
                //3. Show the workout info
                cell.workoutType.text = workout.workoutActivityType.name
                cell.activityIcon.image = UIImage(named: "run")
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy"
                cell.startTime.text = formatter.string(from: workout.startDate)
                
                let duration = (Int(workout.duration) / 60 ) % 60
                let maxHR = heartRates.max().map { String($0) } ?? "Value not provided"
                cell.duration.text = "\(duration)min, \(maxHR)"
                
                
            } else {
                fatalError("Error loading Workout")
            }
            
        }
        return cell
    }
    
}

