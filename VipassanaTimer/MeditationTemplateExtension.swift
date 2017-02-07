//
//  MeditationTemplateExtension.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 30.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension MeditationTemplate{
    class func new(start:Date,name:String?, dauerAnapana: Int32, dauerVipassana: Int32, dauerMetta:Int32)->MeditationTemplate?{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let meditation = NSEntityDescription.insertNewObject(forEntityName: "MeditationTemplate", into: context) as? MeditationTemplate{
            meditation.mettaOpenEnd     = false
            meditation.start            = start as NSDate?
            meditation.name             = name
            meditation.dauerAnapana     = dauerAnapana
            meditation.dauerVipassana   = dauerVipassana
            meditation.dauerMetta       = dauerMetta
            return meditation
        }
        return nil
    }
    
}
