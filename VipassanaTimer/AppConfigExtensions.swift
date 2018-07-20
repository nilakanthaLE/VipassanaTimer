//
//  AppConfigExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.02.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import CoreData
import Firebase
import ReactiveSwift

//Benachrichtigung über Firebase
let newNotification             = MutableProperty<(key:String,message:String?)>((key:"1",message:nil))

//✅
//AppConfig
// sichert App relevante Informationen
extension AppConfig{
    // AppConfig holen oder neu erstellen
    class func get()->AppConfig?{
        let request             = NSFetchRequest<AppConfig>(entityName: "AppConfig")
        if let appConfig = (try? context.fetch(request))?.first{ return appConfig }
        return NSEntityDescription.insertNewObject(forEntityName: "AppConfig", into: context) as? AppConfig
    }
    // Benachichtigung anzeigebn, falls neu
    static func setNotification(snapshot:DataSnapshot){
        guard get()?.firLastNotification != snapshot.key else {return}
        newNotification.value = (key:snapshot.key,message:snapshot.value as? String)
    }
}
