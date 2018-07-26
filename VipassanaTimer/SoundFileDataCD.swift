//
//  SoundFileDataCD.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import CoreData

//✅
// SoundFileData in CoreData
extension SoundFileDataCD{
    //erstellt neues CoreData Soundfile Objekt
    static func create(soundFileData:SoundFileData)  -> SoundFileDataCD?{
        let soundFileDataCD = NSEntityDescription.insertNewObject(forEntityName: "SoundFileDataCD", into: context) as? SoundFileDataCD
        soundFileDataCD?.duration       = soundFileData.duration
        soundFileDataCD?.mettaDuration  = soundFileData.mettaDuration
        soundFileDataCD?.title          = soundFileData.title
        soundFileDataCD?.fireBaseTitle  = soundFileData.fireBaseTitle
        return soundFileDataCD
    }
    //aktualisiert bestehendes CoreData Soundfile Objekt
    static func update(soundFileData:SoundFileData?) -> SoundFileData?{
        guard let soundFileData = soundFileData else {return nil}
        let data = get(soundFileData: soundFileData)
        data?.duration      = soundFileData.duration
        data?.mettaDuration = soundFileData.mettaDuration
        data?.title         = soundFileData.title
        data?.fireBaseTitle = soundFileData.fireBaseTitle
        saveContext()
        return soundFileData
    }
    // holt alle CoreData SoundFileData Objekte
    static func getAll() -> [SoundFileDataCD]{
        let request             = NSFetchRequest<SoundFileDataCD>(entityName: "SoundFileDataCD")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return (try? context.fetch(request)) ?? [SoundFileDataCD]()
    }
    // holt ein bestimmtes CoreData SoundFileData Objekt
    static func get(soundFileData:SoundFileData?) -> SoundFileDataCD?{
        guard let soundFileData = soundFileData else {return nil}
        let request             = NSFetchRequest<SoundFileDataCD>(entityName: "SoundFileDataCD")
        request.predicate       = NSPredicate(format: "fireBaseTitle = %@",soundFileData.fireBaseTitle)
        return (try? context.fetch(request))?.first
    }
    // Das SoundFileData Objekt (von CoreData Objekt abgeleitet)
    var soundFileData:SoundFileData?{
        guard let title = title, let fireBaseTitle = fireBaseTitle else {return nil}
        return SoundFileData(title: title, duration: duration, mettaDuration: mettaDuration, fireBaseTitle: fireBaseTitle)
    }
    
    func delete(){
        context.delete(self)
        saveContext()
    }
}
