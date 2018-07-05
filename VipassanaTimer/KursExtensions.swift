//
//  KursExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 30.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import Firebase

extension Kurs{
    
    
    class func new(kursData:KursData) -> Kurs?{
        let kurs = NSEntityDescription.insertNewObject(forEntityName: "Kurs", into: context) as? Kurs
        kurs?.name              = kursData.title
        kurs?.kursTage          = Int16(kursData.kursTage)
        kurs?.start             = kursData.startTag
        kurs?.kursID            = UUID().uuidString
        kurs?.teacher           = kursData.lehrer
        
        for kursMeditation in kursData.meditationSet{ kurs?.addMeditation(  Meditation.new(kursMeditation: kursMeditation) ) }
        return kurs
    }
    
    func addMeditation(_ meditation:Meditation?){
        guard let meditation = meditation else {return}
        addToMeditations(meditation)
    }
    
    
    var startDate:Date{ return sortedMeditations.first?.start ?? start ?? Date() }
    var endDate:Date{ return sortedMeditations.last?.start ?? startDate }
    var sortedMeditations:[Meditation]{ return (meditations as? Set<Meditation>)?.sorted(by: {$0.start?.compare($1.start! as Date) == .orderedAscending }) ?? [Meditation]()  }
    
    func delete(inFirebaseToo:Bool){
        print("Kurs delete")
        for case let meditation as Meditation in meditations!{ meditation.delete(inFirebaseToo: true) }
        if inFirebaseToo{ FirKurse.deleteKurs(kurs: self) }
        context.delete(self)
        saveContext()
    }
    
    //old
    class func new(template:KursTemplate,start:Date)->Kurs?{
        
        if let kurs = NSEntityDescription.insertNewObject(forEntityName: "Kurs", into: context) as? Kurs{
            kurs.name               = template.name
            kurs.kursTage           = template.kursTage
            kurs.kursTemplate       = template
            kurs.start              = start
            kurs.kursID             = UUID().uuidString
            guard let meditations = template.meditationsTemplates as? Set<MeditationTemplate> else {return nil}
            for meditationTemplate in meditations{
                guard let timeToAdd = meditationTemplate.start?.timeIntervalSince1970 else {return nil}
                guard let newStartDate    = start.firstSecondOfDay?.addingTimeInterval(timeToAdd) else {return nil}
                guard let meditation      = Meditation.new(template: meditationTemplate, start: newStartDate) else {return nil}
                kurs.addToMeditations(meditation)
            }
            FirKurse.update(kurs: kurs)
            return kurs
        }
        return nil
    }
    
    var firebaseData:[String:Any]?{
        return ["name":name ?? "_fehlt_",
                "kurstage":kursTage,
                "start":start?.timeIntervalSinceReferenceDate ?? 0,
                "lastSync" : Date().timeIntervalSinceReferenceDate ]
    }
    static func getOrCreateEmpty(withID kursID:String) -> Kurs?{
        print("Kurs getOrCreateEmpty")
        let request             = NSFetchRequest<Kurs>(entityName: "Kurs")
        request.predicate       = NSPredicate(format: "kursID == %@", kursID)
        if let kurs = (try? context.fetch(request))?.first{
            return kurs
        }
        if let kurs = NSEntityDescription.insertNewObject(forEntityName: "Kurs", into: context) as? Kurs{
            kurs.kursID = kursID
            return kurs
        }
        print("return getOrCreateEmpty nil")
        return nil
    }

    static func createOrUpdate(withChild snapshot:DataSnapshot?){
        print("Kurs ....")
        guard let snapshot = snapshot, let kurs = Kurs.getOrCreateEmpty(withID: snapshot.key) else {return}
        guard snapshot.valueAsDict?["deleted"] as? Bool != true else {
            kurs.delete(inFirebaseToo: false); return
            
        }
        
        kurs.name                   = snapshot.valueAsDict?["name"] as? String
        kurs.kursTage               = snapshot.valueAsDict?["kurstage"] as? Int16 ?? 0
        kurs.start                  = Date(timeIntervalSinceReferenceDate: snapshot.valueAsDict?["start"] as? TimeInterval ?? 0)
        kurs.inFirebase             = true
        saveContext()
    }
    static func getNotInFirebase()->[Kurs]{
        let request             = NSFetchRequest<Kurs>(entityName: "Kurs")
        request.predicate       = NSPredicate(format: "inFirebase ==  false || inFirebase == nil")
        if let kurse = (try? context.fetch(request)){
            return kurse
        }
        return [Kurs]()
    }
    
    
    class func getAll()->[Kurs]{
        let request             = NSFetchRequest<Kurs>(entityName: "Kurs")
        request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: true)]
        if let kurse = try? context.fetch(request){
            return kurse
        }
        return [Kurs]()
    }
    class func getAllTillToday()->[Kurs]{
        let request             = NSFetchRequest<Kurs>(entityName: "Kurs")
        request.predicate       = NSPredicate(format: "start <= %@", Date() as CVarArg)
        if let kurse = try? context.fetch(request){
            return kurse
        }
        return [Kurs]()
    }
    
    
    var gesamtDauerMeditationen:TimeInterval{
        return sortedMeditations.map{$0.gesamtDauer}.reduce(0){$0+$1}
    }
}
