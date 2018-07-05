//
//  HealthManager.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 23.02.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

class HealthManager{
    static let healthKitStore:HKHealthStore = HKHealthStore()
    
    class func saveMeditation(start:Date,ende:Date,meditation:Meditation){
        guard let mindfulType = HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession) else {return}
        // Now create the sample
        let mindfulSample   = HKCategorySample(type: mindfulType, value: HKCategoryValue.notApplicable.rawValue, start: start, end: ende)
        // Finally save to health store
        healthKitStore.save(mindfulSample) { (result:Bool, error:Error?) in
            if result{
                meditation.inHealthKit = true
                print("Saved")
            }else{ print("error saving mindfulSession",error?.localizedDescription ?? "Fehler") }
        }
    }
    
    
    func updateHealthKit(){
        let status = HealthManager.healthKitStore.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: .mindfulSession)!)
        if status == .sharingAuthorized{
            let meditationen    = Meditation.getNotInHealthKit()
            for meditation in meditationen{ saveMeditationIfNeeded(meditation: meditation) }
        }
        
    }
    
    func saveMeditationIfNeeded(meditation:Meditation){
        guard let start     = meditation.start  else {return}
        let ende            = start.addingTimeInterval(meditation.gesamtDauer)
        guard let mindfulType   = HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession) else {return}
        let predicate           = NSPredicate(format: "startDate == %@ && endDate == %@", start as CVarArg, ende as CVarArg)
        let query               = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: 10, sortDescriptors: nil)
        { (query, results, error) in
            if let results = results as? [HKCategorySample], let _ = results.first {
                meditation.inHealthKit = true
            }
            else{ HealthManager.saveMeditation(start: start as Date, ende: ende as Date,meditation: meditation) }
        }
        HealthManager.healthKitStore.execute(query)
    }

    func deleteMeditation(meditation:Meditation){
        guard let mindfulType   = HKSampleType.categoryType(forIdentifier: HKCategoryTypeIdentifier.mindfulSession) else {return}
        if let start = meditation.start{
            let ende                = start.addingTimeInterval(meditation.gesamtDauer) as Date
            let predicate           = NSPredicate(format: "startDate == %@ && endDate == %@", start as CVarArg, ende as CVarArg)
            let query               = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: 10, sortDescriptors: nil)
            { (query, results, error) in
                if let results = results as? [HKCategorySample], let result = results.first {
                    print(result)
                    HealthManager.deleteMeditation(meditation: result)
                }
            }
            HealthManager.healthKitStore.execute(query)
        }
        
    }
    private static func deleteMeditation(meditation:HKCategorySample){
        HealthManager.healthKitStore.delete(meditation) {(success, error) -> Void in
            if(error != nil) { print("Error deleting sample: \(String(describing: error?.localizedDescription))")}
            else{print("meditation \(meditation.startDate.string("dd.MM.yy hh:mm")) gelöscht")}
        }
    }
    
    func authorizeHealthKit(completion: ((Bool,Error?) -> Void)!)
    {
        let hkTypesToRead   = Set([HKObjectType.categoryType(forIdentifier: .mindfulSession)!])
        let hkTypesToWrite  = Set([HKSampleType.categoryType(forIdentifier: .mindfulSession)!])
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        guard HKHealthStore.isHealthDataAvailable() else {return}
        // 4.  Request HealthKit authorization
        HealthManager.healthKitStore.requestAuthorization(toShare: hkTypesToWrite, read: hkTypesToRead) { (success, error) -> Void in}
    }
}
