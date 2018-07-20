//
//  AppUserExtensions.swift
//  
//
//  Created by Matthias Pochmann on 19.07.17.
//

import CoreData
import UIKit

//✅
//AppUser
extension AppUser{
    //den AppUser holen
    class func get()->AppUser?{
        let request             = NSFetchRequest<AppUser>(entityName: "AppUser")
        if let user             = (try? context.fetch(request))?.first  { return user }
        return NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser 
    }
    //FirebaseSnapshot
    var firebaseData:[String:Any]{
        let user        = Meditierender.get()
        let version     = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        var dict:[String:Any] = ["spitzname_sichtbarkeit":user?.nickNameSichtbarkeit ?? 0,
                                "statistik_sichtbarkeit":user?.statistikSichtbarkeit ?? 0,
                                "iOS_Version":UIDevice.current.systemVersion,
                                "isNewVersion":true,
                                "lastUpdate" : String(describing: Date()),
                                "statisticStart" : StatistikUeberblickDaten.startDateFuerDurchschnitt?.timeIntervalSinceReferenceDate ?? 0 ]
        if let firebaseID = firebaseID                      { dict["ID"] = firebaseID}
        if let nick = user?.nickName                        { dict["spitzname"] = nick}
        if let queryNick = user?.nickName?.lowercased()     { dict["querySpitzname"] = queryNick}
        if let appVersion = version                         { dict["App_Version"] = appVersion}
        return dict
    }
}
