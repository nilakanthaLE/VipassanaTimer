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
        //10 Tagekurs
        for _kurs in getAll(){
            _kurs.delete()
        }
        if get(name: "10-Tage Kurs") == nil{
            let kursTemplate = new(name: "10-Tage Kurs")
            let tagNull = Date.init(timeIntervalSince1970: 0)
            
            //0. Tag
            var name                = "nullter Tag"
            var addedTimeToDayNull  = TimeInterval(20*60*60)
            var start               = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation    = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //1.Tag
            name                    = "erster Tag I"
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "erster Tag II"
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "erster Tag III"
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "erster Tag IV"
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "erster Tag V"
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "erster Tag VI"
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "erster Tag VII"
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "erster Tag VIII"
            addedTimeToDayNull      = TimeInterval(1*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 2700, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //2.Tag
            name                    = "zweiter Tag I"
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zweiter Tag II"
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zweiter Tag III"
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zweiter Tag IV"
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zweiter Tag V"
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zweiter Tag VI"
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zweiter Tag VII"
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zweiter Tag VIII"
            addedTimeToDayNull      = TimeInterval(2*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 2700, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //3.Tag
            name                    = "dritter Tag I"
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "dritter Tag II"
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "dritter Tag III"
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "dritter Tag IV"
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "dritter Tag V"
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "dritter Tag VI"
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 5400, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "dritter Tag VII"
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "dritter Tag VIII"
            addedTimeToDayNull      = TimeInterval(3*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 2700, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //4.Tag
            name                    = "vierter Tag I"
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "vierter Tag II"
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 3600, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "vierter Tag III"
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 7200, dauerVipassana: 0, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "vierter Tag IV"
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "vierter Tag V"
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "vierter Tag VI"
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "vierter Tag VII"
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "vierter Tag VIII"
            addedTimeToDayNull      = TimeInterval(4*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //5.Tag
            name                    = "fünfter Tag I"
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "fünfter Tag II"
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "fünfter Tag III"
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "fünfter Tag IV"
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "fünfter Tag V"
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "fünfter Tag VI"
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "fünfter Tag VII"
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "fünfter Tag VIII"
            addedTimeToDayNull      = TimeInterval(5*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //6.Tag
            name                    = "sechster Tag I"
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "sechster Tag II"
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "sechster Tag III"
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "sechster Tag IV"
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "sechster Tag V"
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "sechster Tag VI"
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "sechster Tag VII"
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "sechster Tag VIII"
            addedTimeToDayNull      = TimeInterval(6*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //7.Tag
            name                    = "siebenter Tag I"
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "siebenter Tag II"
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "siebenter Tag III"
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "siebenter Tag IV"
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "siebenter Tag V"
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "siebenter Tag VI"
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "siebenter Tag VII"
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "siebenter Tag VIII"
            addedTimeToDayNull      = TimeInterval(7*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //8.Tag
            name                    = "achter Tag I"
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "achter Tag II"
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "achter Tag III"
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "achter Tag IV"
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "achter Tag V"
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "achter Tag VI"
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "achter Tag VII"
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "achter Tag VIII"
            addedTimeToDayNull      = TimeInterval(8*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //9.Tag
            name                    = "neunter Tag I"
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "neunter Tag II"
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "neunter Tag III"
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "neunter Tag IV"
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "neunter Tag V"
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "neunter Tag VI"
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 5400, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "neunter Tag VII"
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "neunter Tag VIII"
            addedTimeToDayNull      = TimeInterval(9*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2700, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //10.Tag
            name                    = "zehnter Tag I"
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zehnter Tag II"
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 8*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3600, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zehnter Tag III"
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 9*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zehnter Tag IV"
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 13*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 4800, dauerMetta: 600){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zehnter Tag V"
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 14*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3000, dauerMetta:600){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zehnter Tag VI"
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 15*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 4800, dauerMetta: 600){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zehnter Tag VII"
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 18*60*60 + 0*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 3000, dauerMetta: 600){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            name                    = "zehnter Tag VIII"
            addedTimeToDayNull      = TimeInterval(10*24*60*60 + 20*60*60 + 15*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 2100, dauerMetta: 600){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
            
            //11.Tag
            name                    = "elfter Tag I"
            addedTimeToDayNull      = TimeInterval(11*24*60*60 + 4*60*60 + 30*60)
            start                   = tagNull.addingTimeInterval(addedTimeToDayNull)
            if let meditation       = MeditationTemplate.new(start: start, name: name, dauerAnapana: 0, dauerVipassana: 7200, dauerMetta: 0){
                kursTemplate?.addToMeditationsTemplates([meditation])
            }
        }
    } 
}
