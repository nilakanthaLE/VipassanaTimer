//
//  TimerConfigExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData
import UIKit


extension TimerConfig {
    
    class func new(dauerAnapana:Int32,dauerVipassana:Int32,dauerMetta:Int32,mettaOpenEnd:Bool)->TimerConfig?{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let newTimerConfig = NSEntityDescription.insertNewObject(forEntityName: "TimerConfig", into: context) as? TimerConfig{
            newTimerConfig.dauerAnapana    = dauerAnapana
            newTimerConfig.dauerMetta      = dauerMetta
            newTimerConfig.dauerVipassana  = dauerVipassana
            newTimerConfig.mettaOpenEnd    = mettaOpenEnd
            return newTimerConfig
        }
        return nil
    }
    
    
    
    class func getAll()->[TimerConfig]{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let request             = NSFetchRequest<TimerConfig>(entityName: "TimerConfig")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        if let timerConfigs = (try? context.fetch(request)){
            return timerConfigs
        }
        return [TimerConfig]()
    }
    func delete(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(self)
    }
    func setActive(){
        for timerConfig in TimerConfig.getAll(){
            timerConfig.isActive = false
        }
        isActive = true
    }
    var gesamtDauer:TimeInterval{
        return TimeInterval(dauerAnapana + dauerVipassana + dauerMetta)
    }
    
    //holt den aktiven Timer oder erstellt neuen aktiven Timer
    class func getActive()->TimerConfig?{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<TimerConfig>(entityName: "TimerConfig")
        request.predicate       = NSPredicate(format: "isActive = true")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        if let timerConfig = (try? context.fetch(request))?.first{
            return timerConfig
        }
        return nil
    }
    class private func get(dauerAnapana:Int32,dauerVipassana:Int32,dauerMetta:Int32,mettaOpenEnd:Bool,name:String?)->TimerConfig?{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<TimerConfig>(entityName: "TimerConfig")
        if name == nil{
            request.predicate       = NSPredicate(format: "dauerAnapana == \(dauerAnapana) && dauerVipassana == \(dauerVipassana) && dauerMetta == \(dauerMetta) && mettaOpenEnd == \(mettaOpenEnd) && name == nil")
        }else{
            request.predicate       = NSPredicate(format: "dauerAnapana == \(dauerAnapana) && dauerVipassana == \(dauerVipassana) && dauerMetta == \(dauerMetta) && mettaOpenEnd == \(mettaOpenEnd) && name == %@",name!)
        }
        
        if let timerConfig = (try? context.fetch(request))?.first{
            timerConfig.toDelete    = false
            return timerConfig
        }
        if let timerConfig      = TimerConfig.new(dauerAnapana: dauerAnapana, dauerVipassana: dauerVipassana, dauerMetta:dauerMetta, mettaOpenEnd: mettaOpenEnd){
            timerConfig.name        = name
            timerConfig.toDelete    = false
            return timerConfig
        }
        return nil
    }
    class func get(with meditation:Meditation) ->TimerConfig?{
        let anzahlVorher = getAll().count
        guard let timerConfig = TimerConfig.get(dauerAnapana: meditation.dauerAnapana, dauerVipassana: meditation.dauerVipassana, dauerMetta: meditation.dauerMetta, mettaOpenEnd: meditation.mettaOpenEnd, name: meditation.name) else {return nil}
        //wenn Timer neu erstellt wird
        if anzahlVorher < getAll().count{
            timerConfig.toDelete    = true
            timerConfig.name        = (timerConfig.name ?? "") + "*"
        }
        return timerConfig
    }
    class func deleteToDelete(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<TimerConfig>(entityName: "TimerConfig")
        request.predicate       = NSPredicate(format: "toDelete == YES")
        if let timerConfigs = try? context.fetch(request){
            for timerConfig in timerConfigs{
                timerConfig.delete()
            }
        }
    }
}

