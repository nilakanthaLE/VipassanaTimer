//
//  BackgroundInfoExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 09.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension BackgroundInfo{
    
    class func set(anapana:Date,vipassana:Date,ende:Date)->BackgroundInfo?{
        let context             = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<BackgroundInfo>(entityName: "BackgroundInfo")
        
        if let backgroundInfo = (try? context.fetch(request))?.first{
            backgroundInfo.anapanaEnde      = anapana
            backgroundInfo.vipassanaEnde    = vipassana
            backgroundInfo.meditationsEnde  = ende
            return backgroundInfo
        }
        if let backgroundInfo = NSEntityDescription.insertNewObject(forEntityName: "BackgroundInfo", into: context) as? BackgroundInfo{
            backgroundInfo.anapanaEnde      = anapana
            backgroundInfo.vipassanaEnde    = vipassana
            backgroundInfo.meditationsEnde  = ende 
            return backgroundInfo
        }
        return nil
    }
    class func getInfo()->BackgroundInfo?{
        let context             = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request             = NSFetchRequest<BackgroundInfo>(entityName: "BackgroundInfo")
        
        if let backgroundInfo = (try? context.fetch(request))?.first{
            return backgroundInfo
        }
        if let backgroundInfo = NSEntityDescription.insertNewObject(forEntityName: "BackgroundInfo", into: context) as? BackgroundInfo{
            return backgroundInfo
        }
        return nil
    }
    func delete(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(self)
    }
    
    
}
