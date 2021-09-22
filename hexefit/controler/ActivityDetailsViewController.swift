//
//  ActivityDetailsViewController.swift
//  hexefit
//
//  Created by Renata Rego on 19/09/2021.
//

import UIKit

class ActivityDetailsViewController: UIViewController {
    
    var hexWorkout: HexWorkout?
    var userProfile: UserProfile?
    var workoutIconName: String?
    
    @IBOutlet weak var workoutName: UILabel!
    @IBOutlet weak var workoutIcon: UIImageView!
    
    
    @IBOutlet weak var durationValue: UILabel!
    @IBOutlet weak var hrRangeValue: UILabel!
    @IBOutlet weak var intensityRangeValue: UILabel!
    @IBOutlet weak var activeCalValue: UILabel!
    @IBOutlet weak var distanceValue: UILabel!
    @IBOutlet weak var hrAvgValue: UILabel!
    @IBOutlet weak var intensityAvgValue: UILabel!
    @IBOutlet weak var CalBurnLevel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillUIValues()

        // Do any additional setup after loading the view.
    }
    
    func fillUIValues(){
        if let safeWorkout = hexWorkout{
            workoutName.text = safeWorkout.hkWorkout.workoutActivityType.name
            workoutIcon.image = UIImage(named: workoutIconName ?? "Workout")
            
            durationValue.text = "\(String(Int(safeWorkout.hkWorkout.duration/60)))min"
            
            let distance = safeWorkout.hkWorkout.totalDistance?.doubleValue(for: .meter()) ?? 0.0
            distanceValue.text = "\(String(format: "%.1f", distance/1000))km"
            
            let minHR = safeWorkout.heartRates?.min() ?? 0.0
            let maxHR = safeWorkout.heartRates?.max() ?? 0.0
            let avgHR = safeWorkout.avgHR ?? 0.0
            
            hrRangeValue.text = "\(String(Int(minHR))) - \(String(Int(maxHR)))bpm"
            hrAvgValue.text = "\(String(format: "%.1f", avgHR))bpm"
            
            if let safeUserProfile = userProfile{
                let intensityMin = (minHR/safeUserProfile.maxHeartRate) * 100
                let intensityMax = (maxHR/safeUserProfile.maxHeartRate) * 100
                let intensityAvg = (avgHR/safeUserProfile.maxHeartRate) * 100
                intensityRangeValue.text = "\(Int(intensityMin))-\(Int(intensityMax))%"
                intensityAvgValue.text = "\(String(format: "%.1f", intensityAvg))%"
                
            }
            
            let cal = safeWorkout.hkWorkout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0.0
            activeCalValue.text = "\(String(Int(cal)))kcal"
            
            CalBurnLevel.text = hexWorkout?.intensity
            
                
        }
        
    }
    

    /*
    //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    

}
