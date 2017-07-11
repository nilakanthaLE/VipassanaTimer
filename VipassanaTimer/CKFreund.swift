//
//  CKFreund.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 23.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CloudKit

class CKFreund {
    var user1:CKReference
    var user2:CKReference
    var statusUser1:Int16
    var statusUser2:Int16
    var recordID:CKRecordID
    var deletionUserID:String?
    
    
    
    func update(with freund:Freund){
        guard let freundID = freund.freundID,
            let meineID     = Meditierender.get()?.userID,
            let _recordID   = freund.recordID else {return}
        if freund.isMeineAnfrage{
            user1 = CKReference(recordID: CKRecordID(recordName: meineID), action: .none)
            user2 = CKReference(recordID: CKRecordID(recordName: freundID), action: .none)
            statusUser2 = freund.freundStatus
            statusUser1 = freund.meinStatus
            deletionUserID = freund.deletionUserID
        }else{
            user1 = CKReference(recordID: CKRecordID(recordName: freundID), action: .none)
            user2 = CKReference(recordID: CKRecordID(recordName: meineID), action: .none)
            statusUser1 = freund.freundStatus
            statusUser2 = freund.meinStatus
            deletionUserID    = freund.deletionUserID
        }
        recordID = CKRecordID(recordName:_recordID)
    }
    
    init?(_ freund:Freund) {
        guard let freundID = freund.freundID, let meineID = Meditierender.get()?.userID, let _recordID = freund.recordID else {return nil}
        if freund.isMeineAnfrage{
            user1 = CKReference(recordID: CKRecordID(recordName: meineID), action: .none)
            user2 = CKReference(recordID: CKRecordID(recordName: freundID), action: .none)
            statusUser2 = freund.freundStatus
            statusUser1 = freund.meinStatus
            deletionUserID    = freund.deletionUserID
        }else{
            user1 = CKReference(recordID: CKRecordID(recordName: freundID), action: .none)
            user2 = CKReference(recordID: CKRecordID(recordName: meineID), action: .none)
            statusUser1 = freund.freundStatus
            statusUser2 = freund.meinStatus
        }
        recordID = CKRecordID(recordName:_recordID)
    }
    init?(_ record:CKRecord){
        guard let _user1        = record["user1"] as? CKReference,
            let _user2          = record["user2"] as? CKReference,
            let _statusUser1    = record["statusUser1"] as? Int16,
            let _statusUser2    = record["statusUser2"] as? Int16 else {return nil}
        
        user1 = _user1
        user2 = _user2
        statusUser1 = _statusUser1
        statusUser2 = _statusUser2
        deletionUserID = record["deletionUserID"] as? String
        recordID    = record.recordID
        _record     = record
        
    }
    var record:CKRecord{
        let __record = _record != nil ? _record! : CKRecord(recordType: CKRecord.MyRecordTypes.UserConnection , recordID: recordID)
        __record["user1"]        = user1
        __record["user2"]        = user2
        __record["statusUser1"]  = statusUser1 as CKRecordValue?
        __record["statusUser2"]  = statusUser2 as CKRecordValue?
        __record["deletionUserID"] = deletionUserID as CKRecordValue?
        return __record
    }
    private var _record:CKRecord?
}

extension MyCloudKit{
    //MARK: Freunde
    static func fetchUser(_ name:String){
        let predicate               = NSPredicate(format: "nickName = %@", name)
        let query                   = CKQuery(recordType: CKRecord.MyRecordTypes.Meditierender, predicate: predicate)
        
        database.perform(query, inZoneWith: nil){ (results, error) in
            if (error != nil) {
                print("Fehler fetchUser: \(String(describing: error?.localizedDescription))")
            }
            else {
                var userInfo : [String:CKMeditierender]?
                if let result = results?.first, let ckMeditierender = CKMeditierender(result){
                    userInfo = ["ckMeditierender":ckMeditierender]
                }
                DispatchQueue.main.async {
                    let notification = Notification(name: Notification.Name.MyNames.gefundenerUser, object: nil, userInfo:userInfo)
                    NotificationCenter.default.post(notification)
                }
            }
        }
    }
    static func createOrUpdate(_ freund:Freund){
        let recordID    = CKRecordID(recordName: freund.recordID!)
        database.fetch(withRecordID: recordID) { (record, error) in
            if error != nil{
                print("createOrUpdate freund Fehler: \(String(describing: error?.localizedDescription))")
                guard let record          = CKFreund(freund)?.record else {return}
                save(record,coreDataObject: .Freund(freund))
            }else{
                guard let record = record, let ckFreund = CKFreund(record) else {return}
                ckFreund.update(with: freund)
                save(ckFreund.record,coreDataObject: .Freund(freund))
            }
        }
    }
    static func delete(_ freund:Freund){
        guard let recordID = freund.recordID else {return}
        Singleton.sharedInstance.myCloudKit?.toDelete.append(CKRecordID(recordName: recordID))
    }
    static func updateFreundeUndFreundesAnfragen(){
        guard let meineID = Meditierender.get()?.userID else {return}
        
        func query(with predicate:NSPredicate){
            let query       = CKQuery(recordType: CKRecord.MyRecordTypes.UserConnection, predicate: predicate)
            database.perform(query, inZoneWith: nil){ (results, error) in
                if (error != nil) { print("Fehler: \(String(describing: error?.localizedDescription))") }
                else {
                    guard let results = results else {return}
                    for result in results{
                        if let ckFreund = CKFreund(result){ _ = Freund.createOrUpdateFreund(with: ckFreund) }
                    }
                    if results.count > 0{
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(Notification(name: Notification.Name.MyNames.updateFreundesUndFreundesAnfragenListe))
                        }
                    }
                }
            }
        }
        let ich       = CKReference(recordID: CKRecordID(recordName: meineID), action: .none)
        query(with: NSPredicate(format: "user2 = %@",ich))
        query(with: NSPredicate(format: "user1 = %@",ich))
    }
    // Subscription ... From AppDelegate
    static func updateListOfFriends(recordID:CKRecordID,reason:CKQueryNotificationReason){
        MyCloudKit.database.fetch(withRecordID: recordID) {(record, error) in
            if error != nil{
                print(error!.localizedDescription)
            }else{
                guard let record = record,let ckFreund = CKFreund(record) else {return}
                _ = Freund.createOrUpdateFreund(with: ckFreund)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(Notification(name: Notification.Name.MyNames.updateFreundesUndFreundesAnfragenListe))
                }
            }
        }
    }
    static func updataFreundName(_ freund:Freund){
        guard let freundID = freund.freundID else {return}
        let ID = "M" + freundID
        let userRecordID = CKRecordID(recordName: ID)
        database.fetch(withRecordID: userRecordID) { (record, error) in
            if error != nil{ print(error!.localizedDescription) }
            else{
                guard let record = record else {return}
                guard let ckMeditierender   = CKMeditierender(record)  else {return}
                DispatchQueue.main.async {
                    freund.freundNick           = ckMeditierender.nickName
                    NotificationCenter.default.post(Notification(name: Notification.Name.MyNames.updateFreundesUndFreundesAnfragenListe))
                }
                
            }
        }
    }
}
