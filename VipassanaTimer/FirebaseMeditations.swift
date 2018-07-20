//
//  FirebaseMeditations.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import Firebase

//✅
//Methoden für Einträge von Meditationen in Firebase
// neu erstellen, updaten, löschen
// Observer für Änderungen starten
class FirMeditations{
    private init(){}
    
    //FirebaseRef
    static private var ref:DatabaseReference?{
        guard let appUserID     = AppUser.get()?.firebaseID   else {return nil}
        return database.reference(withPath: "meditations").child(appUserID)
    }
    
    //Einträge in Firebase erzeugen, updaten, "löschen"
    static func update(meditation:Meditation?){
        guard let meditation    = meditation, let medID = meditation.meditationsID else {return}
        meditation.inFirebase   = false
        ref?.child(medID).setValue(meditation.firebaseData) { (error, ref) in if error == nil {meditation.inFirebase = true} }
    }
    static func deleteMeditation(meditation:Meditation?){
        guard let medID = meditation?.meditationsID  else {return}
        let ref                 = FirMeditations.ref?.child(medID)
        ref?.setValue( deleteDict )
    }
    
    //sync für alles seit letztem SyncDate
    // Observer für alles, was nach AppStart geschieht
    static func sync(){
        ref?.removeAllObservers()
        ref?.queryOrdered(byChild: "lastSync").queryStarting(atValue: appSync).observe(.childAdded)     { (snapshot) in createOrUpdate(snap: snapshot) }
        ref?.queryOrdered(byChild: "lastSync").queryStarting(atValue: appSync).observe(.childChanged)   { (snapshot) in createOrUpdate(snap: snapshot) }
    }
    
    //helper
    static private var appSync:TimeInterval{ return AppConfig.get()?.firMedLastSync?.timeIntervalSinceReferenceDate ?? Date(timeIntervalSince1970: 0).timeIntervalSinceReferenceDate }
    static private func createOrUpdate(snap:DataSnapshot?){
        Meditation.createOrUpdateMeditation(withChild: snap)
        let lastSync    = snap?.valueAsDict?["lastSync"] as? TimeInterval ?? 0
        if lastSync > appSync{ AppConfig.get()?.firMedLastSync = Date(timeIntervalSinceReferenceDate: lastSync) }
    }
}
