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
    
    
    static func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
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
                let activeEnergy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
                let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate),
                let basalEnergyBurned = HKObjectType.quantityType(forIdentifier: .basalEnergyBurned),
                let activeEnergyBurned = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
                let flightsClimbed = HKObjectType.quantityType(forIdentifier: .flightsClimbed),
                let stepsCount = HKObjectType.quantityType(forIdentifier: .stepCount)
        else {
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
                                                       restingHeartRate,
                                                       basalEnergyBurned,
                                                       activeEnergyBurned,
                                                       stepsCount,
                                                       flightsClimbed,
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
    
    
    
    
    func loadUserBirthday  (completion:
                                @escaping (DateComponents?) -> Void)   {
        
        let healthKitStore = HKHealthStore()
        do{
            let birthdayComponents = try healthKitStore.dateOfBirthComponents()
            completion(birthdayComponents)
        } catch {
            print("could not load date of birthday")
            completion(nil)
        }
        
        
        
    }
    
    func loadUserBasalEnergyBurned(completion: @escaping (HKQuantitySample) -> Void) {
        
        guard let basalEnergyBurnedSampleType = HKSampleType.quantityType(forIdentifier: .basalEnergyBurned) else {
            print("Basal Energy Burned Sample Type is no longer available in HealthKit")
            return
        }
        
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(
            withStart: Date.distantPast,
            end: Date().dayBefore)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        //let limit = 1
        let sampleQuery = HKSampleQuery(sampleType: basalEnergyBurnedSampleType,
                                        predicate: mostRecentPredicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors:
                                            [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                    print("loadUserBasalEnergyBurned sample is missing")
                    return
                }
                completion(mostRecentSample)
            }
        }
        HKHealthStore().execute(sampleQuery)
    }
    
    
    func loadUserRestingHeartRate(completion: @escaping (HKQuantitySample) -> Void) {
        
        guard let restingHeartRateSampleType = HKSampleType.quantityType(forIdentifier: .restingHeartRate) else {
            print("Resting Heart Rate Sample Type is no longer available in HealthKit")
            return
        }
        
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        //let limit = 1
        let sampleQuery = HKSampleQuery(sampleType: restingHeartRateSampleType,
                                        predicate: mostRecentPredicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors:
                                            [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKQuantitySample else {
                    print("loadUserRestingHeartRate sample is missing")
                    return
                }
                completion(mostRecentSample)
            }
        }
        HKHealthStore().execute(sampleQuery)
    }
    
    
    func loadWorkouts(limit: Int, completion:
                        @escaping ([HKWorkout]?, Error?) -> Void) {
        
        
        HealthKitAssistant.authorizeHealthKit { (authorization, error) in
            guard error == nil else {
                fatalError("HeathKit not Authorized. Reason: \(String(describing: error))")
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
                limit: limit,
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
        
        HealthKitAssistant.authorizeHealthKit { (authorization, error) in
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

extension Date {
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}
