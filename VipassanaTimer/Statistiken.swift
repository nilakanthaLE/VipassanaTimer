//
//  Statistiken.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.02.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
struct Statistik {
    private let start:Date
    private let ende:Date
    let gesamtDauer:TimeInterval
    let anzahlMeditationen:Int
    private var numberOfDays:Int{ return Date.daysBetween(start: start, end: ende) }
    //init
    init (start _start:Date,ende _ende:Date){ self.init(meditationen:Meditation.getDays(start: _start, ende: _ende),start:_start,ende:_ende) }
    init(meditationen:[Meditation],start _start:Date,ende _ende:Date){
        start   = _start
        ende    = _ende
        anzahlMeditationen      = meditationen.count
        gesamtDauer             = meditationen.reduce(0.0) { $0 + ($1.gesamtDauer) }
        timesZweiMalEineStunde  = meditationen.filter{$0.atLeastOneHour}.count
    }
    //Ergebnisse
    var meditationsPerDay:Double        { return Double(anzahlMeditationen) / Double(numberOfDays) }
    var timePerDay:TimeInterval         { return numberOfDays == 0 ? 0 : gesamtDauer / Double(numberOfDays) }
    var timePerMeditation:TimeInterval  { return anzahlMeditationen == 0 ? 0 : gesamtDauer / Double(anzahlMeditationen) }
    var timePerWeek:TimeInterval{
        let anzahlTage      = Date.daysBetween(start: start.mondayOfWeek, end: ende.sundayOfWeek)
        let anzahlWochen    = ceil(Double(anzahlTage) / 7.0)
        return anzahlWochen == 0 ? 0 : gesamtDauer / Double(anzahlWochen)
    }
    var timePerMonth:TimeInterval{
        let anzahlMonate = Date.anzahlMonate(von: start, bis: ende)
        return anzahlMonate == 0 ? 0 : gesamtDauer / Double(anzahlMonate)
    }
    var timesPerDay:Double          { return numberOfDays == 0 ? 0 : Double(anzahlMeditationen) / Double(numberOfDays) }
    var tagDauerLabelText:String    { return "∑ \(gesamtDauer.hhmmString)h | ø \(timePerMeditation.hhmmString)h " + NSLocalizedString("PerM", comment: "PerM") }
    var wocheDauerLabelText:String  { return "∑ \(gesamtDauer.hhmmString)h | ø \(timePerDay.hhmmString)h " + NSLocalizedString("PerDay", comment: "PerDay") }
    var tagAnzahlLabelText:String   { return "∑ \(anzahlMeditationen) | ø \(timePerMeditation.hhmmString)h " + NSLocalizedString("PerM", comment: "PerM") }
    var wocheAnzahlLabelText:String { return "∑ \(anzahlMeditationen) | ø \(timesPerDay.zweiKommaStellenString) " + NSLocalizedString("PerDay", comment: "PerDay") }
    let timesZweiMalEineStunde:Int
}

//extension Int{
//    var asInt16:Int16   {return Int16(self)}
//}

//struct StatistikUeberblickModel{
//    //Strings
//
//    static var gesamtAenderungTag:(text:String,farbe:UIColor){
//        let statistics          = Statistics.get()
//        let gesamtAktuellTag    = statistics.gesamtAktuellTag
//        let gesamtVorherigTag   = statistics.gesamtVorherigTag
//
//        let aenderung   = gesamtAktuellTag - gesamtVorherigTag
//        let farbe       = getFarbe(aenderung:aenderung)
//        let dreieck     = getZeichen(aenderung: aenderung)
//        let prozent     = (gesamtVorherigTag == 0 ? (gesamtAktuellTag == 0 ? 0 : 1) :  1 - (gesamtAktuellTag/gesamtVorherigTag))*100
//        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
//        return (text:string,farbe:farbe)
//    }
//
//    static var gesamtAenderungWoche:(text:String,farbe:UIColor){
//        let statistics              = Statistics.get()
//        let gesamtAktuellWoche      = statistics.gesamtAktuellWoche
//        let gesamtVorherigWoche     = statistics.gesamtVorherigWoche
//
//        let aenderung   = gesamtAktuellWoche - gesamtVorherigWoche
//        let farbe       = getFarbe(aenderung:aenderung)
//        let dreieck     = getZeichen(aenderung: aenderung)
//        let prozent     = (gesamtVorherigWoche == 0 ? (gesamtAktuellWoche == 0 ? 0 : 1) : 1 - (gesamtAktuellWoche/gesamtVorherigWoche) )*100
//        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
//        return (text:string,farbe:farbe)
//    }
//
//    static var gesamtAenderungMonat:(text:String,farbe:UIColor){
//        let statistics              = Statistics.get()
//        let gesamtAktuellMonat      = statistics.gesamtAktuellMonat
//        let gesamtVorherigMonat     = statistics.gesamtVorherigMonat
//
//        let aenderung   = gesamtAktuellMonat - gesamtVorherigMonat
//        let farbe       = getFarbe(aenderung:aenderung)
//        let dreieck     = getZeichen(aenderung: aenderung)
//        let prozent     = (gesamtVorherigMonat == 0 ? (gesamtAktuellMonat == 0 ? 0 : 1) : 1 - (gesamtAktuellMonat/gesamtVorherigMonat))*100
//        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
//        return (text:string,farbe:farbe)
//    }
//    static var durchschnittAenderungTag:(text:String,farbe:UIColor){
//        let statistics              = Statistics.get()
//        let gesamtVorherigTag       = statistics.gesamtVorherigTag
//        let durchschnittTag         = statistics.durchschnittTag
//
//        let aenderung   = gesamtVorherigTag - durchschnittTag
//        let farbe       = getFarbe(aenderung:aenderung)
//        let dreieck     = getZeichen(aenderung: aenderung)
//        let prozent     = (durchschnittTag == 0 ? (gesamtVorherigTag == 0 ? 0 : 1) :  1 - (gesamtVorherigTag/durchschnittTag))*100
//        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
//        return (text:string,farbe:farbe)
//    }
//    static var durchschnittAenderungWoche:(text:String,farbe:UIColor){
//        let statistics              = Statistics.get()
//        let gesamtVorherigWoche     = statistics.gesamtVorherigWoche
//        let durchSchnittWoche       = statistics.durchschnittWoche
//
//        let aenderung   = gesamtVorherigWoche - durchSchnittWoche
//        let farbe       = getFarbe(aenderung:aenderung)
//        let dreieck     = getZeichen(aenderung: aenderung)
//        let prozent     = (durchSchnittWoche == 0 ? (gesamtVorherigWoche == 0 ? 0 : 1) : 1 - (gesamtVorherigWoche/durchSchnittWoche) )*100
//        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
//        return (text:string,farbe:farbe)
//    }
//    static var durchschnittAenderungMonat:(text:String,farbe:UIColor){
//        let statistics              = Statistics.get()
//        let gesamtVorherigMonat     = statistics.gesamtVorherigMonat
//        let durchSchnittMonat       = statistics.durchschnittMonat
//
//        let aenderung   = gesamtVorherigMonat - durchSchnittMonat
//        let farbe       = getFarbe(aenderung:aenderung)
//        let dreieck     = getZeichen(aenderung: aenderung)
//        let prozent     = (durchSchnittMonat == 0 ? (gesamtVorherigMonat == 0 ? 0 : 1) : 1 - (gesamtVorherigMonat/durchSchnittMonat))*100
//        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
//        return (text:string,farbe:farbe)
//    }
//    //helper
//    private static func getZeichen(aenderung:TimeInterval) -> String{
//        return aenderung > 0 ? "▲" : aenderung == 0 ? "=" : "▼"
//    }
//    private static func getFarbe(aenderung:TimeInterval) -> UIColor{
//        return aenderung > 0 ? UIColor.init(red: 51.0/255.0, green: 102.0/255.0, blue: 0.0/255.0, alpha: 1.0) : aenderung == 0 ? UIColor.black : UIColor.red
//    }
//
//}







