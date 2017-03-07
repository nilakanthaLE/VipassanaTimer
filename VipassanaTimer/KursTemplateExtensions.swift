//
//  KursTemplateExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 30.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension KursTemplate{
    
    class func new(name:String?)->KursTemplate?{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if let kursTemplate = NSEntityDescription.insertNewObject(forEntityName: "KursTemplate", into: context) as? KursTemplate{
            kursTemplate.name             = name
            return kursTemplate
        }
        return nil
    }
    
    class func getAll()->[KursTemplate]{
        let context             = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<KursTemplate>(entityName: "KursTemplate")
        if let kursTemplate     = try? context.fetch(request){
            return kursTemplate
        }
        return [KursTemplate]()
        
    }
    
    class func get(name:String)->KursTemplate?{
        let context             = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<KursTemplate>(entityName: "KursTemplate")
        
        request.predicate       = NSPredicate(format: "name == %@", name)
        if let kursTemplate     = (try? context.fetch(request))?.first{
                return kursTemplate
        }
        return nil
        
    }
    func delete(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(self)
    }
    
    var sortedMeditations:[MeditationTemplate]{
        guard let meditations = meditationsTemplates as? Set<MeditationTemplate> else{return [MeditationTemplate]()}
        return meditations.sorted(by: {$0.start?.compare($1.start as! Date) == .orderedAscending })
    }
    
    class func createKursTemplates(){
        let course = NSLocalizedString("TenDayCourse", comment: "TenDayCourse")
        if get(name: course) == nil{
            let kursTemplate = new(name: course)
            let tagNull = Date.init(timeIntervalSince1970: 0)
            
            kursTemplate?.kursTage   = 10
            //0. Tag
            var name                = NSLocalizedString("TenDayCourse0", comment: "TenDayCourse0")
            var addedTimeToDayNull  = TimeInterval(20*60*60)
            var start               = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation    = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //1.Tag
            name                    = NSLocalizedString("TenDayCourse1_1", comment: "TenDayCourse1_1")
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse1_2", comment: "TenDayCourse1_2")
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse1_3", comment: "TenDayCourse1_3")
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse1_4", comment: "TenDayCourse1_4")
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse1_5", comment: "TenDayCourse1_5")
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse1_6", comment: "TenDayCourse1_6")
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse1_7", comment: "TenDayCourse1_7")
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse1_8", comment: "TenDayCourse1_8")
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 2700, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //2.Tag
            name                    = NSLocalizedString("TenDayCourse2_1", comment: "TenDayCourse2_1")
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse2_2", comment: "TenDayCourse2_2")
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse2_3", comment: "TenDayCourse2_3")
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse2_4", comment: "TenDayCourse2_4")
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse2_5", comment: "TenDayCourse2_5")
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse2_6", comment: "TenDayCourse2_6")
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse2_7", comment: "TenDayCourse2_7")
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse2_8", comment: "TenDayCourse2_8")
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 2700, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //3.Tag
            name                    = NSLocalizedString("TenDayCourse3_1", comment: "TenDayCourse3_1")
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse3_2", comment: "TenDayCourse3_2")
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse3_3", comment: "TenDayCourse3_3")
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse3_4", comment: "TenDayCourse3_4")
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse3_5", comment: "TenDayCourse3_5")
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse3_6", comment: "TenDayCourse3_6")
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse3_7", comment: "TenDayCourse3_7")
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse3_8", comment: "TenDayCourse3_8")
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 2700, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //4.Tag
            name                    = NSLocalizedString("TenDayCourse4_1", comment: "TenDayCourse4_1")
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse4_2", comment: "TenDayCourse4_2")
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse4_3", comment: "TenDayCourse4_3")
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse4_4", comment: "TenDayCourse4_4")
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse4_5", comment: "TenDayCourse4_5")
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse4_6", comment: "TenDayCourse4_6")
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse4_7", comment: "TenDayCourse4_7")
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse4_8", comment: "TenDayCourse4_8")
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //5.Tag
            name                    = NSLocalizedString("TenDayCourse5_1", comment: "TenDayCourse5_1")
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse5_2", comment: "TenDayCourse5_2")
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse5_3", comment: "TenDayCourse5_3")
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse5_4", comment: "TenDayCourse5_4")
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse5_5", comment: "TenDayCourse5_5")
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse5_6", comment: "TenDayCourse5_6")
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse5_7", comment: "TenDayCourse5_7")
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse5_8", comment: "TenDayCourse5_8")
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //6.Tag
            name                    = NSLocalizedString("TenDayCourse6_1", comment: "TenDayCourse6_1")
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse6_2", comment: "TenDayCourse6_2")
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse6_3", comment: "TenDayCourse6_3")
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse6_4", comment: "TenDayCourse6_4")
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse6_5", comment: "TenDayCourse6_5")
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse6_6", comment: "TenDayCourse6_6")
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse6_7", comment: "TenDayCourse6_7")
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse6_8", comment: "TenDayCourse6_8")
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //7.Tag
            name                    = NSLocalizedString("TenDayCourse7_1", comment: "TenDayCourse7_1")
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse7_2", comment: "TenDayCourse7_2")
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse7_3", comment: "TenDayCourse7_3")
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse7_4", comment: "TenDayCourse7_4")
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse7_5", comment: "TenDayCourse7_5")
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse7_6", comment: "TenDayCourse7_6")
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse7_7", comment: "TenDayCourse7_7")
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse7_8", comment: "TenDayCourse7_8")
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //8.Tag
            name                    = NSLocalizedString("TenDayCourse8_1", comment: "TenDayCourse8_1")
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse8_2", comment: "TenDayCourse8_2")
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse8_3", comment: "TenDayCourse8_3")
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse8_4", comment: "TenDayCourse8_4")
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse8_5", comment: "TenDayCourse8_5")
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse8_6", comment: "TenDayCourse8_6")
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse8_7", comment: "TenDayCourse8_7")
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse8_8", comment: "TenDayCourse8_8")
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //9.Tag
            name                    = NSLocalizedString("TenDayCourse9_1", comment: "TenDayCourse9_1")
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse9_2", comment: "TenDayCourse9_2")
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse9_3", comment: "TenDayCourse9_3")
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse9_4", comment: "TenDayCourse9_4")
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse9_5", comment: "TenDayCourse9_5")
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse9_6", comment: "TenDayCourse9_6")
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse9_7", comment: "TenDayCourse9_7")
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse9_8", comment: "TenDayCourse9_8")
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //10.Tag
            name                    = NSLocalizedString("TenDayCourse10_1", comment: "TenDayCourse10_1")
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse10_2", comment: "TenDayCourse10_2")
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse10_3", comment: "TenDayCourse10_3")
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse10_4", comment: "TenDayCourse10_4")
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 4800, dauerMetta: 600){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse10_5", comment: "TenDayCourse10_5")
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3000, dauerMetta:600){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse10_6", comment: "TenDayCourse10_6")
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 4800, dauerMetta: 600){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse10_7", comment: "TenDayCourse10_7")
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3000, dauerMetta: 600){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = NSLocalizedString("TenDayCourse10_8", comment: "TenDayCourse10_8")
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2100, dauerMetta: 600){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //11.Tag
            name                    = NSLocalizedString("TenDayCourse11", comment: "TenDayCourse11")
            addedTimeToDayNull      = TimeInterval(11*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        }
    } 
}
