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

//✅
// der meditierende/appUser
extension Meditierender {
    // den Meditierenden holen oder neu erstellen
    static func get()->Meditierender?{
        let request             = NSFetchRequest<Meditierender>(entityName: "Meditierender")
        if let meditierender    = (try? context.fetch(request))?.first{  return meditierender }
        let meditierender       = NSEntityDescription.insertNewObject(forEntityName: "Meditierender", into: context) as? Meditierender
        meditierender?.cloudNeedsUpdate = true
        return meditierender
    }
}
