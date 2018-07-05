//
//  Kurse.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 08.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift
import Firebase

class FirebaseKursProto{
    static let ref  = database.reference(withPath: "kursProtos")
    static func insertNew(publicKursProto:PublicKursProto){ ref.child(publicKursProto.kursTitle).setValue(publicKursProto.firebaseData) }
    
    //1 wert von publicKursProtos ist nil
    // für picker!
    static func getList(publicKursProtos:MutableProperty<[PublicKursProto?]>)
    {
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {return}
            var list =  snapshot.children.map{PublicKursProto(snapshot: $0 as? DataSnapshot)}
            list.insert(nil, at: 0)
            publicKursProtos.value = list
        }
    }
}


class KursData{
    //added Member
    let startTag:Date
    var lehrer:String?
    let title:String?
    let meditationSet:[KursMeditation]
    let kursTage:Int
    init(publicKursProto:PublicKursProto,startTag:Date,teacher:String?){
        self.title      = publicKursProto.kursNameD
        self.startTag   = startTag
        kursTage        = publicKursProto.days.count
        meditationSet   = KursData.setMeditationSet(publicKursProto: publicKursProto, startTag: startTag)
        lehrer          = teacher
    }
    static func setMeditationSet(publicKursProto:PublicKursProto,startTag:Date) -> [KursMeditation]{
        guard let startOfDay    = startTag.firstSecondOfDay?.timeIntervalSince1970 else {return [KursMeditation]()}
        let meditations         = publicKursProto.days.sorted{$0.tag < $1.tag}.map{$0.meditationen}
        
        for meditationsTag in meditations.enumerated() {
            let tagDate = TimeInterval(meditationsTag.offset * 24 * 3600) + startOfDay
            for meditation in meditationsTag.element.sorted(by: {$0.startDate.timeIntervalSince1970 < $1.startDate.timeIntervalSince1970}).enumerated(){
                meditation.element.startDate += tagDate
                meditation.element.meditationTitle = "\(publicKursProto.kursTitle) \(meditationsTag.offset) - \(meditation.offset)"
            }
        }
        return meditations.flatMap{$0}
    }
}

class PublicKursProto{
    var kursNameD:String
    var kursNameEng:String
    var kursTitle:String
    var days:[MeditationsTag]
    var firebaseData:[String:Any]{
        let array = days.sorted{$0.tag < $1.tag}.map{$0.firebaseData}
        let daysDict = array.reduce([String:Any]()){(ergebnis,value) -> [String:Any] in
            var ergebnis = ergebnis
            let _key = value.keys.first!
            ergebnis[_key] = value[_key]
            return ergebnis
        }
        return ["meditationen":daysDict,"kursNameD":kursNameD,"kursNameEng":kursNameEng]
    }
    
    init?(snapshot:DataSnapshot?){
        
        
        guard let value = snapshot?.value as? NSDictionary else {return nil}
        days            = snapshot?.childSnapshot(forPath: "meditationen").children.map{MeditationsTag(snapshot: $0 as? DataSnapshot)}.compactMap{$0} ?? [MeditationsTag]()
        kursNameD       = value["kursNameD"] as? String ?? "???"
        kursNameEng     = value["kursNameEng"] as? String ?? "???"
        kursTitle       = snapshot!.key
    }
    
    init(){
        kursNameD       = "10 Tage Kurs"
        kursNameEng     = "10 Day Course"
        kursTitle       = "10day"
        days            = [MeditationsTag]()
    }
}

//10-Tage
class tenDayKurs:PublicKursProto{
    override init(){
        super.init()
        days = [ AnkunftsTag(tag: 0),
                 AnapanaTag(tag: 1),
                 AnapanaTag(tag: 2),
                 AnapanaTag(tag: 3),
                 VipassanaEinfuehrungsTag(tag:4),
                 VipassanaTag(tag:5),
                 VipassanaTag(tag:6),
                 VipassanaTag(tag:7),
                 VipassanaTag(tag:8),
                 VipassanaTag(tag:9),
                 MettaEinfuehrungsTag(tag:10),
                 AbfahrtsTag(tag:11)
        ]
        kursNameD   = "10 Tage Kurs"
        kursNameEng = "10 Day Course"
        kursTitle   = "10day"
    }
    
}
//Satipatthana
class satipatthanaKurs:PublicKursProto{
    override init(){
        super.init()
        days = [ AnkunftsTag(tag: 0),
                 AnapanaTag(tag: 1),
                 AnapanaTag(tag: 2),
                 AnapanaTag(tag: 3),
                 VipassanaEinfuehrungsTag(tag:4),
                 VipassanaTag(tag:5),
                 VipassanaTag(tag:6),
                 VipassanaTag(tag:7),
                 MettaEinfuehrungsTag(tag:8),
                 AbfahrtsTag(tag: 9)
        ]
        kursNameD   = "Satipatthana Kurs"
        kursNameEng = "Satipatthana Course"
        kursTitle   = "Satipatthana"
    }
}



class KursMeditation:MeditationNewVersion{
    var _startDate:TimeInterval         { return startDate.timeIntervalOfDay }
    var _endeDate:TimeInterval          { return _startDate + gesamtDauer }
    
    
    var nummer:Int  = 0
    
    var firebaseData:[String:Any]{
        
        
        return["meditation\(nummer)": [
            "start"                         : _startDate,
            "gesamtDauer"                   : gesamtDauer,
            "anapanaDauer"                  : anapanaDauer,
            "mettaDauer"                    : mettaDauer,
            "mettaOpenEnd"                  : mettaEndlos,
            "meditationTitle"               : meditationTitle ?? "...",
            "endeDate"                      : _endeDate,
            "nummer"                        : nummer
        ]]
    }
    
    static func start(string:String) -> TimeInterval{
        let timeValues = string.split(separator: Character(":")).map{TimeInterval($0)}.compactMap{$0}
        print(Date(timeIntervalSince1970: timeValues[0] * 60 * 60 + timeValues[1] * 60))
        return timeValues[0] * 60 * 60 + timeValues[1] * 60
    }
    init(gesamtDauer: TimeInterval, startString: String, nummer:Int){
        super.init(gesamtDauer: gesamtDauer, start: Date(timeIntervalSince1970:KursMeditation.start(string: startString)) ,anapana:0 , metta:0, mettaEndlos:false)
        self.nummer = nummer
    }
    
    init?(snapshot:DataSnapshot?){
        guard let value = snapshot?.value as? NSDictionary else {return nil}
        super.init(gesamtDauer: 2, start: Date())
        startDate       = Date(timeIntervalSince1970: ((value["start"] as? TimeInterval) ?? 0))
        gesamtDauer     = (value["gesamtDauer"] as? TimeInterval) ?? 0
        anapanaDauer    = (value["anapanaDauer"] as? TimeInterval) ?? 0
        mettaDauer      = (value["mettaDauer"] as? TimeInterval) ?? 0
        mettaEndlos     = (value["mettaOpenEnd"] as? Bool) ?? false
        meditationTitle = value["meditationTitle"] as? String
        endeDate        = Date(timeIntervalSince1970: ((value["endeDate"] as? TimeInterval) ?? 0))
        nummer          = value["nummer"] as? Int ?? 0
    }
    
}



class MeditationsTag{
    var tag:Int = 0
    var meditationen:[KursMeditation]
    init(tag:Int){
        self.tag = tag
        meditationen = [KursMeditation]()
    }
    
    var _firebaseData:[KursMeditation]{
        return meditationen
    }
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
    
    init?(snapshot:DataSnapshot?){
        guard let key = snapshot?.key else {return nil}
        tag = Int(key.dropFirst(3)) ?? 0
        meditationen = snapshot?.children.map{KursMeditation(snapshot: $0 as? DataSnapshot)}.compactMap{$0} ?? [KursMeditation]() }
}

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

