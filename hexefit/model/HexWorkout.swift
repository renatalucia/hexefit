//
//  HexWorkout.swift
//  hexefit
//
//  Created by Renata Rego on 20/07/2021.
//

import Foundation
import HealthKit

struct HexWorkout{
    
    var hkWorkout: HKWorkout
    
    var heartRates: [Double]?
    
    var avgHR: Double?
    
    // workout intensity based on energy burned
    // see: https://www.hsph.harvard.edu/obesity-prevention-source/moderate-and-vigorous-physical-activity/
    var intensity: String?
    
//    var endDate: 
    
    init(hkWorkout: HKWorkout, heartRates: [Double], user: UserProfile){
        self.hkWorkout = hkWorkout
        self.heartRates = heartRates
        
        let sumArray = heartRates.reduce(0, +)
        self.avgHR = sumArray / Double(heartRates.count)
        
        if let workoutEnergy = hkWorkout.totalEnergyBurned,
           let basalEnergy = user.basalEnergyBurned{
            
            let caloriesBurned = workoutEnergy.doubleValue(for: HKUnit.kilocalorie())
            let basalCalories = (basalEnergy / 86400.0) * hkWorkout.duration
            
            let calRatio = caloriesBurned / basalCalories
            
            if calRatio < 3.0 {
                self.intensity = "light"
            } else if calRatio < 6.0 {
                self.intensity = "moderate"
            } else {
                self.intensity = "vigorous"
            }
        }
        
        
        
//        if avgHR  < user.heartRateThresholds[0] {
//            self.intensity = "low"
//        } else if avgHR  < user.heartRateThresholds[1] {
//            self.intensity = "moderate"
//        } else if avgHR  < user.heartRateThresholds[2] {
//            self.intensity = "intense"
//        } else {
//            self.intensity = "very intense"
//        }
    }
    
  
    
 
}
