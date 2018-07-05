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
        let statistics          = (try? context.fetch(request))?.first
        return statistics ?? NSEntityDescription.insertNewObject(forEntityName: "Statistics", into: context) as! Statistics
    }
    
    func getGraphData(takt:StatistikTakt) -> StatistikUeberblickGraphData{
        return StatistikUeberblickGraphData(takt: takt,
                                     aktuell:       getValue(takt: takt, zeitraum: .aktuell) ,
                                     letzter:       getValue(takt: takt, zeitraum: .letzter) ,
                                     vorletzter:    getValue(takt: takt, zeitraum: .vorletzter),
                                     durchSchnitt:  getValue(takt: takt, zeitraum: .durchSchnitt))
    }
    private func getValue(takt:StatistikTakt,zeitraum:StatistikZeitraum) -> Double{
        switch takt{
        case .taeglich:
            switch zeitraum{
            case .aktuell:      return gesamtAktuellTag     / 3600
            case .letzter:      return gesamtVorherigTag    / 3600
            case .vorletzter:   return gesamtVorletzterTag  / 3600
            case .durchSchnitt: return durchschnittTag      / 3600
            }
        case .woechentlich:
            switch zeitraum{
            case .aktuell:      return gesamtAktuellWoche   / 3600
            case .letzter:      return gesamtVorherigWoche  / 3600
            case .vorletzter:   return gesamtVorletzteWoche / 3600
            case .durchSchnitt: return durchschnittWoche    / 3600
            }
        case .monatlich:
            switch zeitraum{
            case .aktuell:      return gesamtAktuellMonat       / 3600
            case .letzter:      return gesamtVorherigMonat      / 3600
            case .vorletzter:   return gesamtVorletzterMonat    / 3600
            case .durchSchnitt: return durchschnittMonat        / 3600
            }
        }
    }
    
    
    static func setCoreDataStatisticsAsync(update:@escaping ()->Void){
        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .userInitiated).async {
            let start = Date()
            defer { print("setCoreDataStatisticsAsync -> \(Date().timeIntervalSince(start)) s") }
            
            let data = StatistikUeberblickDaten()
            print("Statistik StartDatum: \(StatistikUeberblickDaten.startDateFuerDurchschnitt?.string("dd.MM.yyyy"))")
            
            
            let regelmaessigZweimalAmTagMax     = Int16(data.regelmaessigkeit.zweiMalTaeglichMax)
            let regelmaessigZweiMalAmTag        = Int16(data.regelmaessigkeit.zweiMalTaeglichBisHeute)
            let regelmaessigEinmalAmTagMax      = Int16(data.regelmaessigkeit.taeglichEinmalMax)
            let regelmaessigEinmalAmTag         = Int16(data.regelmaessigkeit.taeglichEinmalBisHeute)
            let kursTage                        = Int16(data.kursTage)
            let gesamtDauerOhneKurse            = data.gesamtOhneKurse
            
            let gesamtVorletzterTag             = data.gesamtVorletzterTag
            let gesamtVorletzteWoche            = data.gesamtVorletzteWoche
            let gesamtVorletzterMonat           = data.gesamtVorletzterMonat
            
            let gesamtVorherigWoche             = data.gesamtVorherigWoche
            let gesamtVorherigTag               = data.gesamtVorherigTag
            let gesamtVorherigMonat             = data.gesamtVorherigMonat
            
            let gesamtDauer                     = data.gesamt
            
            let gesamtAktuellWoche              = data.gesamtAktuellWoche
            let gesamtAktuellTag                = data.gesamtAktuellTag
            let gesamtAktuellMonat              = data.gesamtAktuellMonat
            
            let durchschnittWoche               = data.durchSchnittWoche
            let durchschnittVorherigWoche       = data.gesamtVorherigWoche
            let durchschnittVorherigTag         = data.gesamtVorherigTag
            let durchschnittVorherigMonat       = data.gesamtVorherigMonat
            let durchschnittTag                 = data.durchschnittTag
            let durchschnittMonat               = data.durchSchnittMonat
            
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                let statistics  = Statistics.get()
                statistics.regelmaessigZweimalAmTagMax     = regelmaessigZweimalAmTagMax
                statistics.regelmaessigZweiMalAmTag        = regelmaessigZweiMalAmTag
                statistics.regelmaessigEinmalAmTagMax      = regelmaessigEinmalAmTagMax
                statistics.regelmaessigEinmalAmTag         = regelmaessigEinmalAmTag
                statistics.kursTage                        = kursTage
                
                statistics.gesamtVorletzterTag              = gesamtVorletzterTag
                statistics.gesamtVorletzteWoche             = gesamtVorletzteWoche
                statistics.gesamtVorletzterMonat            = gesamtVorletzterMonat
                
                
                statistics.gesamtVorherigWoche             = gesamtVorherigWoche
                statistics.gesamtVorherigTag               = gesamtVorherigTag
                statistics.gesamtVorherigMonat             = gesamtVorherigMonat
                
                statistics.gesamtAktuellWoche              = gesamtAktuellWoche
                statistics.gesamtAktuellTag                = gesamtAktuellTag
                statistics.gesamtAktuellMonat              = gesamtAktuellMonat
                
                statistics.gesamtDauerOhneKurse            = gesamtDauerOhneKurse
                statistics.gesamtDauer                     = gesamtDauer
                
                
                
                statistics.durchschnittWoche               = durchschnittWoche
                statistics.durchschnittVorherigWoche       = durchschnittVorherigWoche
                statistics.durchschnittVorherigTag         = durchschnittVorherigTag
                statistics.durchschnittVorherigMonat       = durchschnittVorherigMonat
                statistics.durchschnittTag                 = durchschnittTag
                statistics.durchschnittMonat               = durchschnittMonat
                
                saveContext()
                update()
            }
        }
    }
}

