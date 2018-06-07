//
//  AppUserExtensions.swift
//  
//
//  Created by Matthias Pochmann on 19.07.17.
//

import Foundation
let context             = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

import Foundation
import CoreData
import UIKit
import Firebase

extension AppUser{
    
    class func get()->AppUser?{
        
        let request             = NSFetchRequest<AppUser>(entityName: "AppUser")
        if let user = (try? context.fetch(request))?.first {
            return user
        }
        if let user = NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser  {
            return user
        }
        return nil
    }
    
    
    
    var firebaseData:[String:Any]{
        let user        = Meditierender.get()
        let iOSVersion  = UIDevice.current.systemVersion
        let version     = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        return ["ID":firebaseID ?? "_fehlt_",
                "spitzname":user?.nickName ?? "_fehlt_",
                "querySpitzname":user?.nickName?.lowercased() ?? "_fehlt_",
                "spitzname_sichtbarkeit":user?.nickNameSichtbarkeit ?? 0,
                "statistik_sichtbarkeit":user?.statistikSichtbarkeit ?? 0,
                "iOS_Version":iOSVersion,
                "App_Version":version ?? "_fehlt_",
                "isNewVersion":true,
                "lastUpdate" : String(describing: Date()),
                "statisticStart" : StatistikUeberblickDaten.startDateFuerDurchschnitt?.timeIntervalSinceReferenceDate ?? 0 ]
    }
}
