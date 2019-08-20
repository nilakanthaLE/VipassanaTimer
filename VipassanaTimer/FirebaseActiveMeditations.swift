//
//  FirebaseActiveMeditations.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Firebase

//✅
//Methoden für Einträge von ActiveMeditations in Firebase
// neu erstellen, updaten, löschen
class FirActiveMeditations{
    
    //activMeditation erstellen
    static func createActiveMeditation(meditation:PublicMeditation?) {
        guard let userID    = AppUser.get()?.firebaseID , let meditation = meditation  else {return}
        let firebaseData    = meditation.firebasePublicMeditation
        let ref             = database.reference(withPath: "activeMeditations")
        ref.child(userID).setValue(firebaseData)
    }
    
    //eigene activMeditation löschen
    static func deleteActiveMeditation(){
        print("deleteMyOwnActiveMeditation")
        guard let userID    = AppUser.get()?.firebaseID   else {return}
        let ref             = database.reference(withPath: "activeMeditations").child(userID)
        ref.removeValue()
    }
    
    //aufräumen
    // löscht alle aktiven Meditationen, die bereits länger als 5h existieren
    
    /*
     erledigt  eine FirebaseFunction
     static func cleaningActiveMeditations(){
     print("cleaningActiveMeditations ....")
     let timestamp   = String(Date().timeIntervalSinceReferenceDate - 5*60*60)
     let ref         = database.reference(withPath: "activeMeditations")
     ref.queryOrdered(byChild: "start").queryEnding(atValue: timestamp ).observeSingleEvent(of: .value){ snapshot in
     guard let ids = (snapshot.valueAsDict?.allKeys as? Array<String> ) else {return}
     for id in ids   { ref.child(id).removeValue() }
     }
     }
     */
}
