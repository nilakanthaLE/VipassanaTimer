////
////  CKMeditierender.swift
////  VipassanaTimer
////
////  Created by Matthias Pochmann on 23.03.17.
////  Copyright © 2017 Matthias Pochmann. All rights reserved.
////
//
//import Foundation
//import CloudKit
//
//class CKMeditierender{
//    var userRef:CKReference
//    var nickName:String?
//    var recordID:CKRecordID
//    var statisticVisibility:Int16
//    
//    init?(_ meditierender:Meditierender) {
//        guard let userID =  meditierender.userID else {return nil}
//        userRef     = CKReference(recordID: CKRecordID(recordName: userID), action: .none)
//        nickName    = meditierender.nickName
//        let ID      = "M" + userID
//        recordID    = CKRecordID(recordName:ID)
//        statisticVisibility = meditierender.statistikSichtbarkeit
//    }
//    init?(_ record:CKRecord){
//        guard let _userRef = record["userRef"] as? CKReference,
//            let _nickName        = record["nickName"] as? String? else {return nil}
//        userRef     = _userRef
//        nickName    = _nickName
//        _record     = record
//        recordID    = record.recordID
//        statisticVisibility = record["statisticVisibility"] as? Int16 ?? 0
//    }
//    var record:CKRecord{
//        
//        let __record = _record != nil ? _record! : CKRecord(recordType: CKRecord.MyRecordTypes.Meditierender, recordID: recordID)
//        __record["userRef"]     = userRef
//        __record["nickName"]    = nickName as CKRecordValue?
//        __record["statisticVisibility"] = statisticVisibility as CKRecordValue?
//        
//        print("record: \(__record)  ...statisticVisibility: \(statisticVisibility)")
//        return __record
//    }
//    var _record:CKRecord?
//    func update(with meditierender:Meditierender){
//        nickName    = meditierender.nickName
//        statisticVisibility = meditierender.statistikSichtbarkeit
//    }
//}
////extension MyCloudKit{
//    //MARK: Meditierender
//    static func createOrUpdate(_ meditierender:Meditierender){
//        func createOrUpdateCKMeditierender(create:Bool){
//            let ID = "M" + meditierender.userID!
//            let userRecordID = CKRecordID(recordName: ID)
//            database.fetch(withRecordID: userRecordID) { (record, error) in
//                if error != nil{
//                    print(error!.localizedDescription)
//                    guard let ckMeditierender = CKMeditierender(meditierender)  else {return}
//                    save(ckMeditierender.record,coreDataObject: .Meditierender(meditierender))
//                }
//                else{
//                    guard let record = record,
//                        let ckMeditierender   = CKMeditierender(record) else {return}
//                    
//                    if create{ meditierender.nickName = ckMeditierender.nickName }
//                    else{
//                        ckMeditierender.update(with: meditierender)
//                        save( ckMeditierender.record, coreDataObject: .Meditierender(meditierender))
//                    }
//                }
//            }
//        }
//        
//        if meditierender.userID == nil{
//            let container = CKContainer.default()
//            container.fetchUserRecordID { (userRecordID, error) in
//                
//                if error != nil{print("fetchUserRecordID \(error!.localizedDescription)")}
//                else{
//                    guard let userRecordID  = userRecordID else {return}
//                    meditierender.userID    = userRecordID.recordName
//                    createOrUpdateCKMeditierender(create: true)
//                    MyCloudKit.subscriptionForFreunde()
//                }
//            }
//        }
//        else{createOrUpdateCKMeditierender(create: false)}
//    }
//}

