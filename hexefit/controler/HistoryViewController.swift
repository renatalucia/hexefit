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
    var healthStore: HKHealthStore?
    var hexWorkouts: [HexWorkout]?
    
    var hkAssistant = HealthKitAssistant()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - HealthKit Methods
    
    
    
    
    // MARK: - LifeCycle Methods
    
    override  func viewDidAppear(_ animated: Bool) {
        print("here")
        tableView.dataSource = self
        hexWorkouts = hexWorkouts?.sorted(by: { ($0.hkWorkout.endDate) > ($1.hkWorkout.endDate) })
        //        print(hexWorkouts)
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        //healthStoreAvailable = createHealthStore()
        
        hkAssistant.loadWorkouts { (workouts, error) in
            print("N. of workouts: \(workouts!.count)")
            if error == nil{
                self.hexWorkouts = []
                guard self.hexWorkouts != nil else {fatalError("HexWorkouts is nill")}
                for workout in workouts!{
                    self.hkAssistant.loadHeartRates(for: workout) { samples, error in
                        if error == nil{
                            let hexWorkout = HexWorkout(hkWorkout: workout, heartRates: samples!)
                            self.hexWorkouts!.append(hexWorkout)
                        }
                    }
                }
            }
            else{
                print("load workouts produced an error")
            }
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        hkAssistant.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                
                return
            }
            
            print("HealthKit Successfully Authorized.")
        }
        

        tableView.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "historyReusableCell")
        tableView.rowHeight = 120;
        tableView.separatorStyle = .none
        
        
        
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

extension HKWorkoutActivityType {
    
    /*
     Simple mapping of available workout types to a human readable name.
     */
    var name: String {
        switch self {
        case .americanFootball:             return "American Football"
        case .archery:                      return "Archery"
        case .australianFootball:           return "Australian Football"
        case .badminton:                    return "Badminton"
        case .baseball:                     return "Baseball"
        case .basketball:                   return "Basketball"
        case .bowling:                      return "Bowling"
        case .boxing:                       return "Boxing"
        case .climbing:                     return "Climbing"
        case .crossTraining:                return "Cross Training"
        case .curling:                      return "Curling"
        case .cycling:                      return "Cycling"
        case .dance:                        return "Dance"
        case .danceInspiredTraining:        return "Dance Inspired Training"
        case .elliptical:                   return "Elliptical"
        case .equestrianSports:             return "Equestrian Sports"
        case .fencing:                      return "Fencing"
        case .fishing:                      return "Fishing"
        case .functionalStrengthTraining:   return "Functional Strength Training"
        case .golf:                         return "Golf"
        case .gymnastics:                   return "Gymnastics"
        case .handball:                     return "Handball"
        case .hiking:                       return "Hiking"
        case .hockey:                       return "Hockey"
        case .hunting:                      return "Hunting"
        case .lacrosse:                     return "Lacrosse"
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind and Body"
        case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
        case .paddleSports:                 return "Paddle Sports"
        case .play:                         return "Play"
        case .preparationAndRecovery:       return "Preparation and Recovery"
        case .racquetball:                  return "Racquetball"
        case .rowing:                       return "Rowing"
        case .rugby:                        return "Rugby"
        case .running:                      return "Running"
        case .sailing:                      return "Sailing"
        case .skatingSports:                return "Skating Sports"
        case .snowSports:                   return "Snow Sports"
        case .soccer:                       return "Soccer"
        case .softball:                     return "Softball"
        case .squash:                       return "Squash"
        case .stairClimbing:                return "Stair Climbing"
        case .surfingSports:                return "Surfing Sports"
        case .swimming:                     return "Swimming"
        case .tableTennis:                  return "Table Tennis"
        case .tennis:                       return "Tennis"
        case .trackAndField:                return "Track and Field"
        case .traditionalStrengthTraining:  return "Traditional Strength Training"
        case .volleyball:                   return "Volleyball"
        case .walking:                      return "Walking"
        case .waterFitness:                 return "Water Fitness"
        case .waterPolo:                    return "Water Polo"
        case .waterSports:                  return "Water Sports"
        case .wrestling:                    return "Wrestling"
        case .yoga:                         return "Yoga"
            
        // iOS 10
        case .barre:                        return "Barre"
        case .coreTraining:                 return "Core Training"
        case .crossCountrySkiing:           return "Cross Country Skiing"
        case .downhillSkiing:               return "Downhill Skiing"
        case .flexibility:                  return "Flexibility"
        case .highIntensityIntervalTraining:    return "High Intensity Interval Training"
        case .jumpRope:                     return "Jump Rope"
        case .kickboxing:                   return "Kickboxing"
        case .pilates:                      return "Pilates"
        case .snowboarding:                 return "Snowboarding"
        case .stairs:                       return "Stairs"
        case .stepTraining:                 return "Step Training"
        case .wheelchairWalkPace:           return "Wheelchair Walk Pace"
        case .wheelchairRunPace:            return "Wheelchair Run Pace"
            
        // iOS 11
        case .taiChi:                       return "Tai Chi"
        case .mixedCardio:                  return "Mixed Cardio"
        case .handCycling:                  return "Hand Cycling"
            
        // iOS 13
        case .discSports:                   return "Disc Sports"
        case .fitnessGaming:                return "Fitness Gaming"
            
        // Catch-all
        default:                            return "Other"
        }
    }
}
