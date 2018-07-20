//
//  DauerExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData

//✅
//Pausen(dauer)
extension Dauer{
    class func new(start:Date,ende:Date)->Dauer?{
        let dauer       = NSEntityDescription.insertNewObject(forEntityName: "Dauer", into: context) as? Dauer
        dauer?.start    = start
        dauer?.ende     = ende
        return dauer
    }
    var asTimeInterval:TimeInterval{ return ende!.timeIntervalSince(start! as Date) }
}
