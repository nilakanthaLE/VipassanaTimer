//
//  TimerConfigExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import CoreData

//✅
// Liste holen
extension TimerConfig{
    //holt alle TimerConfigs
    // falls keine vorhanden, wird einer erstellt
    class func getAll()->[TimerConfig]{
        let request             = NSFetchRequest<TimerConfig>(entityName: "TimerConfig")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let configs             = (try? context.fetch(request)) ?? [TimerConfig]()
        if configs.count == 0   { return [TimerConfig.create()]}
        return fixOldVersion(timerConfigs: configs )
    }
    
    //helper
    private static func fixOldVersion(timerConfigs:[TimerConfig]) -> [TimerConfig]{
        //alte version
        // hatte wert für vipassana (wird nun berechnet)
        // hatte keinen wert für gesamtDauer (wurde berechnet)
        for _toFix in timerConfigs.filter({$0.gesamtDauer == 0})  { _ = _toFix.fixNewVersion()  }
        return timerConfigs
    }
    private func fixNewVersion() -> TimerConfig{
        guard gesamtDauer == 0 else {return self}
        gesamtDauer = TimeInterval(dauerAnapana + dauerVipassana + dauerMetta)
        return self
    }
}

//✅
//neuen Timer erstellen
// aktiven Timer holen
// timer aktiv setzen
extension TimerConfig {
    //erstellt neuen Timer
    class func create(gesamtDauer:TimeInterval = 60*60,
                      anapanaDauer:TimeInterval = 5*60,
                      mettaDauer:TimeInterval = 5*60,
                      mettaEndlos:Bool = false,
                      name:String? = NSLocalizedString("FirstMeditation", comment: "FirstMeditation")) -> TimerConfig{
        
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
    //holt aktiven Timer
    class func getActive()->TimerConfig?{
        let request             = NSFetchRequest<TimerConfig>(entityName: "TimerConfig")
        request.predicate       = NSPredicate(format: "isActive = true")
        return ((try? context.fetch(request))?.first)?.fixNewVersion()
    }
}

//✅
//Protokol MeditationConfigProto
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
}
