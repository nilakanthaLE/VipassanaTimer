//
//  FreundExtension.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import CoreData
import Firebase

//✅
//Listen von Freunden und Freundesanfragen
extension Freund{
    //alle Freundesobjekte
    static func getAll() -> [Freund]{
        let request = NSFetchRequest<Freund>(entityName: "Freund")
        return (try? context.fetch(request)) ?? [Freund]()
    }
    //"meine" Anfragen
    static func getMeineAnfragen() -> [[Freund]]{
        let request         = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate   = NSPredicate(format: "meinStatus == %i && freundStatus <= 0",FreundStatus.granted.rawValue)
        let freunde         = (try? context.fetch(request)) ?? [Freund]()
        var list            = [[Freund](),[Freund]()]
        for freund in freunde{
            let section = freund.freundStatus  == 0 ? 0 : 1
            list[section].append(freund)
        }
        return list
    }
    //alle (tatsächlichen) Freunde
    static func getFreunde() -> [Freund]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "meinStatus == %i && freundStatus == %i",FreundStatus.granted.rawValue, FreundStatus.granted.rawValue)
        return (try? context.fetch(request)) ?? [Freund]()
    }
    //Anfragen von Usern an "mich"
    static func getFreundesAnfragen() -> [Freund]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "meinStatus == %i && freundStatus == %i",FreundStatus.requested.rawValue, FreundStatus.granted.rawValue)
        return (try? context.fetch(request)) ?? [Freund]()
    }
    //Anfragen von "mir" zurückgewiesen
    static func getZurueckgewieseneAnfragen() -> [Freund]{
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "meinStatus < 0 && freundStatus == %i",FreundStatus.granted.rawValue)
        return (try? context.fetch(request)) ?? [Freund]()
    }
}

//✅
//holen,erstellen,aktualisieren,löschen
extension Freund{
    //Freund mit ID holen
    static func get(withUserID userID:String?) -> Freund?{
        guard let userID = userID else {return nil}
        let request             = NSFetchRequest<Freund>(entityName: "Freund")
        request.predicate       = NSPredicate(format: "freundID == %@", userID)
        return (try? context.fetch(request))?.first
    }
    //einen bestehenden Freund aktualiseren oder neu erstellen (Firebase)
    static func createOrUpdateFreund(with snapshot:DataSnapshot) -> Freund?{
        let freund = get(withUserID: snapshot.key) ?? create()
        return setData(freund, snapshot: snapshot)
    }
    //löschen
    static func deleteFreund(with snapshot:DataSnapshot){ get(withUserID: snapshot.key)?.delete() }
    func delete(){
        DispatchQueue.main.async {
            context.delete(self)
            saveContext()
        }
    }
    //FreundStatus
    var status:FreundStatus?    { return FreundStatus.getStatus(freundStatus) }
    //helper
    private static func setData(_ freund:Freund?,snapshot:DataSnapshot)->Freund?{
        guard let freund = freund else {return nil}
        freund.freundID         = snapshot.key
        freund.freundStatus     = snapshot.valueAsDict?["statusUser"] as? Int16 ?? 0
        freund.meinStatus       = snapshot.valueAsDict?["statusSelf"] as? Int16 ?? 0
        freund.freundNick       = snapshot.valueAsDict?["freundNick"] as? String
        return freund
    }
    private static func create() -> Freund?{ return NSEntityDescription.insertNewObject(forEntityName: "Freund", into: context) as? Freund }
}

//✅
//MARK: enum FreundStatus
enum FreundStatus:Int16{
    case blocked    = -2
    case rejected   = -1
    case requested  = 0
    case granted    = 1
    
    static func getStatus (_ status:Int16?) -> FreundStatus?{
        guard let status = status else {return nil}
        switch status{
        case -2     : return .blocked
        case -1     : return .rejected
        case 0      : return .requested
        case 1      : return .granted
        default     : return nil
        }
    }
    
}
