//
//  MeditierenderExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 09.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Meditierender {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    class func get()->Meditierender?{
        let request             = NSFetchRequest<Meditierender>(entityName: "Meditierender")
        if let meditierender = (try? context.fetch(request))?.first{
            return meditierender
        }
        
        if let meditierender = NSEntityDescription.insertNewObject(forEntityName: "Meditierender", into: context) as? Meditierender{
            meditierender.cloudNeedsUpdate = true
            return meditierender
        }
        return nil
    }
    class func setNickName(_ nickName:String){
        Meditierender.get()?.nickName = nickName
        saveContext()
    }
    class func getNeedCloudUpdate() -> Meditierender?{
        let request             = NSFetchRequest<Meditierender>(entityName: "Meditierender")
        request.predicate       = NSPredicate(format: "cloudNeedsUpdate == true")
        if let meditierender = (try? context.fetch(request))?.first{
            return meditierender
        }
        return nil
    }
    
    func update(withDict dict:NSDictionary?){
        nickName                = dict?["spitzname"] as? String
        nickNameSichtbarkeit    = dict?["spitzname_sichtbarkeit"] as? Int16 ?? 0
        statistikSichtbarkeit   = dict?["statistikSichtbarkeit"] as? Int16 ?? 0
    }
}
