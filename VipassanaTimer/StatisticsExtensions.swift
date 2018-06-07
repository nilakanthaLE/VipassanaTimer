//
//  StatisticsExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 22.07.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import CoreData

extension Statistics{
    class func get()->Statistics{
        let request             = NSFetchRequest<Statistics>(entityName: "Statistics")
        if let statistics       = (try? context.fetch(request))?.first { return statistics }
        return NSEntityDescription.insertNewObject(forEntityName: "Statistics", into: context) as! Statistics
    }
}

