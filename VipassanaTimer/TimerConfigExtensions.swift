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


extension TimerConfig:MeditationConfigProto {
    //Protokol MeditationConfigProto
    var gesamtDauer: TimeInterval {
        get {  return TimeInterval(dauerGesamt) }
        set {  dauerGesamt = Int32(newValue)  }
    }
    var meditationTitle: String? {
        get { return name }
        set { name = newValue }
    }
    
    var anapanaDauer: TimeInterval {
        get { return TimeInterval(dauerAnapana) }
        set { dauerAnapana = Int32(newValue) }
    }
    
    var mettaDauer: TimeInterval {
        get { return TimeInterval(dauerMetta) }
        set { dauerMetta = Int32(newValue) }
    }
    
    var mettaEndlos: Bool {
        get { return mettaOpenEnd }
        set { mettaOpenEnd = newValue }
    }
    
    
    //new
    
    
    
    //holt alle TimerConfigs
    // falls keine vorhanden, wird einer erstellt
    class func getAll()->[TimerConfig]{
        let request             = NSFetchRequest<TimerConfig>(entityName: "TimerConfig")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        func fixOldVersion(timerConfigs:[TimerConfig]?) -> [TimerConfig]?{
            //alte version
            // hatte wert für vipassana (wird nun berechnet)
            // hatte keinen wert für gesamtDauer (wurde berechnet)
            guard let toFix = ( timerConfigs?.filter{$0.gesamtDauer == 0} ) else {return timerConfigs}
            for _toFix in toFix{ _ = _toFix.fixNewVersion()  }
            return timerConfigs
        }
        return fixOldVersion(timerConfigs: (try? context.fetch(request))) ?? [TimerConfig.create()]
    }
    
    
    //holt aktiven Timer
    class func getActive()->TimerConfig?{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<TimerConfig>(entityName: "TimerConfig")
        request.predicate       = NSPredicate(format: "isActive = true")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return ((try? context.fetch(request))?.first)?.fixNewVersion()
    }
    //erstellt neuen Timer
    class func create(gesamtDauer:TimeInterval = 60*60, anapanaDauer:TimeInterval = 5*60,mettaDauer:TimeInterval = 5*60,mettaEndlos:Bool = false,name:String? = NSLocalizedString("FirstMeditation", comment: "FirstMeditation")) -> TimerConfig{
        let newTimerConfig = NSEntityDescription.insertNewObject(forEntityName: "TimerConfig", into: context) as! TimerConfig
        newTimerConfig.gesamtDauer      = gesamtDauer
        newTimerConfig.anapanaDauer     = anapanaDauer
        newTimerConfig.mettaDauer       = mettaDauer
        newTimerConfig.mettaEndlos      = mettaEndlos
        newTimerConfig.name             = name
        saveContext()
        return newTimerConfig
    }
    //löscht Timer
    func delete(){
        context.delete(self)
        saveContext()
    }
    //setzt Timer aktiv
    func setActive(){
        for timerConfig in TimerConfig.getAll(){ timerConfig.isActive = false }
        isActive = true
        saveContext()
    }
    
    //MARK:helper
    private func fixNewVersion() -> TimerConfig{
        guard gesamtDauer == 0 else {return self}
        gesamtDauer = TimeInterval(dauerAnapana + dauerVipassana + dauerMetta)
        return self
    }
    
    
    
    //old
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
    
    
    //jetzt mit TimerConfig.create()
    static func createFirstTimer(){
        if TimerConfig.getAll().count == 0{
            let new     = TimerConfig.new(dauerAnapana: 5*60, dauerVipassana: 50*60, dauerMetta: 5*60, mettaOpenEnd: false)
            new?.name   = NSLocalizedString("FirstMeditation", comment: "FirstMeditation")
        }
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
    
    
    //löscht Timer die für die Anpassung einer Meditation im Kalender vorübergehend erstellt wurden
    class func deleteToDelete(){
        let request             = NSFetchRequest<TimerConfig>(entityName: "TimerConfig")
        request.predicate       = NSPredicate(format: "toDelete == YES")
        if let timerConfigs = try? context.fetch(request){
            for timerConfig in timerConfigs{ timerConfig.delete() }
        }
    }
}

