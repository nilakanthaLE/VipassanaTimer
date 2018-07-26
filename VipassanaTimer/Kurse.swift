//
//  Kurse.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 08.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift
import Firebase

//✅
// realer Kurs mit startDatum
class KursData{
    let startTag:Date
    var lehrer:String?
    let title:String?
    let meditationSet:[KursMeditation]
    let kursTage:Int
    init(publicKursProto:PublicKursProto,startTag:Date,teacher:String?){
        self.title      = publicKursProto.localizedName
        self.startTag   = startTag
        kursTage        = publicKursProto.kursTage
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


//✅
//Meditation in einem Kurs
class KursMeditation:MeditationBasis{
    var nummer:Int
    var firebaseData:[String:Any]{
        return["meditation\(nummer)": [
            "start"                         : startDate.timeIntervalOfDay,
            "gesamtDauer"                   : gesamtDauer,
            "anapanaDauer"                  : anapanaDauer,
            "mettaDauer"                    : mettaDauer,
            "mettaOpenEnd"                  : mettaEndlos,
            "meditationTitle"               : meditationTitle ?? "...",
            "nummer"                        : nummer
        ]]
    }
    
    //init
    init(gesamtDauer: TimeInterval, startString: String, nummer:Int){
        self.nummer = nummer
        super.init(gesamtDauer: gesamtDauer, start: Date(timeIntervalSince1970:KursMeditation.start(string: startString)) ,anapana:0 , metta:0, mettaEndlos:false)
        
    }
    init?(snapshot:DataSnapshot?){
        guard let value = snapshot?.value as? NSDictionary else {return nil}
        nummer          = value["nummer"] as? Int ?? 0
        super.init(gesamtDauer: 2, start: Date())
        startDate       = Date(timeIntervalSince1970: ((value["start"] as? TimeInterval) ?? 0))
        gesamtDauer     = (value["gesamtDauer"] as? TimeInterval) ?? 0
        anapanaDauer    = (value["anapanaDauer"] as? TimeInterval) ?? 0
        mettaDauer      = (value["mettaDauer"] as? TimeInterval) ?? 0
        mettaEndlos     = (value["mettaOpenEnd"] as? Bool) ?? false
        meditationTitle = value["meditationTitle"] as? String
    }
    
    //helper
    static private func start(string:String) -> TimeInterval{
        let timeValues = string.split(separator: Character(":")).map{TimeInterval($0)}.compactMap{$0}
        return timeValues[0] * 60 * 60 + timeValues[1] * 60
    }
}





