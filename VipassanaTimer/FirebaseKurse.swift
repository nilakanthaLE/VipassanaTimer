//
//  FirebaseKurse.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Firebase

//✅
//Methoden für Einträge von Kursen in Firebase
// neu erstellen, updaten, löschen
// Observer für Änderungen starten
class FirKurse{
    private init(){}
    
    //FirebaseRef
    private static var ref:DatabaseReference? {
        guard let appUserID     = AppUser.get()?.firebaseID   else {return nil}
        return database.reference(withPath: "kurse").child(appUserID)
    }
    
    //Einträge in Firebase erzeugen, updaten, "löschen"
    static func update(kurs:Kurs?){
        guard let kurs  = kurs, let kursID = kurs.kursID else {return}
        kurs.inFirebase = false
        let ref         = FirKurse.ref?.child(kursID)
        ref?.setValue(kurs.firebaseData) { (error, ref) in if error == nil {kurs.inFirebase = true} }
        updateMeditations(kurs: kurs)
    }
    static func deleteKurs(kurs:Kurs){
        guard let kursID    = kurs.kursID  else {return}
        let ref             = FirKurse.ref?.child(kursID)
        ref?.setValue( deleteDict )
        deleteMeditations(kurs: kurs)
    }
    
    //sync für alles seit letztem SyncDate
    //  Observer für alles, was nach AppStart geschieht
    static func sync(){
        ref?.removeAllObservers()
        ref?.queryOrdered(byChild: "lastSync").queryStarting(atValue: appSync).observe(.childAdded)     { (snapshot) in createOrUpdate(snapshot: snapshot) }
        ref?.queryOrdered(byChild: "lastSync").queryStarting(atValue: appSync).observe(.childChanged)   { (snapshot) in createOrUpdate(snapshot: snapshot) }
    }
    
    //helper
    static private var appSync:TimeInterval                 { return AppConfig.get()?.firMedLastSync?.timeIntervalSinceReferenceDate ?? Date(timeIntervalSince1970: 0).timeIntervalSinceReferenceDate }
    static private func updateMeditations(kurs:Kurs)        { for meditation in kurs.meditations as? Set<Meditation> ?? Set<Meditation>() { FirMeditations.update(meditation: meditation) }  }
    static private func deleteMeditations(kurs:Kurs)        { for meditation in kurs.meditations as? Set<Meditation> ?? Set<Meditation>() { FirMeditations.deleteMeditation(meditation: meditation) } }
    static private func createOrUpdate(snapshot:DataSnapshot?){
        Kurs.createOrUpdate(withChild: snapshot)
        let lastSync = snapshot?.valueAsDict?["lastSync"] as? TimeInterval ?? 0
        if lastSync > appSync       { AppConfig.get()?.firKursLastSync = Date(timeIntervalSinceReferenceDate: lastSync) }
    }
}
