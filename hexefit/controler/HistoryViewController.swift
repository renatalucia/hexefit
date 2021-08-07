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
    
    var userProfile = UserProfile()
    
    var hkAssistant = HealthKitAssistant()
    
    @IBOutlet weak var trainingsButton: UIBarButtonItem!
    
    
    @IBOutlet weak var historyButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - HealthKit Methods
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    func loadUserProfile(completionHandler: @escaping CompletionHandler){
        var birthdayComponents: DateComponents?
        var restingHeartRate: HKQuantitySample?
        var basalEnergyBurned: HKQuantitySample?
        
        let heartRateUnit: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())

        
        let group = DispatchGroup()
        
        group.enter()
        hkAssistant.loadUserBirthday { birthday in
            birthdayComponents = birthday
            group.leave()
        }
        
        group.enter()
        hkAssistant.loadUserRestingHeartRate { rhr in
            print(rhr.count)
            print(rhr.quantity)
            print(rhr.quantityType)
            restingHeartRate = rhr
            group.leave()
        }
        
        group.enter()
        hkAssistant.loadUserBasalEnergyBurned  { beb in
                print(beb.count)
                print(beb.quantity)
                print(beb.quantityType)
                basalEnergyBurned = beb
                group.leave()
        }
       
        
        group.notify(queue: .main) {
            self.userProfile.birthdayComponents = birthdayComponents
            self.userProfile.restingHeartRate = restingHeartRate?.quantity.doubleValue(for: heartRateUnit)
            self.userProfile.basalEnergyBurned = basalEnergyBurned?.quantity.doubleValue(for: HKUnit.kilocalorie())
            completionHandler(true)
        }
        
        
    }
    
    func loadWorkouts(completionHandler: @escaping CompletionHandler){
        print("loadWorkouts()")
        
        if hexWorkouts == nil{
            hexWorkouts = []
        }
        
        guard self.hexWorkouts != nil else {fatalError("HexWorkouts is nill")}
        
        let hkGroup = DispatchGroup()
        
        if  hkWorkouts == nil {
            hkGroup.enter()
            hkAssistant.loadWorkouts (limit: 30, completion: { (workouts, error) in
                print("N. of workouts: \(workouts!.count)")
                if error == nil{
                    self.hkWorkouts = workouts!
                }
                else{
                    print("load workouts error")
                }
                hkGroup.leave()
            })
        }
        
        hkGroup.notify(queue: .main) {
            let group = DispatchGroup()
            for workout in self.hkWorkouts!{
                group.enter()
//                print(workout.startDate)
                self.hkAssistant.loadHeartRates(for: workout) { samples, error in
                    if error == nil{
                        let hexWorkout = HexWorkout(hkWorkout: workout, heartRates: samples!, user: self.userProfile)
                        self.hexWorkouts!.append(hexWorkout)
                    }
                    else{
                        print("error loading heart rates. Error: \(String(describing: error))")
                    }
                    group.leave()
                }
            }
            
            
            group.notify(queue: .main) {
                completionHandler(true)
                print("N. of hexworkouts: \(self.hexWorkouts!.count)")
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
            
            
            let group = DispatchGroup()
            group.enter()
            self.loadUserProfile { success in
                if success{
                    print("age: \(String(describing: self.userProfile.age))")
                    print("rhr: \(String(describing: self.userProfile.restingHeartRate))")
         
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                self.loadWorkouts { success in
                    print(success)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
            
            print("HealthKit Successfully Authorized.")
        }
    }
    
    
    
    
    // MARK: - LifeCycle Methods
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.hexWorkouts = []
        
        tableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "historyReusableCell")
        tableView.rowHeight = 100;
        tableView.separatorStyle = .none
        
        authorizeHealthKit()
        
        
        
        
    }
    
       
}

extension HistoryViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        performSegue(withIdentifier: "ToActivitySummary", sender: self)

    }

}

extension HistoryViewController: UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return max(workouts?.count ?? 0, 5)
        return hexWorkouts?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //1. Get a cell to display the workout in
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyReusableCell", for: indexPath) as! HistoryCell
        
        guard self.hexWorkouts != nil else{
            fatalError("no workouts to load")}
        
        
        //2. Get the workout corresponding to this row
        if let safeHexWorkouts = self.hexWorkouts{
            let hexworkout = safeHexWorkouts[indexPath.row]
            let workout = hexworkout.hkWorkout
            
            //3. Show the workout info
            cell.workoutType.text = workout.workoutActivityType.name
            cell.activityIcon.image = UIImage(named: "run")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            cell.startTime.text = formatter.string(from: workout.startDate)
            
            let duration = (Int(workout.duration) / 60 ) % 60
//            let maxHR = heartRates.max().map { String($0) } ?? "Value not provided"
//            cell.duration.text = "\(duration)min, \(maxHR)"
            if let workoutntensity = hexworkout.intensity{
                cell.duration.text = "\(duration)min, \(workoutntensity)"
            } else{
                cell.duration.text = "\(duration)min"
            }
            
            
        } else {
            fatalError("Error loading Workout")
        }
        
        return cell
    }
    

    

    
}

