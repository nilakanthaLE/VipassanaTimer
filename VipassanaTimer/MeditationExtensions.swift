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
    class func new(template:MeditationTemplate,start:Date)->Meditation?{
        guard let meditation = new(start: start, mettaOpenEnd: false, name: template.name) else{return nil}
        meditation.dauerAnapana         = template.dauerAnapana
        meditation.dauerVipassana       = template.dauerVipassana
        meditation.dauerMetta           = template.dauerMetta
        meditation.ende                 = start.addingTimeInterval(meditation.gesamtDauer) as NSDate?
        return meditation
    }
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
    class func getAllTillToday()->[Meditation]{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "start <= %@", Date() as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        if let meditationen = (try? context.fetch(request)){
            return meditationen
        }
        return [Meditation]()
    }
    class func getAllOhneKurse()->[Meditation]{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "kurs = nil")
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
        guard let start = start else{return KalenderEintrag()}
        return KalenderEintrag(starts: start as Date, ende: start.addingTimeInterval(gesamtDauer) as Date, view: eintragView)
    }
    
    class func getValuesFor(graphTyp:GraphTypen,von:Date,bis:Date) -> (werte:[Double],xAchsenBeschriftung:[String]){
        var ergebnis = [Double]()
        var xAchsenBeschriftung = [String]()
        switch graphTyp {
        case .GesamtdauerProWoche:
            guard let start = von.mondayOfWeek.firstSecondOfDay,let ende = bis.sundayOfWeek.lastSecondOfDay else{return (werte:[Double](),xAchsenBeschriftung:[String]())}
            var date = start
            while ende.isGreaterThanDate(dateToCompare: date){
                guard let startWoche = date.mondayOfWeek.firstSecondOfDay,let endeWoche = date.sundayOfWeek.lastSecondOfDay else{return (werte:[Double](),xAchsenBeschriftung:[String]())}
                let gesamtDauerWoche = Meditation.getDays(start: startWoche, ende: endeWoche).map{$0.gesamtDauer}.reduce(0){$0+$1}
                date = endeWoche.addDays(1).mondayOfWeek.firstSecondOfDay!
                ergebnis.append(gesamtDauerWoche)
                xAchsenBeschriftung.append("\(startWoche.string("dd.MM."))-\(endeWoche.string("dd.MM."))")
            }
        case .GesamtdauerProMonat:
            guard let start = von.startOfMonth.firstSecondOfDay,let ende = bis.endOfMonth.lastSecondOfDay else{return (werte:[Double](),xAchsenBeschriftung:[String]())}
            var date = start
            while ende.isGreaterThanDate(dateToCompare: date){
                guard let startMonat = date.startOfMonth.firstSecondOfDay,let endeMonat = date.endOfMonth.lastSecondOfDay else{return (werte:[Double](),xAchsenBeschriftung:[String]())}
                let gesamtDauerMonat = Meditation.getDays(start: startMonat, ende: endeMonat).map{$0.gesamtDauer}.reduce(0){$0+$1}
                date = endeMonat.addDays(1).startOfMonth.firstSecondOfDay!
                ergebnis.append(gesamtDauerMonat)
                xAchsenBeschriftung.append("\(startMonat.string("dd.MM."))-\(endeMonat.string("dd.MM."))")
            }
        case .GesamtdauerProTag:
            guard let start = von.firstSecondOfDay,let ende = bis.lastSecondOfDay else{return (werte:[Double](),xAchsenBeschriftung:[String]())}
            var date = start
            while ende.isGreaterThanDate(dateToCompare: date){
                guard let startTag = date.firstSecondOfDay,let endeTag = date.lastSecondOfDay else{return (werte:[Double](),xAchsenBeschriftung:[String]())}
                let gesamtDauerTag = Meditation.getDays(start: startTag, ende: endeTag).map{$0.gesamtDauer}.reduce(0){$0+$1}
                date = endeTag.addDays(1).firstSecondOfDay!
                ergebnis.append(gesamtDauerTag)
                xAchsenBeschriftung.append(startTag.string("dd.MM."))
            }
        }
        return (werte:ergebnis,xAchsenBeschriftung:xAchsenBeschriftung)
    }
    class func gesamtDauer(meditationen:[Meditation]) -> TimeInterval{
        return meditationen.map{$0.gesamtDauer}.reduce(0){$0+$1}
    }
    class func sorted(meditationen:[Meditation]) -> [Meditation]{
        return meditationen.sorted(by: {$0.start?.compare($1.start as! Date) == .orderedAscending })
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
        print("meditation tapped\(meditation)")
        
        NotificationCenter.default.post(name: Notification.Name.MyNames.meditationsKalenderEintragPressed, object: nil, userInfo: ["meditation":meditation])
    }

}

