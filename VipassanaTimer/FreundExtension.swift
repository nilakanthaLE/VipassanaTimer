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
import Firebase

extension Freund{
    static let context         = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    func confirmFriendShip(){
//        meinStatus          = FreundesStatus.granted
//        cloudNeedsUpdate    = true
//        Singleton.sharedInstance.myCloudKit?.updateNow()
//        NotificationCenter.default.post(Notification(name: Notification.Name.MyNames.updateFreundesUndFreundesAnfragenListe))
//    }
    
    
    static func get(withUserID userID:String?) -> Freund?{
        guard let userID = userID else {return nil}
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "freundID == %@", userID)
        if let freunde = (try? context.fetch(request)){
            return freunde.first
        }
        return nil
    }
    
    
    static func createOrUpdateFreund(with snapshot:DataSnapshot) -> Freund?{
        print("createOrUpdateFreund \(snapshot)")
        func setData(_ freund:Freund)->Freund{
            freund.freundID         = snapshot.key
            freund.freundStatus     = snapshot.valueAsDict?["statusUser"] as? Int16 ?? 0
            freund.meinStatus       = snapshot.valueAsDict?["statusSelf"] as? Int16 ?? 0
            freund.freundNick       = snapshot.valueAsDict?["freundNick"] as? String
            return freund
        }
        
        if let freund = get(withUserID: snapshot.key){ return setData(freund) }
        if let freund = NSEntityDescription.insertNewObject(forEntityName: "Freund", into: context) as? Freund {
            return setData(freund)
        }
        return nil
    }
    
    static func deleteFreund(with snapshot:DataSnapshot){ get(withUserID: snapshot.key)?.delete() }
    
    static func getAll() -> [Freund]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        if let freunde = (try? context.fetch(request)){
            return freunde
        }
        return [Freund]()
    }
    
    static func getMeineAnfragen() -> [[Freund]]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "meinStatus == %i && freundStatus <= 0",FreundesStatus.granted)
        
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
    func delete(){
        DispatchQueue.main.async {
            let context         = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(self)
            saveContext()
        }
    }

}

struct FreundesStatus {
    static let blocked:Int16        = -2
    static let rejected:Int16       = -1
    static let requested:Int16      = 0
    static let granted:Int16        = 1
}

enum FreundStatus{
    case blocked
    case rejected
    case requested
    case granted
    
    static func getStatus (_ status:Int16) -> FreundStatus?{
        switch status{
        case -2     : return .blocked
        case -1     : return .rejected
        case 0      : return .requested
        case 1      : return .granted
        default     : return nil
        }
    }
}
