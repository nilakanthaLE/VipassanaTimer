//
//  Statistiken.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.02.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation

//✅
//statistische Daten für Zeiträume
struct Statistik {
    //init
    let gesamtDauer:TimeInterval
    let anzahlMeditationen:Int
    let timesZweiMalEineStunde:Int
    private let numberOfDays:Int
    private let start:Date
    private let ende:Date
    init?(start:Date?,ende:Date?) {
        guard let start = start, let ende = ende else {return nil}
        self.start   = start
        self.ende    = ende
        let meditationen        = Meditation.getZeitraum(start: start.firstSecondOfDay, ende: ende.lastSecondOfDay)
        anzahlMeditationen      = meditationen.count
        gesamtDauer             = meditationen.reduce(0.0) { $0 + ($1.gesamtDauer) }
        timesZweiMalEineStunde  = meditationen.filter{$0.atLeastOneHour}.count
        numberOfDays            = Date.daysBetween(start: start, end: ende)
    }

    //Ergebnisse
    var timesPerDay:Double              { return numberOfDays == 0 ? 0 : Double(anzahlMeditationen) / Double(numberOfDays) }
    var timePerMeditation:TimeInterval  { return anzahlMeditationen == 0 ? 0 : gesamtDauer / Double(anzahlMeditationen) }
    var timePerDay:TimeInterval         { return numberOfDays == 0 ? 0 : gesamtDauer / Double(numberOfDays) }
    var timePerWeek:TimeInterval        { return Date.anzahlWochen(von: start, bis: ende) == 0 ? 0 : gesamtDauer / Date.anzahlWochen(von: start, bis: ende)  }
    var timePerMonth:TimeInterval       { return Date.anzahlMonate(von: start, bis: ende) == 0 ? 0 : gesamtDauer / Double(Date.anzahlMonate(von: start, bis: ende))  }

    //Strings
    var tagDauerLabelText:String    { return "∑ \(gesamtDauer.hhmm)h | ø \(timePerMeditation.hhmm)h " + NSLocalizedString("PerM", comment: "PerM") }
    var wocheDauerLabelText:String  { return "∑ \(gesamtDauer.hhmm)h | ø \(timePerDay.hhmm)h " + NSLocalizedString("PerDay", comment: "PerDay") }
    var tagAnzahlLabelText:String   { return "∑ \(anzahlMeditationen) | ø \(timePerMeditation.hhmm)h " + NSLocalizedString("PerM", comment: "PerM") }
    var wocheAnzahlLabelText:String { return "∑ \(anzahlMeditationen) | ø \(timesPerDay.zweiKommaStellenString) " + NSLocalizedString("PerDay", comment: "PerDay") }
}

//✅
//statistische Daten für Tage
class StatistikDay{
    static func buddhaStatus(day:Date) -> BuddhaStatus{
        let meditations = Meditation.getZeitraum(start: day, ende: day)
        if (meditations.filter{$0.atLeastOneHour}).count >= 2   { return .gold}
        if meditations.count > 0                                { return .silver }
        return .none
    }
    static func statusLabelText(day:Date) -> String {  return buddhaStatus(day:day).statusLabelText }
    static func timePerDay(day:Date) -> Double {
        let meditationen            = Meditation.getZeitraum(start: day, ende: day)
        let anzahlMeditationen      = meditationen.count
        let gesamtDauer             = meditationen.reduce(0.0) { $0 + ($1.gesamtDauer) }
        return anzahlMeditationen == 0 ? 0 : gesamtDauer / Double(anzahlMeditationen)
    }
}







