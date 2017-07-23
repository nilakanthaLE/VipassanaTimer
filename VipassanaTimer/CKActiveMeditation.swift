////
////  CKActiveMeditation.swift
////  VipassanaTimer
////
////  Created by Matthias Pochmann on 23.03.17.
////  Copyright © 2017 Matthias Pochmann. All rights reserved.
////
//
//import Foundation
//import CloudKit
//
//class CKActiveMeditation:Hashable{
//    var hashValue: Int{
//        return "\(meditationRef),\(start),\(gesamtDauer),\(mettaOpenEnd),\(String(describing: userID)),\(String(describing: meditierenderSpitzname)),\(String(describing: durchSchnittProTag)),\(String(describing: gesamtDauerStatistik)),\(String(describing: kursTage)),\(ende),\(spitznameString),\(isActive),\(needsCloudUpdate)".hash
//    }
//    static func == (lhs: CKActiveMeditation, rhs: CKActiveMeditation) -> Bool { return lhs.hashValue == rhs.hashValue }
//    
//    
//    var meditationRef:CKReference
//    var start:Date
//    var gesamtDauer:TimeInterval
//    var mettaOpenEnd:Bool
//    var userID:CKRecordID?
//    var meditierenderSpitzname:String?
//    var durchSchnittProTag:String?
//    var gesamtDauerStatistik:String?
//    var kursTage:String?
//    
//    var ende:Date{ return start.addingTimeInterval(gesamtDauer) }
//    var spitznameString:String{
//        guard let nickName = meditierenderSpitzname, !nickName.isEmpty else {return "?"}
//        return nickName
//    }
//    
//    var isActive:Bool
//    var needsCloudUpdate = false
//    init(_ recordID:CKRecordID){
//        start           = Date()
//        meditationRef   = CKReference(recordID: recordID, action: .none)
//        gesamtDauer     = 0
//        mettaOpenEnd    = false
//        isActive        = false
//    }
//    
//    init?(_ record:CKRecord){
//        print ("CKActiveMeditation init record")
//        guard let _meditationRef        = record["meditationRef"]   as? CKReference,
//            let _start                  = record["start"]           as? Date,
//            let _gesamtDauer            = record["gesamtDauer"]     as? TimeInterval,
//            let _mettaOpenEnd           = record["mettaOpenEnd"]    as? Bool,
//            let _meditierenderSpitzname = record["meditierenderSpitzname"] as? String?,
//            let _durchSchnittProTag     = record["durchSchnittProTag"] as? String?,
//            let _gesamtDauerStatistik   = record["gesamtDauerStatistik"] as? String?,
//            let _kursTage               = record["kursTage"] as? String?
//            else {return nil}
//        
//        start                   = _start
//        gesamtDauer             = _gesamtDauer
//        mettaOpenEnd            = _mettaOpenEnd
//        userID                  = record.creatorUserRecordID
//        meditationRef           = _meditationRef
//        isActive                = true
//        meditierenderSpitzname  = _meditierenderSpitzname
//        durchSchnittProTag      = _durchSchnittProTag
//        gesamtDauerStatistik    = _gesamtDauerStatistik
//        kursTage                = _kursTage
//        _record             = record
//    }
//    init?(_ meditation:Meditation){
//        print ("CKActiveMeditation init meditation")
//        guard let _start = meditation.start,  let meditationID  = meditation.meditationsID else {return nil}
//        start                   = _start as Date
//        gesamtDauer             = meditation.gesamtDauer
//        mettaOpenEnd            = meditation.mettaOpenEnd
//        meditationRef           = CKReference(recordID: CKRecordID(recordName: meditationID), action: .none)
//        let meditierender       = Meditierender.get()
//        if let _userID = meditierender?.userID{
//            userID              = CKRecordID(recordName:_userID)
//        }
//        meditierenderSpitzname  = meditierender?.nickNameSichtbarkeit == 2 ? meditierender?.nickName : ""
//        
//        let statistics = StatistikUeberblickDaten()
//        
//        durchSchnittProTag      = meditierender?.statistikSichtbarkeit == 1 ? statistics.durchschnittTag.hhmmString : ""
//        gesamtDauerStatistik    = meditierender?.statistikSichtbarkeit == 1 ? statistics.gesamt.hhmmString : ""
//        kursTage                = meditierender?.statistikSichtbarkeit == 1 ? "\(statistics.kursTage)" : ""
//        
//        isActive                = true
//        needsCloudUpdate        = true
//    }
//    var record:CKRecord{
//        let __record = _record != nil ? _record! : CKRecord(recordType: CKRecord.MyRecordTypes.ActiveMeditation)
//        __record["meditationRef"]           = meditationRef
//        __record["start"]                   = start as CKRecordValue?
//        __record["gesamtDauer"]             = gesamtDauer as CKRecordValue?
//        __record["mettaOpenEnd"]            = mettaOpenEnd as CKRecordValue?
//        __record["meditierenderSpitzname"]  = meditierenderSpitzname as CKRecordValue?
//        __record["durchSchnittProTag"]      = durchSchnittProTag as CKRecordValue?
//        __record["gesamtDauerStatistik"]    = gesamtDauerStatistik as CKRecordValue?
//        __record["kursTage"]                = kursTage as CKRecordValue?
//        return __record
//    }
//    private var _record:CKRecord?
//}
//class CloudKitActiveMeditations{
//    private var activeMeditations = [CKActiveMeditation]()
//    init() {
//        let predicate   = NSPredicate(value:true)
//        let query       = CKQuery(recordType: CKRecord.MyRecordTypes.ActiveMeditation, predicate: predicate)
//        MyCloudKit.database.perform(query, inZoneWith: nil) { [unowned self](results, error) in
//            if (error != nil) { print("Fehler activeMeditations: \(String(describing: error))") }
//            else {
//                guard let results = results  else {return}
//                for result in results{
//                    if let activeMeditation = CKActiveMeditation(result) { self.addOrRemoveActiveMeditation(activeMeditation) }
//                }
//            }
//        }
//    }
//    
//    private func addOrRemoveActiveMeditation(_ activeMeditation:CKActiveMeditation){
//        //needed functions
//        func filterAndClean(_ activeMeditation:CKActiveMeditation){
//            let now                 = Date()
//            if now.isGreaterThanDate(dateToCompare: activeMeditation.ende) && !activeMeditation.mettaOpenEnd ||
//                now.isGreaterThanDate(dateToCompare: activeMeditation.ende + TimeInterval(30*60)) && activeMeditation.mettaOpenEnd ||
//                activeMeditation.userID?.recordName == "__defaultOwner__" {
//                
//                
//                activeMeditation.isActive           = false
//                activeMeditation.needsCloudUpdate   = true
//                MyCloudKit.createOrDelete(activeMeditation)
//                Singleton.sharedInstance.myCloudKit?.updateNow()
//            }
//        }
//        func postAddAndRemoveNotification(mit userInfo:[String:Any]){
//            DispatchQueue.main.async {
//                let notification = Notification(name: Notification.Name.MyNames.addOrRemoveActiveMeditationToList, object: nil, userInfo:userInfo)
//                NotificationCenter.default.post(notification)
//            }
//        }
//        func add(_ activeMeditation:CKActiveMeditation){
//            for meditation in activeMeditations{ // add, nur falls noch nicht in Liste
//                if meditation.meditationRef == activeMeditation.meditationRef { return }
//            }
//            activeMeditations.append(activeMeditation)
//            postAddAndRemoveNotification(mit:["meditation":activeMeditation, "add" : true,"position" : activeMeditations.count])
//        }
//        func remove(_ activeMeditation:CKActiveMeditation){
//            var i = 0
//            for meditation in activeMeditations{
//                if meditation.record.recordID.recordName == activeMeditation.meditationRef.recordID.recordName{
//                    activeMeditations.remove(at: i)
//                    postAddAndRemoveNotification(mit:["meditation":activeMeditation, "add" : false,"position" : i])
//                    return
//                }
//                i += 1
//            }
//        }
//        
//        //aufruf
//        filterAndClean(activeMeditation)
//        if activeMeditation.isActive        { add(activeMeditation) }
//        else                                { remove(activeMeditation) }
//    }
//    private func cleanMeditationList() {
//        for meditation in activeMeditations{
//            addOrRemoveActiveMeditation(meditation)
//        }
//    }
//    
//    //Notification from App Delegate ... Records in CloudKit (Changed/New)
//    func updateListOfActiveMeditations(recordID:CKRecordID,reason:CKQueryNotificationReason){
//        if reason == .recordDeleted {
//            self.addOrRemoveActiveMeditation(CKActiveMeditation(recordID))
//        }
//        
//        MyCloudKit.database.fetch(withRecordID: recordID) { [unowned self](record, error) in
//            if error != nil{ print(error!.localizedDescription) }
//            else{
//                guard let record = record,let activeMeditation = CKActiveMeditation(record) else {return}
//                switch reason{
//                case .recordCreated : activeMeditation.isActive = true
//                case .recordDeleted : break
//                case .recordUpdated : break
//                }
//                self.addOrRemoveActiveMeditation(activeMeditation)
//            }
//        }
//    }
//    //Timer
//    func update(){ cleanMeditationList() }
//    deinit { print("deinit CloudKitActiveMeditations") }
//}
//extension MyCloudKit{
//    //MARK: Active Meditations
//    static func createOrDelete(_ activeMeditation:CKActiveMeditation){
//        print("createOrDelete activeMeditation")
//        guard activeMeditation.needsCloudUpdate, let userID            = Meditierender.get()?.userID else {return}
//        let reference               = CKReference(recordID: CKRecordID(recordName: userID), action: .none)
//        let predicate               = NSPredicate(format: "creatorUserRecordID == %@", reference)
//        let query                   = CKQuery(recordType: CKRecord.MyRecordTypes.ActiveMeditation, predicate: predicate)
//        // holt alle eigenen aktiven Meditationen
//        
//        database.perform(query, inZoneWith: nil){ (results, error) in
//            if (error != nil) {
//                print("Fehler createOrDelete activeMeditation: \(String(describing: error?.localizedDescription))")
//            }
//            else {
//                guard let results = results else {return}
//                //lösche vorhandene Active Meditationen
//                for result in results{
//                    Singleton.sharedInstance.myCloudKit?.toDelete.append(result.recordID)
//                }
//                Singleton.sharedInstance.myCloudKit?.updateNow()
//                if activeMeditation.isActive{
//                    save(activeMeditation.record, coreDataObject: .ActiveMeditation(activeMeditation))
//                }
//            }
//        }
//    }
//}
//
//
//class CKActiveMeditationListUpdater{
//    //wird alle 15s neu gesetzt
//    private var currentList = [CKRecord]()
//    private var records = Set<CKRecord>(){
//        willSet{
//            print("records_new:\(newValue.count) records_old:\(currentList.count)")
//            var new:Set<CKRecord>{
//                var _new = Set<CKRecord>()
//                for _newValue in newValue{
//                    if (currentList.filter{$0.creatorUserRecordID == _newValue.creatorUserRecordID}).count == 0{
//                        _new.insert(_newValue)
//                    }
//                }
//                return _new
//            }
//            var toRemove:Set<CKRecord>{
//                var _toRemove = Set<CKRecord>()
//                for _record in currentList{
//                    if (newValue.filter{$0.creatorUserRecordID == _record.creatorUserRecordID}).count == 0{
//                        _toRemove.insert(_record)
//                    }
//                }
//                return _toRemove
//            }
//            
//            //update currentList
//            currentList.append(contentsOf: new)
//            for record in toRemove{ if let index = currentList.index(of: record){ currentList.remove(at:index) } }
//            
//            recordsToDelete = toRemove
//            newRecords      = new
//        }
//    }
//    private var newRecords:Set<CKRecord>?       { didSet{ newCKActiveMediations = activeMeditations(for: newRecords, isActive: true) } }
//    private var recordsToDelete:Set<CKRecord>?  { didSet{ ckActiveMeditationsToDelete = activeMeditations(for: recordsToDelete, isActive: false) } }
//    
//    
//    private func activeMeditations(for recordSet:Set<CKRecord>?,isActive:Bool) -> Set<CKActiveMeditation>?{
//        guard let recordSet = recordSet, recordSet.count > 0 else{return nil}
//        var ckActiveMeditations = Set<CKActiveMeditation>()
//        for record in recordSet{
//            if let activeMeditation = CKActiveMeditation(record){
//                activeMeditation.isActive = isActive
//                ckActiveMeditations.insert(activeMeditation)
//            }
//        }
//        return ckActiveMeditations
//    }
//    
//    
//    private func addOrDeleteListAction(_ list:Set<CKActiveMeditation>?){
//        guard let list = list else {return}
//        for ckAM in list{ addOrRemoveActiveMeditation(ckAM) }
//    }
//    private var newCKActiveMediations:Set<CKActiveMeditation>?      { didSet{addOrDeleteListAction(newCKActiveMediations)} }
//    private var ckActiveMeditationsToDelete:Set<CKActiveMeditation>?{ didSet{ addOrDeleteListAction(ckActiveMeditationsToDelete) } }
//    
//    
//    
//    //updateTimer
//    var isON = false{
//        didSet{
//            func reset(){ records.removeAll();newRecords = nil;recordsToDelete = nil;newCKActiveMediations = nil;ckActiveMeditationsToDelete = nil }
//            switch isON {
//            case true:
//                reset()
//                timer    = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(update), userInfo: nil, repeats: true)
//                timer.fire()
//            case false:
//                timer.invalidate()
//                reset()
//            }
//        }
//    }
//    private var timer = Timer()
//    private var lastUpdate:Date?
//    @objc private func update(){
//        print("\nupdateTimer ActiveMeditationListUpdater")
//        var predicate:NSPredicate
//        if lastUpdate == nil    { predicate   = NSPredicate(value:true) }
//        else                    { predicate   = NSPredicate(format: "modificationDate >= %@",lastUpdate! as CVarArg ) }
//        lastUpdate = Date()
//        
//        let query       = CKQuery(recordType: CKRecord.MyRecordTypes.ActiveMeditation, predicate: predicate)
//        MyCloudKit.database.perform(query, inZoneWith: nil) { [unowned self](results, error) in
//            if (error != nil) { print("Fehler activeMeditations: \(String(describing: error))") }
//            else {
//                guard let results = results  else {return}
//                var filteredResults:Set<CKRecord>{
//                    var ergebnis = Set<CKRecord>()
//                    let userIDs = results.map{$0.creatorUserRecordID}
//                    for userID in userIDs{
//                        if let toADD = (results.filter{$0.creatorUserRecordID == userID}).first{
//                            ergebnis.insert( toADD )
//                        }
//                    }
//                    return ergebnis
//                }
//                self.records = filteredResults//Set(results)
//            }
//        }
//    }
//    
//    private func addOrRemoveActiveMeditation(_ activeMeditation:CKActiveMeditation){
//        //functions
//        func filterAndClean(_ activeMeditation:CKActiveMeditation){
//            let now                 = Date()
//            if now.isGreaterThanDate(dateToCompare: activeMeditation.ende) && !activeMeditation.mettaOpenEnd ||
//                now.isGreaterThanDate(dateToCompare: activeMeditation.ende + TimeInterval(30*60)) && activeMeditation.mettaOpenEnd
//                || activeMeditation.userID?.recordName == "__defaultOwner__" {
//                activeMeditation.isActive           = false
//            }
//        }
//        func postAddAndRemoveNotification(mit userInfo:[String:Any]){
//            DispatchQueue.main.async {
//                let notification = Notification(name: Notification.Name.MyNames.addOrRemoveActiveMeditationToList, object: nil, userInfo:userInfo)
//                NotificationCenter.default.post(notification)
//            }
//        }
//        //aufruf
//        filterAndClean(activeMeditation)
//        postAddAndRemoveNotification(mit:["meditation":activeMeditation])
//    }
//}

