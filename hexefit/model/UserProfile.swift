//
//  UserProfile.swift
//  hexefit
//
//  Created by Renata Rego on 25/07/2021.
//

import Foundation

struct  UserProfile {
    let defaultAge: Int = 30 // Default age assumed for workout intensity calculations
    let defaultRestingHeartRate: Double = 70
    
    var restingHeartRate: Double?
    var basalEnergyBurned: Double?
    var birthdayComponents: DateComponents?
    
    
    var age: Int? {
        if let safeBirthdayComponents = birthdayComponents {
            let  today = Date()
            let calendar = Calendar.current
            let todayDateComponents = calendar.dateComponents([.year],
                                                                from: today)
            return todayDateComponents.year! - safeBirthdayComponents.year!
        } else {
            return nil
        }
    }
    
    var maxHeartRate: Double {
        let safeAge = age ?? defaultAge
        return (220.0 - Double(safeAge))

    }
    
    var heartRateReserve: Double {
        let rhr = restingHeartRate ?? defaultRestingHeartRate
        return maxHeartRate - rhr
 
    }
    
    var heartRateThresholds: [Double]{
        let rhr = restingHeartRate ?? defaultRestingHeartRate
        return [
            (heartRateReserve*0.5) + rhr,
            (heartRateReserve*0.7) + rhr,
            (heartRateReserve*0.8) + rhr,
        ]
    }
}
