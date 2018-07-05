//
//  SoundFileDataCD.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData

extension SoundFileDataCD{
    
    
    
    static func create(soundFileData:SoundFileData)  -> SoundFileDataCD?{
        let soundFileDataCD = NSEntityDescription.insertNewObject(forEntityName: "SoundFileDataCD", into: context) as? SoundFileDataCD
        soundFileDataCD?.duration       = soundFileData.duration
        soundFileDataCD?.mettaDuration  = soundFileData.mettaDuration
        soundFileDataCD?.title          = soundFileData.title
        soundFileDataCD?.fireBaseTitle  = soundFileData.fireBaseTitle
        return soundFileDataCD
    }
    
    static func getAll() -> [SoundFileDataCD]{
        let request             = NSFetchRequest<SoundFileDataCD>(entityName: "SoundFileDataCD")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        return (try? context.fetch(request)) ?? [SoundFileDataCD]()
    }
    
    static func get(soundFileData:SoundFileData?) -> SoundFileDataCD?{
        guard let soundFileData = soundFileData else {return nil}
        let request             = NSFetchRequest<SoundFileDataCD>(entityName: "SoundFileDataCD")
        request.predicate       = NSPredicate(format: "fireBaseTitle = %@",soundFileData.fireBaseTitle)
        return (try? context.fetch(request))?.first
    }
    
    
    var soundFileData:SoundFileData?{
        guard let title = title, let fireBaseTitle = fireBaseTitle else {return nil}
        return SoundFileData(title: title, duration: duration, mettaDuration: mettaDuration, fireBaseTitle: fireBaseTitle)
    }

    
    func delete(){
        context.delete(self)
        saveContext()
    }
    
    var loacalSoundfileURL:URL?{
        guard let title = title else {return nil}
        let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
        return  docURL?.appendingPathComponent("\(title).mp3")
    }
}
