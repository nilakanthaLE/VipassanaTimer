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
    private var numberOfDays:Int{
        return Date.daysBetween(start: start, end: ende)
    }
    //init
    init (start _start:Date,ende _ende:Date){
        self.init(meditationen:Meditation.getDays(start: _start, ende: _ende),start:_start,ende:_ende)
    }
    init(meditationen:[Meditation],start _start:Date,ende _ende:Date){
        start   = _start
        ende    = _ende
        anzahlMeditationen      = meditationen.count
        gesamtDauer             = meditationen.reduce(0.0) { $0 + ($1.gesamtDauer) }
    }
    //Ergebnis
    var meditationsPerDay:Double{
        return Double(anzahlMeditationen) / Double(numberOfDays)
    }
    var timePerDay:TimeInterval{
        return numberOfDays == 0 ? 0 : gesamtDauer / Double(numberOfDays)
    }
    var timePerMeditation:TimeInterval{
        return anzahlMeditationen == 0 ? 0 : gesamtDauer / Double(anzahlMeditationen)
    }
    var timePerWeek:TimeInterval{
        let anzahlTage      = Date.daysBetween(start: start.mondayOfWeek, end: ende.sundayOfWeek)
        let anzahlWochen    = ceil(Double(anzahlTage) / 7.0)
        return anzahlWochen == 0 ? 0 : gesamtDauer / Double(anzahlWochen)
    }
    var timePerMonth:TimeInterval{
        let anzahlMonate = Date.anzahlMonate(von: start, bis: ende)
        return anzahlMonate == 0 ? 0 : gesamtDauer / Double(anzahlMonate)
    }
    
    var timesPerDay:Double{
        return numberOfDays == 0 ? 0 : Double(anzahlMeditationen) / Double(numberOfDays)
    }
    var tagDauerLabelText:String{
        return "∑ \(gesamtDauer.hhmmString)h | ø \(timePerMeditation.hhmmString)h " + NSLocalizedString("PerM", comment: "PerM")
    }
    var wocheDauerLabelText:String{
        return "∑ \(gesamtDauer.hhmmString)h | ø \(timePerDay.hhmmString)h " + NSLocalizedString("PerDay", comment: "PerDay")
    }
    
    var tagAnzahlLabelText:String{
        return "∑ \(anzahlMeditationen) | ø \(timePerMeditation.hhmmString)h " + NSLocalizedString("PerM", comment: "PerM")
    }
    var wocheAnzahlLabelText:String{
        return "∑ \(anzahlMeditationen) | ø \(timesPerDay.zweiKommaStellenString) " + NSLocalizedString("PerDay", comment: "PerDay")
    }
    
    
}

extension Int{
    var asInt16:Int16   {return Int16(self)}
}

struct StatistikUeberblickDaten{
    
    static func setCoreDataStatisticsAsync(update:@escaping ()->Void){
        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .userInitiated).async {
            let data        = StatistikUeberblickDaten()
            
            
            let regelmaessigZweimalAmTagMax     = data.regelmaessigEinmalAmTagBisHeute.anzahlZweiMalAmTagMax.asInt16
            let regelmaessigZweiMalAmTag        = data.regelmaessigEinmalAmTagBisHeute.anzahlZweiMalAmTagBisHeute.asInt16
            let regelmaessigEinmalAmTagMax      = data.regelmaessigEinmalAmTagBisHeute.anzahlMax.asInt16
            let regelmaessigEinmalAmTag         = data.regelmaessigEinmalAmTagBisHeute.anzahlBisHeute.asInt16
            let kursTage                        = data.kursTage.asInt16
            let gesamtVorherigWoche             = data.gesamtVorherigWoche
            let gesamtVorherigTag               = data.gesamtVorherigTag
            let gesamtVorherigMonat             = data.gesamtVorherigMonat
            let gesamtDauerOhneKurse            = data.gesamtOhneKurse
            let gesamtDauer                     = data.gesamt
            let gesamtAktuellWoche              = data.gesamtAktuellWoche
            let gesamtAktuellTag                = data.gesamtAktuellTag
            let gesamtAktuellMonat              = data.gesamtAktuellMonat
            let durchschnittWoche               = data.durchSchnittWoche
            let durchschnittVorherigWoche       = data.gesamtVorherigWoche
            let durchschnittVorherigTag         = data.gesamtVorherigTag
            let durchschnittVorherigMonat       = data.gesamtVorherigMonat
            let durchschnittTag                 = data.durchschnittTag
            let durchschnittMonat               = data.durchSchnittMonat
            
            
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                print("start:\(Date().string("HH:mm:ss.SSSS"))")
                let statistics  = Statistics.get()
                
                
                statistics.regelmaessigZweimalAmTagMax     = regelmaessigZweimalAmTagMax
                statistics.regelmaessigZweiMalAmTag        = regelmaessigZweiMalAmTag
                statistics.regelmaessigEinmalAmTagMax      = regelmaessigEinmalAmTagMax
                statistics.regelmaessigEinmalAmTag         = regelmaessigEinmalAmTag
                statistics.kursTage                        = kursTage
                statistics.gesamtVorherigWoche             = gesamtVorherigWoche
                statistics.gesamtVorherigTag               = gesamtVorherigTag
                statistics.gesamtVorherigMonat             = gesamtVorherigMonat
                statistics.gesamtDauerOhneKurse            = gesamtDauerOhneKurse
                statistics.gesamtDauer                     = gesamtDauer
                statistics.gesamtAktuellWoche              = gesamtAktuellWoche
                statistics.gesamtAktuellTag                = gesamtAktuellTag
                statistics.gesamtAktuellMonat              = gesamtAktuellMonat
                statistics.durchschnittWoche               = durchschnittWoche
                statistics.durchschnittVorherigWoche       = durchschnittVorherigWoche
                statistics.durchschnittVorherigTag         = durchschnittVorherigTag
                statistics.durchschnittVorherigMonat       = durchschnittVorherigMonat
                statistics.durchschnittTag                 = durchschnittTag
                statistics.durchschnittMonat               = durchschnittMonat
                saveContext()
                
                update()
                print("ende:\(Date().string("HH:mm:ss.SSSS"))")
            }
        }
        
        
        
    }
    //Strings
    
    static var gesamtAenderungTag:(text:String,farbe:UIColor){
        let statistics          = Statistics.get()
        let gesamtAktuellTag    = statistics.gesamtAktuellTag
        let gesamtVorherigTag   = statistics.gesamtVorherigTag
        
        let aenderung   = gesamtAktuellTag - gesamtVorherigTag
        let farbe       = getFarbe(aenderung:aenderung)
        let dreieck     = getZeichen(aenderung: aenderung)
        let prozent     = (gesamtVorherigTag == 0 ? (gesamtAktuellTag == 0 ? 0 : 1) :  1 - (gesamtAktuellTag/gesamtVorherigTag))*100
        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
        return (text:string,farbe:farbe)
    }
    
    static var gesamtAenderungWoche:(text:String,farbe:UIColor){
        let statistics              = Statistics.get()
        let gesamtAktuellWoche      = statistics.gesamtAktuellWoche
        let gesamtVorherigWoche     = statistics.gesamtVorherigWoche
        
        let aenderung   = gesamtAktuellWoche - gesamtVorherigWoche
        let farbe       = getFarbe(aenderung:aenderung)
        let dreieck     = getZeichen(aenderung: aenderung)
        let prozent     = (gesamtVorherigWoche == 0 ? (gesamtAktuellWoche == 0 ? 0 : 1) : 1 - (gesamtAktuellWoche/gesamtVorherigWoche) )*100
        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
        return (text:string,farbe:farbe)
    }
    
    static var gesamtAenderungMonat:(text:String,farbe:UIColor){
        let statistics              = Statistics.get()
        let gesamtAktuellMonat      = statistics.gesamtAktuellMonat
        let gesamtVorherigMonat     = statistics.gesamtVorherigMonat
        
        let aenderung   = gesamtAktuellMonat - gesamtVorherigMonat
        let farbe       = getFarbe(aenderung:aenderung)
        let dreieck     = getZeichen(aenderung: aenderung)
        let prozent     = (gesamtVorherigMonat == 0 ? (gesamtAktuellMonat == 0 ? 0 : 1) : 1 - (gesamtAktuellMonat/gesamtVorherigMonat))*100
        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
        return (text:string,farbe:farbe)
    }
    static var durchschnittAenderungTag:(text:String,farbe:UIColor){
        let statistics              = Statistics.get()
        let gesamtVorherigTag       = statistics.gesamtVorherigTag
        let durchschnittTag         = statistics.durchschnittTag
        
        let aenderung   = gesamtVorherigTag - durchschnittTag
        let farbe       = getFarbe(aenderung:aenderung)
        let dreieck     = getZeichen(aenderung: aenderung)
        let prozent     = (durchschnittTag == 0 ? (gesamtVorherigTag == 0 ? 0 : 1) :  1 - (gesamtVorherigTag/durchschnittTag))*100
        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
        return (text:string,farbe:farbe)
    }
    static var durchschnittAenderungWoche:(text:String,farbe:UIColor){
        let statistics              = Statistics.get()
        let gesamtVorherigWoche     = statistics.gesamtVorherigWoche
        let durchSchnittWoche       = statistics.durchschnittWoche
        
        let aenderung   = gesamtVorherigWoche - durchSchnittWoche
        let farbe       = getFarbe(aenderung:aenderung)
        let dreieck     = getZeichen(aenderung: aenderung)
        let prozent     = (durchSchnittWoche == 0 ? (gesamtVorherigWoche == 0 ? 0 : 1) : 1 - (gesamtVorherigWoche/durchSchnittWoche) )*100
        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
        return (text:string,farbe:farbe)
    }
    static var durchschnittAenderungMonat:(text:String,farbe:UIColor){
        let statistics              = Statistics.get()
        let gesamtVorherigMonat     = statistics.gesamtVorherigMonat
        let durchSchnittMonat       = statistics.durchschnittMonat
        
        let aenderung   = gesamtVorherigMonat - durchSchnittMonat
        let farbe       = getFarbe(aenderung:aenderung)
        let dreieck     = getZeichen(aenderung: aenderung)
        let prozent     = (durchSchnittMonat == 0 ? (gesamtVorherigMonat == 0 ? 0 : 1) : 1 - (gesamtVorherigMonat/durchSchnittMonat))*100
        let string      = dreieck + " " + abs(aenderung).hhmmString + " (" +  "\(Int(abs(prozent)))%" + ")"
        return (text:string,farbe:farbe)
    }
    //helper
    private static func getZeichen(aenderung:TimeInterval) -> String{
        return aenderung > 0 ? "▲" : aenderung == 0 ? "=" : "▼"
    }
    private static func getFarbe(aenderung:TimeInterval) -> UIColor{
        return aenderung > 0 ? UIColor.init(red: 51.0/255.0, green: 102.0/255.0, blue: 0.0/255.0, alpha: 1.0) : aenderung == 0 ? UIColor.black : UIColor.red
    }
    
    
    //Zeitraum = erster Eintrag / letzter Eintrag
    private var gesamtAktuellTag:TimeInterval{
        let meditationen    = Meditation.getDays(start: Date(), ende: Date())
        return Meditation.gesamtDauer(meditationen: meditationen)
    }
    private var gesamtAktuellWoche:TimeInterval{
        let meditationen    = Meditation.getDays(start: Date().mondayOfWeek, ende: Date().sundayOfWeek)
        return Meditation.gesamtDauer(meditationen: meditationen)
    }
    private var gesamtAktuellMonat:TimeInterval{
        let meditationen    = Meditation.getDays(start: Date().startOfMonth, ende: Date().endOfMonth)
        return Meditation.gesamtDauer(meditationen: meditationen)
    }
    
    private var gesamtVorherigTag:TimeInterval{
        let meditationen    = Meditation.getDays(start: Date().addDays(-1), ende: Date().addDays(-1))
        return Meditation.gesamtDauer(meditationen: meditationen)
    }
    private var gesamtVorherigWoche:TimeInterval{
        let vorwoche        = Date().mondayOfWeek.addDays(-1)
        let meditationen    = Meditation.getDays(start: vorwoche.mondayOfWeek, ende: vorwoche.sundayOfWeek)
        return Meditation.gesamtDauer(meditationen: meditationen)
    }
    private var gesamtVorherigMonat:TimeInterval{
        let vormonat        = Date().startOfMonth.addDays(-1)
        let meditationen    = Meditation.getDays(start: vormonat.startOfMonth, ende: vormonat.endOfMonth)
        return Meditation.gesamtDauer(meditationen: meditationen)
    }
    static var startDateFuerDurchschnitt:Date? {
        let appConfig = AppConfig.get()
        if let datum = appConfig?.startDatumStatistik{
            return datum as Date
        }else{
            return Meditation.getAll().first?.start as Date?
        }
    }
    static var endeDateFuerDurchschnitt:Date? = Date()
    private var durchschnittTag:TimeInterval{
        guard let start     = StatistikUeberblickDaten.startDateFuerDurchschnitt, let ende = StatistikUeberblickDaten.endeDateFuerDurchschnitt else{return 0}
        let meditationen    = Meditation.getDays(start: start, ende: ende)
        let statistik       = Statistik(meditationen: meditationen, start: start, ende: ende)
        return statistik.timePerDay
    }
    private var durchSchnittWoche:TimeInterval{
        guard let start = StatistikUeberblickDaten.startDateFuerDurchschnitt, let ende = StatistikUeberblickDaten.endeDateFuerDurchschnitt else{return 0}
        let meditationen    = Meditation.getDays(start: start, ende: ende)
        let statistik       = Statistik(meditationen: meditationen, start: start, ende: ende)
        return statistik.timePerWeek
    }
    private var durchSchnittMonat:TimeInterval{
        guard let start = StatistikUeberblickDaten.startDateFuerDurchschnitt, let ende = StatistikUeberblickDaten.endeDateFuerDurchschnitt else{return 0}
        let meditationen    = Meditation.getDays(start: start, ende: ende)
        let statistik       = Statistik(meditationen: meditationen, start: start, ende: ende)
        return statistik.timePerMonth
    }
    
    private var gesamt:TimeInterval{
        return Meditation.gesamtDauer(meditationen: Meditation.getAllTillToday())
    }
    
    
    private var gesamtOhneKurse:TimeInterval{
        return Meditation.gesamtDauer(meditationen: Meditation.getAllOhneKurse())
    }
    private var kursTage:Int{
        return Kurs.getAllTillToday().map{Int($0.kursTage)}.reduce(0){$0+$1}
    }
    private var regelmaessigEinmalAmTagBisHeute:(anzahlBisHeute:Int,anzahlMax:Int,anzahlZweiMalAmTagBisHeute:Int,anzahlZweiMalAmTagMax:Int){
        let meditationen = Meditation.getAllTillToday().reversed()
        
        var lastMeditation = meditationen.first
        var meditationDays = [[Meditation]]()
        for meditation in meditationen{
            if let start = meditation.start, let letzterStart = lastMeditation?.start{
                if (start as Date).istGleicherTag(wie: letzterStart as Date){
                    if meditationDays.last != nil{
                        var last = meditationDays.last!
                        last.append(meditation)
                        meditationDays.removeLast()
                        meditationDays.append(last)
                    }else{
                        meditationDays.append([lastMeditation!])
                    }
                }else{
                    var new = [Meditation]()
                    new.append(meditation)
                    meditationDays.append(new)
                }
            }
            lastMeditation = meditation
        }
        // ...
        var ersterDurchlauf                     = true
        var istBisHeute                         = true
        var istBisHeuteZweiMal                  = true
        var zusammenhaengendeTage               = 0
        var zusammenhaengendeTageBisHeute       = 0
        var zusammenhaengendeTageMax            = 0
        var zusammenhaengendZweiMalTage         = 0
        var zusammenhaengendZweiMalTageBisHeute = 0
        var zusammenhaengendZweiMalTageMax      = 0
        var lastMeditationDayIsZweiMal          = true
        
        guard var lastDay = meditationDays.first?.first?.start else{return (0,0,0,0)}
        if !(lastDay as Date).istGleicherTag(wie: Date()) &&  !(lastDay as Date).istGleicherTag(wie: Date().addDays(-1)) { istBisHeute = false}
        
        for meditationDay in meditationDays{
            
            if let iDay  = meditationDay.first?.start{
                // ist iDay Vortag zu lastDay?
                if (lastDay as Date).addDays(-1).istGleicherTag(wie: iDay as Date) || ersterDurchlauf{
                    
                    
                    zusammenhaengendeTage   += 1
                    if istBisHeute                                      { zusammenhaengendeTageBisHeute += 1 }
                    if zusammenhaengendeTage > zusammenhaengendeTageMax { zusammenhaengendeTageMax = zusammenhaengendeTage }
                    
                    var anzahl = 0
                    for meditation in meditationDay{
                        anzahl += meditation.gesamtDauer >= 60*60 ? 1 : 0
                    }
                    
                    if (anzahl < 2 ) && !(iDay as Date).istGleicherTag(wie: Date()) || !istBisHeute
                    {istBisHeuteZweiMal = false}
                    
                    if anzahl >= 2{
                        if lastMeditationDayIsZweiMal {
                            zusammenhaengendZweiMalTage += 1
                            if istBisHeuteZweiMal{ zusammenhaengendZweiMalTageBisHeute += 1 }
                            if zusammenhaengendZweiMalTage > zusammenhaengendZweiMalTageMax { zusammenhaengendZweiMalTageMax = zusammenhaengendZweiMalTage }
                        }
                        else{
                            zusammenhaengendZweiMalTage = 1
                            if istBisHeuteZweiMal{ zusammenhaengendZweiMalTageBisHeute = 1 }
                        }
                    }
                    lastMeditationDayIsZweiMal  = anzahl >= 2 ? true : false
                }
                else{
                    //erster Durchlauf
                    zusammenhaengendeTage           = 0
                    zusammenhaengendZweiMalTage     = 0
                    lastMeditationDayIsZweiMal      = false
                    istBisHeute                     = false
                    istBisHeuteZweiMal              = false
                }
                lastDay = iDay
            }
            ersterDurchlauf = false
        }
        return (anzahlBisHeute:zusammenhaengendeTageBisHeute,anzahlMax:zusammenhaengendeTageMax,anzahlZweiMalAmTagBisHeute:zusammenhaengendZweiMalTageBisHeute,anzahlZweiMalAmTagMax:zusammenhaengendZweiMalTageMax)
    }
}
