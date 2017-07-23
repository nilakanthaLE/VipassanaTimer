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
import Firebase

extension Meditation:EintragInKalender{
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    class func new(template:MeditationTemplate,start:Date)->Meditation?{
        guard let meditation = new(start: start, mettaOpenEnd: false, name: template.name) else{return nil}
        meditation.dauerAnapana         = template.dauerAnapana
        meditation.dauerVipassana       = template.dauerVipassana
        meditation.dauerMetta           = template.dauerMetta
        return meditation
    }
    class func new(start:Date,mettaOpenEnd:Bool,name:String?)->Meditation?{
        
        if let meditation = NSEntityDescription.insertNewObject(forEntityName: "Meditation", into: context) as? Meditation{
            
            meditation.meditationsID    = UUID().uuidString
            meditation.start            = start
            meditation.mettaOpenEnd     = mettaOpenEnd
            meditation.name             = name
            meditation.cloudNeedsUpdate = true
            return meditation
        }
        return nil
    }
    class func new(start:Date,timerConfig:TimerConfig) -> Meditation?{
        
        if let meditation = NSEntityDescription.insertNewObject(forEntityName: "Meditation", into: context) as? Meditation{
            
            meditation.meditationsID    = UUID().uuidString
            meditation.start            = start
            meditation.dauerAnapana     = timerConfig.dauerAnapana
            meditation.dauerVipassana   = timerConfig.dauerVipassana
            meditation.dauerMetta       = timerConfig.dauerMetta
            meditation.mettaOpenEnd     = timerConfig.mettaOpenEnd
            meditation.name             = timerConfig.name
            meditation.cloudNeedsUpdate = true
            
            return meditation
        }
        return nil
    }
    class func startNewActive(timerConfig:TimerConfig) -> Meditation?{
        let meditation          = new(start: Date(), timerConfig: timerConfig)
        return meditation
    }
    
    
    
    var firebaseData:[String:Any]?{
        guard let start = start else {return nil}
        var dict:[String:Any]        =      ["name"             : name ?? "_fehlt",
                                             "start"            : start.timeIntervalSinceReferenceDate,
                                             "dauerAnapana"     : dauerAnapana,
                                             "dauerVipassana"   : dauerVipassana,
                                             "dauerMetta"       : dauerMetta,
                                             "lastSync"         : Date().timeIntervalSinceReferenceDate ]
        if let kursID = kurs?.kursID { dict["kursID" ] = kursID }
        return dict
    }
    static func createOrUpdateMeditation(withChild snapshot:DataSnapshot?){
        print("Meditation createOrUpdateMeditation")
        guard let snapshot = snapshot else {return}

        guard let meditation = getOrCreate(withID: snapshot.key) else {return}
        guard snapshot.valueAsDict?["deleted"] as? Bool != true else {
            print("delete ...")
            meditation.delete(inFirebaseToo: false); return
        }
        
        
        meditation.name             = snapshot.valueAsDict?["name"] as? String
        meditation.start            = Date(timeIntervalSinceReferenceDate: snapshot.valueAsDict?["start"] as? TimeInterval ?? 0)
        meditation.dauerAnapana     = snapshot.valueAsDict?["dauerAnapana"] as? Int32 ?? 0
        meditation.dauerVipassana   = snapshot.valueAsDict?["dauerVipassana"] as? Int32 ?? 0
        meditation.dauerMetta       = snapshot.valueAsDict?["dauerMetta"] as? Int32 ?? 0
        meditation.inFirebase       = true
        if let kursID = snapshot.valueAsDict?["kursID"] as? String{
            meditation.kurs             = Kurs.getOrCreateEmpty(withID: kursID)
        }
        saveContext()
    }
    
    static private func getOrCreate(withID medID:String)->Meditation?{
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "meditationsID = %@", medID)
        if let meditation = (try? context.fetch(request))?.first{
            return meditation
        }
        if let meditation = NSEntityDescription.insertNewObject(forEntityName: "Meditation", into: context) as? Meditation{
            meditation.meditationsID    = medID
            return meditation
        }
        else {return nil}
    }
    
    static func getNotInFirebase()->[Meditation]{
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "inFirebase ==  false || inFirebase == nil")
        if let meditationen = (try? context.fetch(request)){
            return meditationen
        }
        return [Meditation]()
    }

    func addPause(start:Date,ende:Date){
        if let pause = Dauer.new(start: start, ende: ende){
            pausen?.adding(pause)
        }
    }
    
    var ende:Date{
        let _start = start! as Date
        return _start + TimeInterval(dauerAnapana) + TimeInterval(dauerVipassana) + TimeInterval(dauerMetta) + gesamtPausenDauer
    }
    
    static func cleanShortMeditations(){
        for meditation in Meditation.getAll(){
            if meditation.gesamtDauer < 5 * 60{
                meditation.delete(inFirebaseToo: true)
                print("deleted")
            }
        }
    }

    
    class func getNeedCloudUpdate() -> [Meditation]{
        
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "cloudNeedsUpdate == true")
        if let meditationen = (try? context.fetch(request)){
            return meditationen
        }
        return [Meditation]()
    }
    class func get(start:Date,ende:Date)->Meditation?{
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSCompoundPredicate(andPredicateWithSubpredicates:
            [NSPredicate(format: "start == %@",start.firstSecondOfDay! as CVarArg),
             NSPredicate(format: "start == %@", ende.lastSecondOfDay! as CVarArg)])
        if let meditationen = (try? context.fetch(request)){
            return meditationen.first
        }
        return nil
    }
    class func getNotInHealthKit()->[Meditation]{
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "inHealthKit ==  false || inHealthKit == nil")
        if let meditationen = (try? context.fetch(request)){
            return meditationen
        }
        return [Meditation]()
    }
    class func getAll()->[Meditation]{
        
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        if let meditationen = (try? context.fetch(request)){
            return meditationen
        }
        return [Meditation]()
    }
    class func getAllTillToday()->[Meditation]{
        
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "start <= %@", Date() as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        if let meditationen = (try? context.fetch(request)){
            return meditationen
        }
        return [Meditation]()
    }
    class func getAllOhneKurse()->[Meditation]{
        print("getAllOhneKurse")
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "kurs == nil")
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
    
    
    
    func beendet(_ date:Date){
        let verstrichenOhnePause           = Int32(date.timeIntervalSince(start! as Date) - gesamtPausenDauer)
        if verstrichenOhnePause <= dauerAnapana{
            dauerAnapana    = verstrichenOhnePause
            dauerVipassana  = 0
            dauerMetta      = 0
        }else if  verstrichenOhnePause <= (dauerAnapana + dauerVipassana){
            dauerVipassana  = verstrichenOhnePause - dauerAnapana
            dauerMetta      = 0
        }else {
            dauerMetta      = verstrichenOhnePause - dauerAnapana - dauerVipassana
        }
        
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
    var eintragStart:Date{ return start! as Date }
    var eintragEnde:Date{ return ende as Date }
    func delete(inFirebaseToo:Bool){
        HealthManager().deleteMeditation(meditation: self)
        if inFirebaseToo{ FirMeditations.deleteMeditation(meditation:self) }
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(self)
        saveContext()
    }
    
    //Statistiken
    var gesamtDauer:TimeInterval{ return TimeInterval(dauerMetta + dauerAnapana + dauerVipassana) }
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
        return meditationen.sorted(by: {$0.start?.compare($1.start! as Date) == .orderedAscending })
    }
}

class MeditationsKalenderEintrag: NibLoadingView{
    var meditation:Meditation!{
        didSet{
            let multiplierAnapana       = CGFloat(meditation!.dauerAnapana ) / CGFloat(meditation.gesamtDauer)
            let multiplierVipassana     = CGFloat(meditation!.dauerVipassana) / CGFloat(meditation.gesamtDauer)
            
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

