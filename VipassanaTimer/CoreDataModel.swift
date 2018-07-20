//
//  CoreDataModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 29.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation

//✅
//CoreDataModel
// neue Meditation starten
// Meditation beenden
// Pausen eintragen
class CoreDataModel{
    private var myActiveMeditation:Meditation?
    
    func updateMyMeditation(myMeditation:PublicMeditation?){
        guard let myMeditation = myMeditation else {
            
            if let myActiveMeditation = myActiveMeditation{
                //Meditation wurde beendet
                myActiveMeditation.beendet(Date())
                
                //Firebase (auslagern --> FirebaseModel)
                FirMeditations.update(meditation: myActiveMeditation)
                saveContext()
                FirActiveMeditations.deleteActiveMeditation()
            }
            myActiveMeditation = nil
            return
        }
        //neue Meditation wurde gestartet
        myActiveMeditation      = Meditation.start(myMeditation: myMeditation)
        
        
        //Firebase (auslagern --> FirebaseModel)
        FirMeditations.update(meditation: myActiveMeditation)
        FirActiveMeditations.createActiveMeditation(meditation: myMeditation)
        saveContext()
    }
    
    func addPause(start:Date?,ende:Date?){
        guard let start = start, let ende = ende else { return }
        myActiveMeditation?.addPause(start: start, ende: ende)
    }
    
}
