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

extension Kurs{
    
    class func new(template:KursTemplate,start:Date)->Kurs?{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if let kurs = NSEntityDescription.insertNewObject(forEntityName: "Kurs", into: context) as? Kurs{
            kurs.name               = template.name
            kurs.kursTage           = template.kursTage
            kurs.kursTemplate       = template
            kurs.start              = start
            guard let meditations = template.meditationsTemplates as? Set<MeditationTemplate> else {return nil}
            for meditationTemplate in meditations{
                guard let timeToAdd = meditationTemplate.start?.timeIntervalSince1970 else {return nil}
                guard let newStartDate    = start.firstSecondOfDay?.addingTimeInterval(timeToAdd) else {return nil}
                guard let meditation      = Meditation.new(template: meditationTemplate, start: newStartDate) else {return nil}
                kurs.addToMeditations(meditation)
            }
            return kurs
        }
        return nil
    }
    
    class func getAll()->[Kurs]{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<Kurs>(entityName: "Kurs")
        if let kurse = try? context.fetch(request){
            return kurse
        }
        return [Kurs]()
    }
    class func getAllTillToday()->[Kurs]{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<Kurs>(entityName: "Kurs")
        request.predicate       = NSPredicate(format: "start <= %@", Date() as CVarArg)
        if let kurse = try? context.fetch(request){
            return kurse
        }
        return [Kurs]()
    }
    func delete(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(self)
    }
    var sortedMeditations:[Meditation]{
        guard let meditations = meditations as? Set<Meditation> else{return [Meditation]()}
        return meditations.sorted(by: {$0.start?.compare($1.start! as Date) == .orderedAscending })
    }
    var gesamtDauerMeditationen:TimeInterval{
        return sortedMeditations.map{$0.gesamtDauer}.reduce(0){$0+$1}
    }
}
