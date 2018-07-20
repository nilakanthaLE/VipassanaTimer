//
//  KursProtoMeditationsTage.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Firebase

//BasisKlasse für Meditationstage
class MeditationsTag{
    var tag:Int = 0
    var meditationen:[KursMeditation]
    var firebaseData: [String:[String:Any]]{
        let array = meditationen.sorted{$0.nummer < $1.nummer}.map{$0.firebaseData}
        let dict = array.reduce([String:Any]()){(ergebnis,value) -> [String:Any] in
            var ergebnis = ergebnis
            let _key = value.keys.first!
            ergebnis[_key] = value[_key]
            return ergebnis
        }
        return ["tag\(tag)":dict]
    }
    
    init(tag:Int){
        self.tag = tag
        meditationen = [KursMeditation]()
    }
    init?(snapshot:DataSnapshot?){
        guard let key = snapshot?.key else {return nil}
        tag = Int(key.dropFirst(3)) ?? 0
        meditationen = snapshot?.children.map{KursMeditation(snapshot: $0 as? DataSnapshot)}.compactMap{$0} ?? [KursMeditation]() }
}


// verschiedene Typen von Tagen
// Ankunft, Abfahrt, Standard, VipassanaTag, MettaTag
class AnkunftsTag:MeditationsTag{
    override init(tag:Int) {
        super.init(tag: tag)
        meditationen = [KursMeditation(gesamtDauer: 3600, startString: "20:00", nummer: 1)]
    }
}
class AbfahrtsTag:MeditationsTag{
    override init(tag:Int) {
        super.init(tag:tag)
        meditationen = [KursMeditation(gesamtDauer: 1800, startString: "4:30", nummer: 1)]
        self.tag = tag
    }
}

class StandardKursTag:MeditationsTag{
    let zweiStunden:TimeInterval = 7200
    let eineStunde:TimeInterval  = 3600
    let andertHalbStunden:TimeInterval = 5400
    let dreiViertelStunde:TimeInterval   = 2700
    override init(tag:Int) {
        super.init(tag:tag)
        meditationen = [
            KursMeditation(gesamtDauer: zweiStunden, startString: "4:30", nummer:1),
            KursMeditation(gesamtDauer: eineStunde, startString:  "8:00", nummer:2),
            KursMeditation(gesamtDauer: zweiStunden, startString: "9:00", nummer:3),
            KursMeditation(gesamtDauer: andertHalbStunden, startString: "13:00", nummer:4),
            KursMeditation(gesamtDauer: eineStunde, startString: "14:30", nummer:5),
            KursMeditation(gesamtDauer: andertHalbStunden, startString: "15:30", nummer:6),
            KursMeditation(gesamtDauer: eineStunde,startString:  "18:00", nummer:7),
            KursMeditation(gesamtDauer: dreiViertelStunde, startString: "20:15", nummer:8)
        ]
    }
}

class AnapanaTag:StandardKursTag{
    override init(tag:Int) {
        super.init(tag:tag)
        for meditation in meditationen{
            meditation.anapanaDauer = meditation.gesamtDauer
            meditation.mettaDauer   = 0
        }
    }
}
class VipassanaTag:StandardKursTag{
    override init(tag:Int) {
        super.init(tag:tag)
        for meditation in meditationen{
            meditation.anapanaDauer = 0
            meditation.mettaDauer   = 0
        }
    }
}
class MettaTag:VipassanaTag{
    override init(tag:Int) {
        super.init(tag:tag)
        for meditation in meditationen{
            meditation.mettaDauer   = 10 * 60
        }
    }
}
class VipassanaEinfuehrungsTag:AnapanaTag{
    override init(tag:Int) {
        super.init(tag:tag)
        for meditation in meditationen.filter({$0.nummer > 3}){
            meditation.anapanaDauer = 0
            meditation.mettaDauer   = 0
        }
    }
}
class MettaEinfuehrungsTag:VipassanaTag{
    override init(tag:Int) {
        super.init(tag:tag)
        for meditation in meditationen.filter({$0.nummer > 3}){
            meditation.anapanaDauer = 0
            meditation.mettaDauer   = 10 * 60
        }
    }
}
