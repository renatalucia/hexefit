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
    
    var heartRates: [Double]
    
//    var endDate: 
    
    init(hkWorkout: HKWorkout, heartRates: [Double]){
        self.hkWorkout = hkWorkout
        self.heartRates = heartRates
    }
}
