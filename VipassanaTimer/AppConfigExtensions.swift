//
//  AppConfigExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.02.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

extension AppConfig{
    
    class func get()->AppConfig?{
        
        let request             = NSFetchRequest<AppConfig>(entityName: "AppConfig")
        
        if let appConfig = (try? context.fetch(request))?.first{
            return appConfig
        }
        if let appConfig = NSEntityDescription.insertNewObject(forEntityName: "AppConfig", into: context) as? AppConfig{
            return appConfig
        }
        return nil
    }
    
    static func setNotification(snapshot:DataSnapshot){
        guard get()?.firLastNotification != snapshot.key else {return}
        mainModel.newNotification.value = (key:snapshot.key,message:snapshot.value as? String)
    }
}
