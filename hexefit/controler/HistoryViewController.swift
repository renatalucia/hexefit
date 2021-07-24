//
//  HistoryViewController.swift
//  hexefit
//
//  Created by Renata Rego on 17/07/2021.
//

import UIKit



class HistoryViewController: UIViewController {
    
    var userId: String?
    var hexWorkouts: [HexWorkout]?
    
    var hkAssistant = HealthKitAssistant()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - HealthKit Methods
    
    func loadWorkouts(){
//        var count = 1
        hkAssistant.loadWorkouts { (workouts, error) in
            print("N. of workouts: \(workouts!.count)")
            if error == nil{
                self.hexWorkouts = []
                guard self.hexWorkouts != nil else {fatalError("HexWorkouts is nill")}
                
                let group = DispatchGroup()
                for workout in workouts!{
                    group.enter()
//                    print(count)
//                    count += 1
                    
                    self.hkAssistant.loadHeartRates(for: workout) { samples, error in
                        group.leave()
                        if error == nil{
                            let hexWorkout = HexWorkout(hkWorkout: workout, heartRates: samples!)
                            self.hexWorkouts!.append(hexWorkout)
                        }
                    }
                }
                
     
//                self.hexWorkouts = self.hexWorkouts?.sorted(by: { ($0.hkWorkout.endDate) > ($1.hkWorkout.endDate) })
                group.notify(queue: .main) {
                    print("N. of hexworkouts: \(self.hexWorkouts!.count)")
                    DispatchQueue.main.async {
                          self.tableView.reloadData()
                    }
                }
               

            }
            
            else{
                print("load workouts produced an error")
            }
 
        }
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
            
            self.loadWorkouts()
            DispatchQueue.main.async {
                  self.tableView.reloadData()
            }
            print("HealthKit Successfully Authorized.")
        }
    }
        
    
    
    
    // MARK: - LifeCycle Methods
    

        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        
        tableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "historyReusableCell")
        tableView.rowHeight = 120;
        tableView.separatorStyle = .none
        
        authorizeHealthKit()
        
        
        
    }
    
}

extension HistoryViewController: UITableViewDataSource{

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return max(workouts?.count ?? 0, 5)
        return hexWorkouts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard hexWorkouts != nil else {
            fatalError("no workouts to load")
        }
    
        
        //2. Get the workout corresponding to this row
        if let safeHexWorkouts = hexWorkouts{
            let hexworkout = safeHexWorkouts[indexPath.row]
            let workout = hexworkout.hkWorkout
            let heartRates = hexworkout.heartRates
    
        
            //1. Get a cell to display the workout in
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyReusableCell", for: indexPath) as! HistoryCell
        
        
            
            //3. Show the workout info
            cell.workoutType.text = workout.workoutActivityType.name
            cell.activityIcon.image = UIImage(named: "run")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            cell.startTime.text = formatter.string(from: workout.startDate)
            
            let duration = (Int(workout.duration) / 60 ) % 60
            let maxHR = heartRates.max().map { String($0) } ?? "Value not provided"
            cell.duration.text = "\(duration)min, \(maxHR)"
        
            return cell
        } else {
            fatalError("Error loading Workout")
        }
    }
    
}

