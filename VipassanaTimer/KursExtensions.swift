//
//  KursExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 30.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import CoreData
import Firebase

//✅
//Kurse finden und neu erstellen
extension Kurs{
    //erstellt neuen Kurs und KursMeditationen
    static func new(kursData:KursData) -> Kurs?{
        let kurs = NSEntityDescription.insertNewObject(forEntityName: "Kurs", into: context) as? Kurs
        kurs?.name              = kursData.title
        kurs?.kursTage          = Int16(kursData.kursTage)
        kurs?.start             = kursData.startTag
        kurs?.kursID            = UUID().uuidString
        kurs?.teacher           = kursData.lehrer
        for kursMeditation in kursData.meditationSet{ kurs?.addMeditation(  Meditation.new(kursMeditation: kursMeditation ) ) }
        return kurs
    }
    //bestehenden Kurs aktualisieren oder neu erstellen
    // aus Firebase
    static func createOrUpdate(withChild snapshot:DataSnapshot?){
        guard let snapshot = snapshot, let kurs = Kurs.getOrCreateEmpty(withID: snapshot.key) else {return}
        guard snapshot.valueAsDict?["deleted"] as? Bool != true else {
            kurs.delete(inFirebaseToo: false)
            return
        }
        kurs.name                   = snapshot.valueAsDict?["name"] as? String
        kurs.kursTage               = snapshot.valueAsDict?["kurstage"] as? Int16 ?? 0
        kurs.start                  = Date(timeIntervalSinceReferenceDate: snapshot.valueAsDict?["start"] as? TimeInterval ?? 0)
        kurs.inFirebase             = true
        saveContext()
    }
    // bestehenden Kurs finden oder leeren Kurs erstellen
    static func getOrCreateEmpty(withID kursID:String) -> Kurs?{
        let request             = NSFetchRequest<Kurs>(entityName: "Kurs")
        request.predicate       = NSPredicate(format: "kursID == %@", kursID)
        let kurs                = (try? context.fetch(request))?.first ?? NSEntityDescription.insertNewObject(forEntityName: "Kurs", into: context) as? Kurs
        kurs?.kursID            = kursID
        return kurs
    }
}

//✅
//KursListen holen
extension Kurs{
    //alle Kurse holen
    class func getAll()->[Kurs]{
        let request             = NSFetchRequest<Kurs>(entityName: "Kurs")
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        return (try? context.fetch(request)) ?? [Kurs]()
    }
    //alle Kurse bis heute holen
    // z.B. für die Anzahl von KurstTagen
    class func getAllTillToday()->[Kurs]{
        let request             = NSFetchRequest<Kurs>(entityName: "Kurs")
        request.predicate       = NSPredicate(format: "start <= %@", Date() as CVarArg)
        return (try? context.fetch(request)) ?? [Kurs]()
    }
    //alle Kurse, die noch nicht in Firebase sind holen
    static func getNotInFirebase()->[Kurs]{
        let request             = NSFetchRequest<Kurs>(entityName: "Kurs")
        request.predicate       = NSPredicate(format: "inFirebase ==  false || inFirebase == nil")
        return (try? context.fetch(request)) ?? [Kurs]()
    }
}

//✅
// löschen, FirebaseSnapshot
// calcProperties und helper
extension Kurs{
    //einen Kurs, mit Meditationen löschen
    // aus Firebase löschen
    func delete(inFirebaseToo:Bool){
        for case let meditation as Meditation in meditations!{ meditation.delete(inFirebaseToo: true) }
        if inFirebaseToo{ FirKurse.deleteKurs(kurs: self) }
        context.delete(self)
        saveContext()
    }
    
    //FirebaseSnapshot
    var firebaseData:[String:Any]?{
        var dict:[String:Any] =     ["kurstage":kursTage,
                                     "start":start?.timeIntervalSinceReferenceDate ?? 0,
                                     "lastSync" : Date().timeIntervalSinceReferenceDate ]
        if let name = name { dict["name"] = name }
        return dict
    }

    //calc Properties
    var startDate:Date                          { return sortedMeditations.first?.start ?? start ?? Date() }
    var endDate:Date                            { return sortedMeditations.last?.start ?? startDate }
    var sortedMeditations:[Meditation]          { return (meditations as? Set<Meditation>)?.sorted(by: {$0.start?.compare($1.start! as Date) == .orderedAscending }) ?? [Meditation]()  }
    var gesamtDauerMeditationen:TimeInterval    { return sortedMeditations.map{$0.gesamtDauer}.reduce(0){$0+$1} }
    
    //helper
    private func addMeditation(_ meditation:Meditation?){
        guard let meditation = meditation else {return}
        addToMeditations(meditation)
    }
}
