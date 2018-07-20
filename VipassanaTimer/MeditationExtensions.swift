//
//  MeditationExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import CoreData
import MyCalendar
import Firebase


//✅
//MARK: static Methods - Meditationen erstellen
extension Meditation{
    //eine neue Meditation erstellen
    class func new(start:Date,mettaOpenEnd:Bool,name:String?)->Meditation?{
        let meditation = NSEntityDescription.insertNewObject(forEntityName: "Meditation", into: context) as? Meditation
        meditation?.meditationsID    = UUID().uuidString
        meditation?.start            = start
        meditation?.mettaOpenEnd     = mettaOpenEnd
        meditation?.name             = name
        meditation?.cloudNeedsUpdate = true
        return meditation
    }
    //eine neue Meditation über den Kalender erstellen
    static func new(timerData:TimerData,start:Date)->Meditation?{
        let meditation = new(start: start, mettaOpenEnd: false, name: timerData.meditationTitle)
        meditation?.dauerAnapana            = Int32(timerData.anapanaDauer)
        meditation?.dauerVipassana          = Int32(timerData.vipassanaDauer)
        meditation?.dauerMetta              = Int32(timerData.mettaDauer)
        meditation?.cloudNeedsUpdate        = true
        return meditation
    }
    //eine neue Meditation für einen Kurs erstellen
    static func new(kursMeditation:KursMeditation)->Meditation?{
        guard let meditation = new(start: kursMeditation.startDate, mettaOpenEnd: false, name: kursMeditation.meditationTitle) else{return nil}
        meditation.dauerAnapana         = Int32(kursMeditation.anapanaDauer)
        meditation.dauerVipassana       = Int32(kursMeditation.vipassanaDauer)
        meditation.dauerMetta           = Int32(kursMeditation.mettaDauer)
        meditation.cloudNeedsUpdate     = true
        return meditation
    }
    //eine neue Meditation starten (erstellen)
    static func start(myMeditation:PublicMeditation) -> Meditation?{
        let meditation = NSEntityDescription.insertNewObject(forEntityName: "Meditation", into: context) as? Meditation
        meditation?.meditationsID    = UUID().uuidString
        meditation?.start            = myMeditation.startDate
        meditation?.dauerAnapana     = Int32(myMeditation.anapanaDauer)
        meditation?.dauerVipassana   = Int32(myMeditation.vipassanaDauer)
        meditation?.dauerMetta       = Int32(myMeditation.mettaDauer)
        meditation?.mettaOpenEnd     = myMeditation.mettaEndlos
        meditation?.name             = myMeditation.meditationTitle
        meditation?.cloudNeedsUpdate = true
        return meditation
    }
    // erstelle neu oder aktualisere bestehende Meditation (von Firebase)
    static func createOrUpdateMeditation(withChild snapshot:DataSnapshot?){
        guard let snapshot = snapshot,let meditation = getOrCreate(withID: snapshot.key) else {return}
        //delete, wenn als "delete" marktiert
        guard snapshot.valueAsDict?["deleted"] as? Bool != true else { meditation.delete(inFirebaseToo: false); return }
        meditation.name             = snapshot.valueAsDict?["name"] as? String
        meditation.start            = Date(timeIntervalSinceReferenceDate: snapshot.valueAsDict?["start"] as? TimeInterval ?? 0)
        meditation.dauerAnapana     = snapshot.valueAsDict?["dauerAnapana"] as? Int32 ?? 0
        meditation.dauerVipassana   = snapshot.valueAsDict?["dauerVipassana"] as? Int32 ?? 0
        meditation.dauerMetta       = snapshot.valueAsDict?["dauerMetta"] as? Int32 ?? 0
        meditation.inFirebase       = true
        if let kursID = snapshot.valueAsDict?["kursID"] as? String{ meditation.kurs = Kurs.getOrCreateEmpty(withID: kursID) }
        saveContext()
    }
    // bestehende Meditation mit ID finden oder neu erstellen
    static private func getOrCreate(withID medID:String) -> Meditation?{
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "meditationsID = %@", medID)
        if let meditation = (try? context.fetch(request))?.first    { return meditation }
        //neu erstellen (keine Meditation mit ID gefunden)
        let meditation = NSEntityDescription.insertNewObject(forEntityName: "Meditation", into: context) as? Meditation
        meditation?.meditationsID    = medID
        return meditation
    }
}

//✅
//MARK: static Methods - Meditationslisten holen
extension Meditation{
    //alle Meditationen
    static func getAll()->[Meditation]{
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        return (try? context.fetch(request)) ?? [Meditation]()
    }
    //alle Meditationen bis heute
    static func getAllTillToday()->[Meditation]{
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "start <= %@", Date() as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        return (try? context.fetch(request)) ?? [Meditation]()
    }
    //alle Meditationen - außer Kursmeditationen
    static func getAllOhneKurse()->[Meditation]{
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "kurs == nil")
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        return (try? context.fetch(request)) ?? [Meditation]()
    }
    //alle Meditationen, die noch nicht in Firebase sind
    static func getNotInFirebase()->[Meditation]{
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "inFirebase ==  false || inFirebase == nil")
        return (try? context.fetch(request)) ?? [Meditation]()
    }
    //alle Meditationen, die noch nicht in HealthKit sind
    static func getNotInHealthKit()->[Meditation]{
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSPredicate(format: "inHealthKit ==  false || inHealthKit == nil")
        return (try? context.fetch(request)) ?? [Meditation]()
    }
    //alle Meditationen innerhalb eines Zeitraums
    static func getZeitraum(start:Date?,ende:Date?)->[Meditation]{
        guard let start = start, let ende = ende else {return [Meditation]()}
        let request             = NSFetchRequest<Meditation>(entityName: "Meditation")
        request.predicate       = NSCompoundPredicate(andPredicateWithSubpredicates:
            [NSPredicate(format: "start >= %@",start.firstSecondOfDay! as CVarArg),
             NSPredicate(format: "start <= %@", ende.lastSecondOfDay! as CVarArg)])
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        return (try? context.fetch(request)) ?? [Meditation]()
    }
}

//✅
// Statistiken
extension Meditation{
    //GraphDaten für Statistik Seite
    static func getGraphValuesFor(graphTyp:GraphTypen,von:Date,bis:Date) -> [GraphValue]{
        var ergebnis            = [GraphValue]()
        switch graphTyp {
        case .GesamtdauerProWoche:
            guard let start = von.mondayOfWeek.firstSecondOfDay,let ende = bis.sundayOfWeek.lastSecondOfDay else{return [GraphValue]()}
            var date = start
            while ende.isGreaterThanDate(dateToCompare: date){
                guard let startWoche    = date.mondayOfWeek.firstSecondOfDay,let endeWoche = date.sundayOfWeek.lastSecondOfDay else{return [GraphValue]()}
                let gesamtDauerWoche    = Meditation.getZeitraum(start: startWoche, ende: endeWoche).map{$0.gesamtDauer}.reduce(0){$0+$1}
                date                    = endeWoche.addDays(1).mondayOfWeek.firstSecondOfDay!
                let text                = "\(startWoche.string("dd.MM."))"
                ergebnis.append(GraphValue(xLabelText: text, value: gesamtDauerWoche))
            }
        case .GesamtdauerProMonat:
            guard let start = von.startOfMonth.firstSecondOfDay,let ende = bis.endOfMonth.lastSecondOfDay else{return [GraphValue]()}
            var date = start
            while ende.isGreaterThanDate(dateToCompare: date){
                guard let startMonat    = date.startOfMonth.firstSecondOfDay,let endeMonat = date.endOfMonth.lastSecondOfDay else{return [GraphValue]()}
                let gesamtDauerMonat    = Meditation.getZeitraum(start: startMonat, ende: endeMonat).map{$0.gesamtDauer}.reduce(0){$0+$1}
                date                    = endeMonat.addDays(1).startOfMonth.firstSecondOfDay!
                let text                = startMonat.string("MMM").replacingOccurrences(of: ".", with: "") + "." + "\(startMonat.string("yy"))"
                ergebnis.append(GraphValue(xLabelText: text, value: gesamtDauerMonat))
            }
        case .GesamtdauerProTag:
            guard let start = von.firstSecondOfDay,let ende = bis.lastSecondOfDay else{return [GraphValue]()}
            var date = start
            while ende.isGreaterThanDate(dateToCompare: date){
                guard let startTag  = date.firstSecondOfDay,let endeTag = date.lastSecondOfDay else{return [GraphValue]()}
                let gesamtDauerTag  = Meditation.getZeitraum(start: startTag, ende: endeTag).map{$0.gesamtDauer}.reduce(0){$0+$1}
                date                = endeTag.addDays(1).firstSecondOfDay!
                let text            = startTag.string("dd.MM.")
                ergebnis.append(GraphValue(xLabelText: text, value: gesamtDauerTag))
            }
        }
        return ergebnis
    }
    //GesamtDauer berechnen
    static func gesamtDauer(von:Date,bis:Date) -> TimeInterval          { return Meditation.getZeitraum(start: von, ende: bis).map{$0.gesamtDauer}.reduce(0){$0+$1}  }
    static func gesamtDauer(meditationen:[Meditation]) -> TimeInterval  { return meditationen.map{$0.gesamtDauer}.reduce(0){$0+$1} }
    //calc Properties
    var gesamtDauer:TimeInterval    { return TimeInterval(dauerMetta + dauerAnapana + dauerVipassana) }
    var atLeastOneHour:Bool         { return gesamtDauer >= 60*60 }
    static var firstMeditationNotInKurs:Meditation?{ return Meditation.getAllOhneKurse().first }
}



//✅
// Kalender 
extension Meditation
{
    //Kalendereinträge für Tage holen
    static func getKalenderEintraege(days:[Date])->[[KalenderEintrag]]{
        var eintraege = [[KalenderEintrag]]()
        for day in days{
            let eintraegeDay = Meditation.getDay(day: day).map({$0.kalenderEintrag})
            eintraege.append(eintraegeDay)
        }
        return eintraege
    }
    //Protocol - EintragInKalender
    var eintragView:UIView{
        let eintrag         = MeditationsKalenderEintrag()
        eintrag.meditation  = self
        return eintrag
    }
    //helper - Meditationen eines Tages
    private class func getDay(day:Date)->[Meditation]{  return getZeitraum(start: day, ende: day)  }
    private var kalenderEintrag:KalenderEintrag{
        guard let start = start else{return KalenderEintrag()}
        return KalenderEintrag(starts: start as Date, ende: start.addingTimeInterval(gesamtDauer), view: eintragView)
    }
}

//✅
//Meditationen beenden, löschen, Pausen hinzufügen
// aufräumen
// FirebaseSnapshot
extension Meditation{
    //beenden
    func beendet(_ date:Date){
        let verstrichenOhnePause = Int32(date.timeIntervalSince(start! as Date) - gesamtPausenDauer)
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
    //Pause hinzufügen
    func addPause(start:Date,ende:Date){ if let pause = Dauer.new(start: start, ende: ende){ pausen?.adding(pause) } }
    //über Kalender geänderte Meditation aktualisieren
    func update(with timerData:TimerData) -> Meditation{
        dauerAnapana            = Int32(timerData.anapanaDauer)
        dauerVipassana          = Int32(timerData.vipassanaDauer)
        dauerMetta              = Int32(timerData.mettaDauer)
        cloudNeedsUpdate        = true
        return self
    }
    //löschen
    func delete(inFirebaseToo:Bool){
        HealthManager().deleteMeditation(meditation: self)
        if inFirebaseToo{ FirMeditations.deleteMeditation(meditation:self) }
        context.delete(self)
        saveContext()
    }
    //helper
    private var gesamtPausenDauer:TimeInterval{  return ((pausen as? Set<Dauer>) ?? Set<Dauer>()).map{$0.asTimeInterval}.reduce(0, +) }
    //FireBase Snapshot
    var firebaseData:[String:Any]?{
        guard let start = start else {return nil}
        var dict:[String:Any]        =      ["start"            : start.timeIntervalSinceReferenceDate,
                                             "dauerAnapana"     : dauerAnapana,
                                             "dauerVipassana"   : dauerVipassana,
                                             "dauerMetta"       : dauerMetta,
                                             "lastSync"         : Date().timeIntervalSinceReferenceDate ]
        if let kursID = kurs?.kursID    { dict["kursID" ]   = kursID }
        if let name = name              { dict["name"]      = name}
        return dict
    }
    //aufräumen
    // Meditationen kürzer als 5 minuten löschen
    static func cleanShortMeditations(){
        for meditation in Meditation.getAll(){
            if meditation.gesamtDauer < 5 * 60{
                meditation.delete(inFirebaseToo: true)
                print("deleted")
            }
        }
    }
}
