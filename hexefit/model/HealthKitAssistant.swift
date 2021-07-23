//
//  HealthKitAssistant.swift
//  hexefit
//
//  Created by Renata Rego on 17/07/2021.
//

import Foundation
import HealthKit

struct HealthKitAssistant{
    
    var healthStore: HKHealthStore?
    
    init() {
        createHealthStore()
    }
    
    
    func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        //1. Check to see if HealthKit Is Available on this device
        guard HKHealthStore.isHealthDataAvailable() else {
            fatalError("Fatal Error")
            
        }
        
        //2. Prepare the data types that will interact with HealthKit
        guard   let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
                let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
                let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
                let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
                let height = HKObjectType.quantityType(forIdentifier: .height),
                let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass),
                let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            fatalError("Error Fatal")
        }
        
        //3. Prepare a list of types you want HealthKit to read and write
        let healthKitTypesToWrite: Set<HKSampleType> = [bodyMassIndex,
                                                        activeEnergy,
                                                        HKObjectType.workoutType()]
        
        let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                       bloodType,
                                                       biologicalSex,
                                                       bodyMassIndex,
                                                       height,
                                                       bodyMass,
                                                       HKObjectType.workoutType(),
                                                       HKObjectType.quantityType(forIdentifier: .heartRate)!]
        
        
        
        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
    
    mutating func createHealthStore(){
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            fatalError("Health Data not Available")
        }
    }
    
    func loadWorkouts(completion:
                        @escaping ([HKWorkout]?, Error?) -> Void) {
        
        
        authorizeHealthKit { (authorization, error) in
            guard error == nil else {
                fatalError("HeathKit not Authorized")
                // Not authorized, do something about it (for example UI message)
            }
            
            
            // At this point, "authorization" is true, no need to check
            // Get all workouts
            let workoutPredicate = HKQuery.predicateForWorkouts(with: .greaterThanOrEqualTo, duration: 1)
            
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                                  ascending: false)
            
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: workoutPredicate,
                limit: 0,
                sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                // DispatchQueue.main.async {
                guard
                    let samples = samples as? [HKWorkout],
                    error == nil
                else {
                    print("found an error: \(String(describing: error))")
                    completion(nil, error)
                    return
                }
                
                completion(samples, nil)
            }
            
            HKHealthStore().execute(query)
        }
        
    }
    
    func loadHeartRates(for workout: HKWorkout, completion:
                            @escaping ([Double]?, Error?) -> Void) {
        
        authorizeHealthKit { (authorization, error) in
            guard error == nil else {
                fatalError("HeathKit not Authorized")
                // Not authorized, do something about it (for example UI message)
            }
            
            let heartRateUnit:HKUnit = HKUnit(from: "count/min")
            let heartRateType:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
            var heartRateQuery:HKSampleQuery?
            
            
            let startDate = workout.startDate
            let endDate = workout.endDate
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: endDate,
                options: [])
            
            
            let sortDescriptors = [
                NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            ]
            var heartRates: [Double] = []
            heartRateQuery = HKSampleQuery(
                sampleType: heartRateType,
                predicate: predicate,
                limit: 10000, //TODO: return all
                //            limit: Int.max,
                sortDescriptors: sortDescriptors,
                resultsHandler: { (query, results, error) in
                    
                    guard error == nil else {
                        print("found an error: \(String(describing: error))")
                        completion(nil, error)
                        return
                    }
                    
                    for (_, sample) in results!.enumerated() {
                        guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
                        heartRates.append(currData.quantity.doubleValue(for: heartRateUnit))
                    }
                    
                    completion(heartRates, nil)
                }
                
            )
            
            healthStore?.execute(heartRateQuery!)
            
        }
    }
    
}
