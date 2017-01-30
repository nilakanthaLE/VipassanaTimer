//
//  MeditationExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MyCalendar

extension Meditation:EintragInKalender{
    class func new(start:Date,mettaOpenEnd:Bool,name:String?)->Meditation?{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let meditation = NSEntityDescription.insertNewObject(forEntityName: "Meditation", into: context) as? Meditation{
            
            meditation.start            = start as NSDate?
            meditation.mettaOpenEnd     = mettaOpenEnd
            meditation.name             = name
            return meditation
        }
        return nil
    }
    func addPause(start:Date,ende:Date){
        if let pause = Dauer.new(start: start, ende: ende){
            pausen?.adding(pause)
        }
    }
    class func getAll()->[Meditation]{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        if let meditationen = (try? context.fetch(request)){
            return meditationen
        }
        return [Meditation]()
    }
    class func get7Days(firstDay:Date) -> [[Meditation]]{
        var meditationen    = [[Meditation]]()
        for i in 0 ..< 7{
            meditationen.append(getDay(day: firstDay.addDays(i)))
        }

        return meditationen
    }
    class func getDays(start:Date,ende:Date)->[Meditation]{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSCompoundPredicate(andPredicateWithSubpredicates:
            [NSPredicate(format: "start >= %@",start.firstSecondOfDay! as CVarArg),
             NSPredicate(format: "start <= %@", ende.lastSecondOfDay! as CVarArg)])
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        if let meditationen = (try? context.fetch(request)){
            return meditationen
        }
        return [Meditation]()
    }
    private class func getDay(day:Date)->[Meditation]{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSCompoundPredicate(andPredicateWithSubpredicates:
            [NSPredicate(format: "start >= %@",day.firstSecondOfDay! as CVarArg),
             NSPredicate(format: "start <= %@", day.lastSecondOfDay! as CVarArg)])
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        if let meditationen = (try? context.fetch(request)){
            return meditationen
        }
        return [Meditation]()
    }
    func earlyEnd(date:Date){
        let verstrichenOhnePause           = Int32(date.timeIntervalSince(start as! Date) - gesamtPausenDauer)
        if verstrichenOhnePause <= dauerAnapana{
            dauerAnapana    = verstrichenOhnePause
            dauerVipassana  = 0
            dauerMetta      = 0
        }else if  verstrichenOhnePause <= (dauerAnapana + dauerVipassana){
            dauerVipassana  = verstrichenOhnePause - dauerAnapana
            dauerMetta      = 0
        }else if verstrichenOhnePause <= (dauerAnapana + dauerVipassana + dauerMetta){
            dauerMetta      = verstrichenOhnePause - dauerAnapana - dauerVipassana
        }
        ende = date as NSDate?
    }
    var gesamtPausenDauer:TimeInterval{
        var ergebnis = TimeInterval(0)
        for pause in (pausen as? Set<Dauer>) ?? Set<Dauer>(){
            ergebnis += pause.asTimeInterval
        }
        return ergebnis
    }
    //Protocol EintragInKalender
    var eintragView:UIView{
        let eintrag         = MeditationsKalenderEintrag()
        eintrag.meditation  = self
        return eintrag
    }
    var eintragStart:Date{
        return start as! Date
    }
    var eintragEnde:Date{
        return ende as! Date
    }
    func delete(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(self)
    }
    var gesamtDauer:TimeInterval{
        return TimeInterval(dauerMetta + dauerAnapana + dauerVipassana)
    }
    //Statistiken
    class func getStatistics(von start:Date,bis ende:Date) -> Statistik{
        let meditations = Meditation.getDays(start: start, ende: ende)
        return Statistik.init(meditationen: meditations, start: start, ende: ende)
    }
    
    //MARK: KalenderEinträge
    class func getKalenderEintraege(days:[Date])->[[KalenderEintrag]]{
        var eintraege = [[KalenderEintrag]]()
        for day in days{
            let eintraegeDay = Meditation.getDay(day: day).map({$0.kalenderEintrag})
            eintraege.append(eintraegeDay)
        }
        return eintraege
    }
    var kalenderEintrag:KalenderEintrag{
        guard let start = start, let ende = ende else{return KalenderEintrag()}
        return KalenderEintrag(starts: start as Date, ende: ende as Date, view: eintragView)
    }
}

class MeditationsKalenderEintrag: NibLoadingView{
    var meditation:Meditation!{
        didSet{
            let gesamt                  = CGFloat(meditation!.dauerMetta + meditation!.dauerAnapana + meditation!.dauerVipassana)
            let multiplierAnapana       = CGFloat(meditation!.dauerAnapana ) / gesamt
            let multiplierVipassana     = CGFloat(meditation!.dauerVipassana) / gesamt
            
            anapanaView.superview?.removeConstraints([anteilAnapanaConstraint,anteilVipassanaConstraint])
            anteilAnapanaConstraint     = NSLayoutConstraint(item: anapanaView, attribute: .width, relatedBy: .equal, toItem: anapanaView.superview, attribute: .width, multiplier: multiplierAnapana, constant: 0)
            anteilVipassanaConstraint   = NSLayoutConstraint(item: vipassanaView, attribute: .width, relatedBy: .equal, toItem: vipassanaView.superview, attribute: .width, multiplier: multiplierVipassana, constant: 0)
            anapanaView.superview?.addConstraints([anteilAnapanaConstraint,anteilVipassanaConstraint])
        }
    }
    @IBOutlet weak var anteilVipassanaConstraint: NSLayoutConstraint!
    @IBOutlet weak var anteilAnapanaConstraint: NSLayoutConstraint!
    @IBOutlet weak var anapanaView: UIView!
    @IBOutlet weak var vipassanaView: UIView!
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        
        
        NotificationCenter.default.post(name: Notification.Name.MyNames.meditationsKalenderEintragPressed, object: nil, userInfo: ["meditation":meditation])
    }

}

struct Statistik {
    private let start:Date
    private let ende:Date
    private let gesamtDauer:TimeInterval
    private let anzahlMeditationen:Int
    private var numberOfDays:Int{
        return Date.daysBetween(start: start, end: ende)
    }
    //init
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
    var timesPerDay:Double{
        return numberOfDays == 0 ? 0 : Double(anzahlMeditationen) / Double(numberOfDays)
    }
    var tagDauerLabelText:String{
        return "∑ \(gesamtDauer.hhmmString)h | ø \(timePerMeditation.hhmmString)h pro M."
    }
    var wocheDauerLabelText:String{
        return "∑ \(gesamtDauer.hhmmString)h | ø \(timePerDay.hhmmString)h pro Tag"
    }
    
    var tagAnzahlLabelText:String{
        return "∑ \(anzahlMeditationen) | ø \(timePerMeditation.hhmmString)h pro M."
    }
    var wocheAnzahlLabelText:String{
        return "∑ \(anzahlMeditationen) | ø \(timesPerDay.zweiKommaStellenString) pro Tag"
    }
    
}
