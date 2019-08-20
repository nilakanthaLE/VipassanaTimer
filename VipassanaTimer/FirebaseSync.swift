//
//  FirebaseSync.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Firebase

//Dictionary für "gelöschte" Einträge
var deleteDict:NSDictionary{ return ["deleted":true,"lastSync":Date().timeIntervalSinceReferenceDate] }

//✅
//trägt Meditationen und Kurse nach
// startet Observer
class FirSync{
    static func sync(){
        //update/create fehlender Meditationen und Kurse in Firebase
        for meditation in Meditation.getNotInFirebase()     { FirMeditations.update(meditation: meditation) }
        for kurs in Kurs.getNotInFirebase()                 { FirKurse.update(kurs: kurs) }

        FirKurse.sync()
        FirMeditations.sync()
        FirUserConnections.setObserver()
        FirNotitification.setObserver()
        //FirActiveMeditations.cleaningActiveMeditations()
        FirActiveMeditations.deleteActiveMeditation()
    }
}
