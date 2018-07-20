//
//  DateExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 19.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation

//✅
extension TimeInterval{
    var hhmm:String         { return "\(stunden):" + zweiZiffern(uebrigeMinuten) }
    var hhmmss:String       { return "\(stunden):" + zweiZiffern(uebrigeMinuten) + ":" + zweiZiffern(uebrigeSekunden) }
    var dhh:String{
        let days    = Int(stunden / 24)
        let hours   = stunden - days * 24
        return "\(days)d \(hours)h"
    }
    var zweiKommaStellenString:String{ return "\(Double(Int(self*100)) / 100.0)" }
    
    //helper
    private var stunden:Int         { return Int(self / (60 * 60)) }
    private var uebrigeMinuten:Int  { return (Int(self) - (stunden * 60 * 60)) / 60}
    private var uebrigeSekunden:Int { return (Int(self) - (stunden * 60 * 60) - (uebrigeMinuten * 60))}
    private func zweiZiffern(_ wert:Int) -> String{ return wert < 10 ? "0\(wert)" : "\(wert)" }
}

//✅
extension Date{
    //gestern, letzte Woche usw.
    static var gestern:Date         { return Date().addDays(-1) }
    static var vorgestern:Date      { return Date().addDays(-2) }
    static var vorWoche:Date        { return Date().mondayOfWeek.addDays(-1) }
    static var vorletzteWoche:Date  { return Date().mondayOfWeek.addDays(-1).mondayOfWeek.addDays(-1) }
    static var vorMonat:Date        { return Date().startOfMonth.addDays(-1) }
    static var vorletzterMonat:Date { return Date().startOfMonth.addDays(-1).startOfMonth.addDays(-1) }
    
    //start und ende (tag, woche, monat)
    var firstSecondOfDay:Date?      { return currentCalender.date(bySettingHour: 0, minute: 0, second: 0, of: self) }
    var lastSecondOfDay:Date?       { return currentCalender.date(bySettingHour: 23, minute: 59, second: 59, of: self) }
    var mondayOfWeek:Date{
        let weekdayComponents       = currentCalender.component(.weekday, from: self)
        var compontentsToSubstract  = DateComponents()
        compontentsToSubstract.day  = -(weekdayComponents - currentCalender.firstWeekday)
        compontentsToSubstract.day  = compontentsToSubstract.day == 1 ? -6 : compontentsToSubstract.day
        let beginningOfWeek         = currentCalender.date(byAdding: compontentsToSubstract, to: self)
        let components              = currentCalender.dateComponents([.year,.month,.day], from: beginningOfWeek!)
        return currentCalender.date(from: components)!
    }
    var sundayOfWeek:Date           { return mondayOfWeek.addDays(6) }
    var isSunday:Bool               { return sundayOfWeek.string("dd.MM.yyyy") == self.string("dd.MM.yyyy") }
    var startOfMonth:Date{
        let currentDateComponents = currentCalender.dateComponents([.year , .month], from: self)
        return currentCalender.date(from: currentDateComponents)!
    }
    var endOfMonth : Date {
        let plusOneMonthDate            = dateByAddingMonths(monthsToAdd: 1)
        let plusOneMonthDateComponents  = currentCalender.dateComponents([.year , .month], from: plusOneMonthDate)
        return (currentCalender.date(from:plusOneMonthDateComponents)?.addingTimeInterval(-1))!
    }
    
    //Anzahl Tage,Wochen, Monate
    static func daysBetween(start: Date, end: Date) -> Int  { return Calendar.current.dateComponents([.day], from: start, to: end).day! + 1 }
    static func anzahlWochen(von:Date,bis:Date) -> Double   { return ceil(Double(Date.daysBetween(start: von.mondayOfWeek, end: bis.sundayOfWeek)) / 7.0) }
    static func anzahlMonate(von:Date, bis:Date) -> Int     { return (Calendar.current.dateComponents([.month], from: von, to: bis).month ?? 0 ) + 1 }
    
    //gibt Datum der Woche zurück, welche die meisten Tage im Array enthält
    // für Title in WochenKalender
    static func weekOfMostDays(in array:[Date])->Date{
        guard let first = array.first, let last = array.last, let sonntagDerWocheDesErstenTages = first.sundayOfWeek.lastSecondOfDay else{return Date()}
        let anzahlTageVorSonntag = array.filter { sonntagDerWocheDesErstenTages.isGreaterThanDate(dateToCompare: $0) }.count
        return anzahlTageVorSonntag >= 2 ? first : last
    }
   
    //vergangene Sekunden eines Tages
    var timeIntervalOfDay:TimeInterval{ return timeIntervalSince(firstSecondOfDay!) }
    
    // der DatumsString gemäß übergebenem DatumsFormat
    func string(_ format:String)->String{
        let formatter           = DateFormatter()
        formatter.dateFormat    = format
        formatter.locale        = Locale(identifier: Locale.current.languageCode == "de" ? "de" : "en") // Locale(identifier: "de")
        return formatter.string(from: self)
    }
    
    //Tage hinzufügen
    func addDays(_ days:Int) -> Date                    { return (currentCalender as NSCalendar).date(byAdding: .day, value: days, to: self, options: .matchFirst)! }
    
    //vergleichen
    func isGreaterThanDate(dateToCompare:Date) -> Bool  { return self.compare(dateToCompare) == ComparisonResult.orderedDescending }
    
    //helper
    private var currentCalender:Calendar{return Calendar.current}
    private func dateByAddingMonths(monthsToAdd: Int) -> Date {
        var months      = DateComponents()
        months.month    = monthsToAdd
        return currentCalender.date(byAdding: months, to: self)!
    }
}


