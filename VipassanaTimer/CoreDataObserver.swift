//
//  CoreDataObserver.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataObserver{
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    
//    init() {
//        print("CoreDataObserver init")
//        _ = Singleton.sharedInstance
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name:
//            NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
//        
////            notificationCenter.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSManagedObjectContextWillSaveNotification, object: managedObjectContext)
////            notificationCenter.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSManagedObjectContextDidSaveNotification, object: managedObjectContext)
//        
//    }
//    
//    @objc private func managedObjectContextObjectsDidChange(notification: NSNotification) {
//        guard let userInfo = notification.userInfo else { return }
//        
//        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
//            if let meditationen = inserts as? Set<Meditation>{
//                for meditation in meditationen{
//                    if meditation.cloudNeedsUpdate == false{
//                        meditation.cloudNeedsUpdate = true
//                    }
//                }
////                Singleton.sharedInstance.myCloudKit?.updateNow()
//            }
//        }
//        
//        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
//            if let meditationen = updates as? Set<Meditation>{
//                for meditation in meditationen{
//                    var changedValues = meditation.changedValues()
//                    changedValues.removeValue(forKey: "cloudNeedsUpdate")
//                    
//                    if changedValues.count > 0 && meditation.cloudNeedsUpdate == false{
//                        var updateNeeded = false
//                        for key in changedValues.keys{
//                            if key == "mettaOpenEnd" || key == "start" || key == "dauerAnapana" || key == "dauerVipassana" || key == "dauerMetta"{
//                                updateNeeded = true
//                            }
//                        }
//                        if updateNeeded{
//                            print("update Meditation changed: \(changedValues) in CloudKit")
//                            meditation.cloudNeedsUpdate = true
//                        }
//                    }
//                    
//                }
//                print("updates")
//                Singleton.sharedInstance.myCloudKit?.updateNow()
//            }
//        }
//        
//        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
//            if let meditationen = deletes as? Set<Meditation>{
//                for meditation in meditationen{
//                    Singleton.sharedInstance.myCloudKit?.delete(meditation)
//                }
//            }
//        }
//    }
    

}


