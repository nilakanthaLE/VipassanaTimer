//
//  DauerExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Dauer{
    
    class func new(start:Date,ende:Date)->Dauer?{
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let dauer = NSEntityDescription.insertNewObject(forEntityName: "Dauer", into: context) as? Dauer{
            dauer.start            = start as NSDate?
            dauer.ende             = ende as NSDate?
            return dauer
        }
        return nil
    }
    var asTimeInterval:TimeInterval{
        return ende!.timeIntervalSince(start as! Date)
    }
}
