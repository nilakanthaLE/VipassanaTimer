//
//  FreundExtension.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CloudKit

extension Freund{
    static let context         = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    func confirmFriendShip(){
        meinStatus          = FreundesStatus.granted
        cloudNeedsUpdate    = true
        Singleton.sharedInstance.myCloudKit?.updateNow()
        NotificationCenter.default.post(Notification(name: Notification.Name.MyNames.updateFreundesUndFreundesAnfragenListe))
    }
    static func askForFriendShip(with ckMeditierender:CKMeditierender) -> Freund?{
        guard let _meineID  = Meditierender.get()?.userID else {return nil}
        
        func setData(_ freund:Freund)->Freund{
            freund.freundID             = ckMeditierender.userRef.recordID.recordName
            freund.freundNick           = ckMeditierender.nickName
            freund.freundStatus         = FreundesStatus.requested
            freund.meinStatus           = FreundesStatus.granted
            freund.isMeineAnfrage       = true
            freund.cloudNeedsUpdate     = true
            return freund
        }
        
        if let freund = get(ckMeditierender){ return setData(freund)}
        if let freund = NSEntityDescription.insertNewObject(forEntityName: "Freund", into: context) as? Freund
        {
            freund.recordID             = UUID().uuidString
            return setData(freund)
        }
        
        return nil
    }
    static func createOrUpdateFreund(with ckFreund:CKFreund) -> Freund?{
        guard let _meineID  = Meditierender.get()?.userID else {return nil}
        func setData(_ freund:Freund)->Freund{
            
            freund.isMeineAnfrage       = ckFreund.user1.recordID.recordName == _meineID
            if freund.isMeineAnfrage{
                freund.freundID             = ckFreund.user2.recordID.recordName
                freund.freundStatus         = ckFreund.statusUser2
                freund.meinStatus           = ckFreund.statusUser1
                
            }else{
                freund.freundID             = ckFreund.user1.recordID.recordName
                freund.freundStatus         = ckFreund.statusUser1
                freund.meinStatus           = ckFreund.statusUser2
            }
            
            MyCloudKit.updataFreundName(freund)
            return freund
        }
        
        //zu löschende
        if ckFreund.deletionUserID == _meineID{
            if let freund =  get(ckFreund) { freund.delete() }
            Singleton.sharedInstance.myCloudKit?.toDelete.append(ckFreund.recordID)
            return nil
        }

        
        //Standardfälle
        if let freund = get(ckFreund){
            return setData(freund)
        }
        if ckFreund.deletionUserID == nil, let freund = NSEntityDescription.insertNewObject(forEntityName: "Freund", into: context) as? Freund
        {
            freund.recordID             = ckFreund.recordID.recordName
            return setData(freund)
        }
        
        return nil
    }
    static func get(_ ckFreund:CKFreund) -> Freund?{
        guard let _meineID  = Meditierender.get()?.userID else {return nil}
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        let freundID            = ckFreund.user1.recordID.recordName == _meineID ? ckFreund.user2.recordID.recordName : ckFreund.user1.recordID.recordName
        request.predicate       = NSPredicate(format: "freundID == %@", freundID)
        if let freunde = (try? context.fetch(request)){
            return freunde.first
        }
        return nil
    }
    
    static func get(_ ckMeditierender:CKMeditierender) -> Freund?{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "freundID == %@", ckMeditierender.userRef.recordID.recordName)
        if let freunde = (try? context.fetch(request)){
            return freunde.first
        }
        return nil
    }
    class func getNeedCloudUpdate() -> [Freund]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "cloudNeedsUpdate == true")
        if let freunde = (try? context.fetch(request)){
            return freunde
        }
        return [Freund]()
    }
    static func getAll() -> [Freund]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        if let freunde = (try? context.fetch(request)){
            return freunde
        }
        return [Freund]()
    }
    static func getMeineAnfragen() -> [[Freund]]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "meinStatus == %i && freundStatus <= 0 && deletionUserID = nil",FreundesStatus.granted)
        
        if let freunde = (try? context.fetch(request)){
            
            var list = [[Freund](),[Freund]()]
            for freund in freunde{
                let section = freund.freundStatus  == 0 ? 0 : 1
                list[section].append(freund)
            }
            return list
        }
        return [[Freund]]()
    }
    static func getFreunde() -> [Freund]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "meinStatus == %i && freundStatus == %i",FreundesStatus.granted, FreundesStatus.granted)
        
        if let freunde = (try? context.fetch(request)){
            return freunde
        }
        return [Freund]()
    }
    static func getFreundesAnfragen() -> [Freund]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "meinStatus == %i && freundStatus == %i",FreundesStatus.requested, FreundesStatus.granted)
        
        if let freunde = (try? context.fetch(request)){
            return freunde
        }
        return [Freund]()
    }
    static func getZurueckgewieseneAnfragen() -> [Freund]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "meinStatus < 0 && freundStatus == %i",FreundesStatus.granted)
        
        if let freunde = (try? context.fetch(request)){
            return freunde
        }
        return [Freund]()
    }
    static func getDeletionNeeded() -> [Freund]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "deletionUserID != nil")
        
        if let freunde = (try? context.fetch(request)){
            return freunde
        }
        return [Freund]()
    }
    func deletionNeeded(){
        deletionUserID    = freundID
        Singleton.sharedInstance.myCloudKit?.updateNow()
    }
    func delete(){
        DispatchQueue.main.async {
            let context         = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(self)
        }
        
    }
    static func isUserFriend(_ recordID:CKRecordID?) -> Bool{
        guard let recordID = recordID else {return false}
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "freundID == %@ && meinStatus == 1 && freundStatus = 1",recordID.recordName)
        

        if let fetchErgebnis = try? context.fetch(request),fetchErgebnis.count > 0 {
            return true
        }
        return false
    }
}

struct FreundesStatus {
    static let blocked:Int16        = -2
    static let rejected:Int16       = -1
    static let requested:Int16      = 0
    static let granted:Int16        = 1
}
