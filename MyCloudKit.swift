////
////  MyCloudKit.swift
////  VipassanaTimer
////
////  Created by Matthias Pochmann on 07.03.17.
////  Copyright © 2017 Matthias Pochmann. All rights reserved.
////
//
//import Foundation
//import CloudKit
//import UIKit
//
//extension Notification.Name.MyNames{
//    static let addOrRemoveActiveMeditationToList = Notification.Name("addOrRemoveActiveMeditationToList")
//    static let gefundenerUser = Notification.Name("gefundeneUser")
//    static let updateFreundesUndFreundesAnfragenListe = Notification.Name("updateFreundesUndFreundesAnfragenListe")
//}
//extension CKRecord{
//    struct MyRecordTypes{
//        static let UserConnection = "UserConnection"
//        static let ActiveMeditation = "ActiveMeditation"
//        static let Meditierender = "Meditierender"
//    }
//}
//enum CoreDataTyp{
//    case Meditierender(Meditierender)
//    case Meditation(Meditation)
//    case ActiveMeditation(CKActiveMeditation)
//    case Freund(Freund)
//}
//
//class MyCloudKit{
//    //delete
//    var toDelete = [CKRecordID]()
//    func delete(_ meditation:Meditation){
//        guard let meditationsID = meditation.meditationsID else {return}
//        toDelete.append(CKRecordID(recordName: meditationsID))
//    }
//    
//    private var activeMeditation:CKActiveMeditation?
//    private var inactivatedMeditation:CKActiveMeditation?
//    var newActiveMeditation:Meditation?{
//        willSet{
//            if newValue != nil {
//                activeMeditation        = CKActiveMeditation(newValue!)
//                inactivatedMeditation   = nil
//            }
//            else if activeMeditation != nil{
//                inactivatedMeditation           = activeMeditation
//                inactivatedMeditation?.isActive         = false
//                inactivatedMeditation?.needsCloudUpdate = true
//                activeMeditation = nil
//            }
//            updateNow()
//        }
//    }
//    
//    
//    
//    //MARK: Updater
//    private let updateInterval = 1.0
//    private var lastUpdate = Date()
//    init() {
//        print("init MyCloudKit start")
//        cleanMyActiveMeditations()
//        let minutenTimer    = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(update), userInfo: nil, repeats: true)
//        minutenTimer.fire()
//    }
//    @objc private func update(){
//        updateNow()
//        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
//    }
//    func updateNow(){
//        if Date().timeIntervalSince(lastUpdate) > updateInterval {
//            lastUpdate = Date()
//            if let meditierender  = Meditierender.getNeedCloudUpdate(){
//                print("needsupdate: meditierender")
//                MyCloudKit.createOrUpdate(meditierender)
//            }
//            for meditation in Meditation.getNeedCloudUpdate(){
//                print("needsupdate: meditation")
//                MyCloudKit.createOrUpdate(meditation)
//            }
//            for delete in toDelete{
//                print("needsupdate: delete")
//                MyCloudKit.delete(delete)
//            }
//            toDelete.removeAll()
//            
//            if activeMeditation != nil && activeMeditation?.needsCloudUpdate == true {
//                print("needsupdate: activeMeditation")
//                MyCloudKit.createOrDelete(activeMeditation!)
//            }
//            if inactivatedMeditation != nil{
//                print("needsupdate: inactivatedMeditation")
//                MyCloudKit.createOrDelete(inactivatedMeditation!)
//                inactivatedMeditation = nil
//            }
//            for freund in Freund.getNeedCloudUpdate(){
//                print("needsupdate: freund")
//                MyCloudKit.createOrUpdate(freund)
//            }
//            for freund in Freund.getDeletionNeeded(){
//                print("needsupdate: freund.del")
//                MyCloudKit.createOrUpdate(freund)
//            }
//        }
//    }
//}
//
//
//
//
//



////MARK: class Methods extension
//extension MyCloudKit{
//    //MARK: Allgemein
//    static let database = CKContainer.default().publicCloudDatabase
//    
//    static func delete(_ recordID:CKRecordID){
//        database.delete(withRecordID: recordID) { (recordID, error) in
//            if error != nil{ print(error!.localizedDescription)
//            }else{ print("Objekt aus CloudKit gelöscht") }  } }
//    
//    static func save(_ recordToSave: CKRecord,coreDataObject:CoreDataTyp?) {
//        database.save(recordToSave) { (savedRecord, error) in
//            if error != nil {
//                print(error as Any)
//                //falls Objekt schon vorhanden  -> cloudNeedsUpdate = true
//            }
//            else{
//                guard let coreDataObject = coreDataObject else{return}
//                switch coreDataObject{
//                case .Meditation(let meditation)        : meditation.cloudNeedsUpdate       = false
//                case .Meditierender(let meditierender)  : meditierender.cloudNeedsUpdate    = false
//                case .ActiveMeditation(let activeMed)   : activeMed.needsCloudUpdate        = false
//                case .Freund(let freund)                :
//                    freund.cloudNeedsUpdate           = false
//                    if freund.deletionUserID != nil
//                        {freund.delete()}
//                }
//                print("success") }}}
//
//    //MARK: initital Clean
//    func cleanMyActiveMeditations(){
//        guard let userID            = Meditierender.get()?.userID else {return}
//        let reference               = CKReference(recordID: CKRecordID(recordName: userID), action: .none)
//        let predicate               = NSPredicate(format: "creatorUserRecordID == %@", reference)
//        let query                   = CKQuery(recordType: CKRecord.MyRecordTypes.ActiveMeditation, predicate: predicate)
//        
//        MyCloudKit.database.perform(query, inZoneWith: nil){ (results, error) in
//            if (error != nil) {
//                print("Fehler cleanMyActiveMeditations: \(String(describing: error?.localizedDescription))")
//            }
//            else {
//                guard let results = results else {return}
//                for result in results{
//                    Singleton.sharedInstance.myCloudKit?.toDelete.append(result.recordID)
//                }
//            }
//        }
//    }
//    
//    //MARK: Subscriptions
////    static func subscriptionForNewActiveMeditations(){
////        let predicate = NSPredicate(format: "TRUEPREDICATE")
////
////        let subscription    = CKQuerySubscription(recordType: CKRecord.MyRecordTypes.ActiveMeditation, predicate: predicate, options: [.firesOnRecordUpdate,.firesOnRecordCreation,.firesOnRecordDeletion])
////
////        let notification                        = CKNotificationInfo()
////        notification.category                   = "ActiveMeditation"
////        notification.shouldSendContentAvailable = true
////        subscription.notificationInfo           = notification
////
////        database.save(subscription){ (saved, error) in
////            if error != nil { print(error!.localizedDescription) }
////            else { print("subscription created")  }
////        }
////    }
//    
//    static func subscriptionForFreunde(){
//        guard let meineID = Meditierender.get()?.userID else {return}
//        
//        func subscription(with predicate:NSPredicate){
//            let subscription    = CKQuerySubscription(recordType: CKRecord.MyRecordTypes.UserConnection, predicate: predicate, options: [.firesOnRecordUpdate,.firesOnRecordCreation])
//            
//            let notification                        = CKNotificationInfo()
//            notification.category                   = "Freunde"
//            notification.shouldSendContentAvailable = true
//            subscription.notificationInfo           = notification
//            
//            database.save(subscription){ (saved, error) in
//                if error != nil { print(error!.localizedDescription) }
//                else { print("subscription created")  }
//            }
//        }
//        let ich       = CKReference(recordID: CKRecordID(recordName: meineID), action: .none)
//        subscription(with: NSPredicate(format: "user2 = %@",ich))
//        subscription(with: NSPredicate(format: "user1 = %@",ich))
//    }
//    
//}

