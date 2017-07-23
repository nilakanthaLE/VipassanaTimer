//
//  CKMeditation.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 23.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CloudKit

//class CKMeditation{
//    var start:Date
//    var gesamtDauer:TimeInterval
//    var recordID:CKRecordID
//    var mettaOpenEnd:Bool
//    var userID:CKRecordID?
//    var ende:Date{ return start.addingTimeInterval(gesamtDauer) }
//    
//    func update(with meditation:Meditation){
//        guard let _start = meditation.start else {return}
//        start               = _start as Date
//        gesamtDauer         = meditation.gesamtDauer
//        mettaOpenEnd        = meditation.mettaOpenEnd
//        userID              = nil
//        recordID            = CKRecordID(recordName: meditation.meditationsID!)
//    }
//    init?(_ record:CKRecord){
//        guard let _start = record["start"] as? Date,
//            let _gesamtDauer         = record["gesamtDauer"] as? TimeInterval,
//            let _mettaOpenEnd        = record["mettaOpenEnd"] as? Bool else {return nil}
//        
//        start               = _start
//        gesamtDauer         = _gesamtDauer
//        mettaOpenEnd        = _mettaOpenEnd
//        userID              = record.creatorUserRecordID
//        recordID            = record.recordID
//        _record             = record
//    }
//    init?(_ meditation:Meditation) {
//        guard let _start = meditation.start else {return nil}
//        start               = _start as Date
//        gesamtDauer         = meditation.gesamtDauer
//        mettaOpenEnd        = meditation.mettaOpenEnd
//        userID              = nil
//        recordID            = CKRecordID(recordName: meditation.meditationsID!)
//    }
//    var record:CKRecord{
//        let __record = _record != nil ? _record! : CKRecord(recordType: "Meditation", recordID: recordID)
//        __record["start"]               = start as CKRecordValue?
//        __record["gesamtDauer"]         = gesamtDauer as CKRecordValue?
//        __record["mettaOpenEnd"]        = mettaOpenEnd as CKRecordValue?
//        return __record
//    }
//    private var _record:CKRecord?
//}
//
//extension MyCloudKit{
//    
//    //MARK: Meditation
//    static func createOrUpdate(_ meditation:Meditation){
//        let recordID    = CKRecordID(recordName: meditation.meditationsID!)
//        database.fetch(withRecordID: recordID) { (record, error) in
//            if error != nil{
//                if (error as? CKError) != nil{
//                    
//                }
//                print("createOrUpdate meditation Fehler: \(String(describing: error?.localizedDescription))")
//                guard let record          = CKMeditation(meditation)?.record else {return}
//                save(record,coreDataObject: .Meditation(meditation))
//            }else{
//                guard let record = record, let ckMeditation = CKMeditation(record) else {return}
//                
//                ckMeditation.update(with: meditation)
//                save(ckMeditation.record,coreDataObject: .Meditation(meditation))
//            }
//        }
//    }
//}

