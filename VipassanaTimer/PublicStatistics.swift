//
//  PublicStatistics.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 17.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import Firebase

//✅
// über Sitzplatz -> öffentliches Profil einsehbare UserStatistiken
struct PublicStatistics{
    let durchSchnittProTag:String?
    let gesamtDauer:String?
    let kursTage:String?
    
    //MARK: init
    //von Firebase
    init?(snapshot:DataSnapshot,freundStatus:FreundStatus?){
        guard freundStatus == .granted , let value = snapshot.value as? NSDictionary,let statistikSichtbarkeit = value["statistikSichtbarkeit"] as? Int16, statistikSichtbarkeit == 1 else {return nil}
        durchSchnittProTag          = value["durchSchnittProTag"] as? String
        gesamtDauer                 = value["gesamtDauerStatistik"] as? String
        kursTage                    = value["kursTage"] as? String
    }
    //eigene
    init(){
        let statistics              = Statistics.get()
        durchSchnittProTag          = statistics.durchschnittTag.hhmm
        gesamtDauer                 = statistics.gesamtDauer.hhmm
        kursTage                    = "\(statistics.kursTage)"
    }
}
