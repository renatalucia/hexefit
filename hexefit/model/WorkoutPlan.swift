//
//  WorkoutPlan.swift
//  hexefit
//
//  Created by Renata Rego on 27/07/2021.
//

import Foundation

struct WorkoutPlan{
    
    var name: String
    var description: String
    var sets: [WorkoutSet]?
    
}

struct WorkoutSet{
    var seqNumber: Int
    var exercises: [WorkoutExercise]
}

struct WorkoutExercise{
    var name: String
    var details: String
}
