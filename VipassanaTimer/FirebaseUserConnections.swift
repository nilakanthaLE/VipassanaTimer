//
//  FirebaseUserConnections.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import Firebase
import ReactiveSwift

//für updateEreignisse
// falls User gerade FreundesAnfragen betrachtet
let freundEreignis              = MutableProperty<Void>(Void())

//✅
//Methoden für Einträge von UserConnections (Freundschaftem) in Firebase
// neu erstellen, updaten, löschen
// Observer für Änderungen starten
class FirUserConnections{
    private init(){}
    static private let basisRef             = database.reference(withPath: "userConnections")
    static private var appUserID:String?    { return AppUser.get()?.firebaseID }
    
    // Observer starten
    static func setObserver(){
        guard let appUserID     = appUserID  else {return}
        let ref                 = basisRef.child(appUserID)
        ref.removeAllObservers()
        ref.observe(.childAdded)    { createOrUpdate(snapshot: $0) }
        ref.observe(.childChanged)  { createOrUpdate(snapshot: $0) }
        ref.observe(.childRemoved)  { deleteFreund(snapshot: $0) }
    }
    
    //Freundschaftsstatus in Firebase setzen/aktualisieren
    static func setFreundschaftsstatus(withUserID userID:String?,userStatus:Int16?,meinStatus:Int16?){
        guard let appUserID     = appUserID , let userID = userID  else {return}
        let ref1                = basisRef.child(appUserID).child(userID)       //mein Eintrag
        ref1.observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else { return }
            var update:[String:Any]{
                var _value = [String:Any]()
                if let userStatus = userStatus {_value["statusUser"] = userStatus}
                if let meinStatus = meinStatus {_value["statusSelf"] = meinStatus}
                return _value
            }
            ref1.updateChildValues(update)
        }
        let ref2                = basisRef.child(userID).child(appUserID)       //eintrag des Freundes
        ref2.observeSingleEvent(of: .value) { (snapshot) in
            guard snapshot.exists() else { return }
            var update:[String:Any]{
                var _value = [String:Any]()
                if let userStatus = userStatus {_value["statusSelf"] = userStatus}
                if let meinStatus = meinStatus {_value["statusUser"] = meinStatus}
                return _value
            }
            ref2.updateChildValues(update)
        }
    }
    
    //neue Freundschaftsanfrage erstellen
    static func createFreundesanfrage(withUserDict userDict:NSDictionary?){
        guard let userID    = userDict?["ID"] as? String,
            let appUserID   = appUserID,
            let freundNick  = userDict?["spitzname"],
            let userNick    = Meditierender.get()?.nickName   else {return}
        
        let userConnectionMe:[String:Any]       = [ userID:    [ "statusSelf":FreundStatus.granted.rawValue, "statusUser":FreundStatus.requested.rawValue, "freundNick": freundNick ] ]
        let userConnectionFreund:[String:Any]   = [ appUserID: [ "statusSelf":FreundStatus.requested.rawValue, "statusUser":FreundStatus.granted.rawValue, "freundNick": userNick ] ]
        
        basisRef.child(appUserID).updateChildValues(userConnectionMe)
        basisRef.child(userID).updateChildValues(userConnectionFreund)
    }
    
    //UserConnection in Firebase löschen
    static func deleteUserConnection(withUserID userID:String?){
        guard let appUserID     = AppUser.get()?.firebaseID , let userID = userID  else {return}
        basisRef.child(appUserID).child(userID).removeValue()   //mein Eintrag
        basisRef.child(userID).child(appUserID).removeValue()   //eintrag des Freundes
    }
    
    //meinen geänderten Nickname in FreundConnections übertragen
    static func setMyNewNickName(){  for freund in Freund.getAll(){ updateMyNickName(for: freund) } }
    
    //helper
    static func updateMyNickName(for freund:Freund){
        guard let appUserID = AppUser.get()?.firebaseID , let userID = freund.freundID , let meinNick = Meditierender.get()?.nickName  else {return}
        basisRef.child(userID).child(appUserID).updateChildValues([ "freundNick": meinNick ])
    }
    static private func createOrUpdate(snapshot:DataSnapshot){
        _ = Freund.createOrUpdateFreund(with: snapshot)
        freundEreignis.value    = Void()
    }
    static private func deleteFreund(snapshot:DataSnapshot){
        _ = Freund.deleteFreund(with: snapshot)
        freundEreignis.value    = Void()
    }
}
