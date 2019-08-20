//
//  FirebaseUser.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Firebase
import ReactiveSwift

//✅
//Methoden für Einträge von User in Firebase
// neu erstellen, updaten, löschen
// Observer für Änderungen starten
// User suchen
class FirUser{
    private init(){}
    static let userRef = database.reference(withPath: "users")
    
    //User Eintrag in Firebase aktualisieren
    static func updateUserEintrag() {
        guard let appUser = AppUser.get(), let userID    = AppUser.get()?.firebaseID  else {return}
        userRef.child(userID).setValue(appUser.firebaseData)
        
        //erstellt neue Usereinträge (mit uid als key)
        // notwendig für FirebaseRules (Security)
        usersNewVersionUpdate()
    }
    //userNewVersion
    // erstellt Eintrag in usersNewVersion
    // egal, ob Spitzname oder nicht
    static func usersNewVersionUpdate(){
        guard let authUID = Auth.auth().currentUser?.uid else {return}
        database.reference(withPath: "usersNewVersion").child(authUID).setValue(true)
    }
    
    //User in Firebase suchen
    static func getUser(byNickname nickname:String?, userSuchErgebnis:MutableProperty<UserSuchErgebnis>? = nil, ergebnisSnapshot:MutableProperty<NSDictionary?>? = nil){
        guard let nickname = nickname else {return}
        userRef.queryOrdered(byChild: "querySpitzname").queryEqual(toValue: nickname.lowercased()).observeSingleEvent(of: .value) { (snapshot) in
            let filteredSnapshot = filterUserSnapshots(snapshot: snapshot)
            userSuchErgebnis?.value = filteredSnapshot == nil ? UserSuchErgebnis.nichtGefunden : UserSuchErgebnis.gefunden
            ergebnisSnapshot?.value = filteredSnapshot
        }
    }
    
    //Observer starten
    static func observeMyUserData(){
        guard let userID        = AppUser.get()?.firebaseID  else {return}
        let myUserRef           = userRef.child(userID)
        myUserRef.removeAllObservers()
        myUserRef.observe(.childAdded)      { updateMeditierender(snapshot: $0) }
        myUserRef.observe(.childChanged)    { updateMeditierender(snapshot: $0) }
    }
    
    
    //helper
    static private func updateMeditierender(snapshot:DataSnapshot){
        AppUser.get()?.userDatenInitialSync = true
        if snapshot.key == "spitzname", let value = snapshot.value as? String, Meditierender.get()?.nickName != value {
            Meditierender.get()?.nickName = value
            FirUserConnections.setMyNewNickName()
        }
        if snapshot.key == "spitzname_sichtbarkeit" {Meditierender.get()?.nickNameSichtbarkeit   = snapshot.value as? Int16 ?? 0}
        if snapshot.key == "statistik_sichtbarkeit" {Meditierender.get()?.statistikSichtbarkeit     = snapshot.value as? Int16 ?? 0}
        if snapshot.key == "statisticStart" {
            guard let value   = snapshot.value as? TimeInterval else {return}
            let date    = value == 0 ? nil : Date (timeIntervalSinceReferenceDate: value)
            AppConfig.get()?.startDatumStatistik =  date
        }
        saveContext()
    }
    static private func filterUserSnapshots(snapshot:DataSnapshot) -> NSDictionary?{
        //filter self
        if snapshot.firstKey == AppUser.get()?.firebaseID  {return nil}
        //filter Freunde
        for freund in Freund.getAll() { if freund.freundID == snapshot.firstValue?["ID"] as? String { return nil } }
        return snapshot.firstValue
    }
}
