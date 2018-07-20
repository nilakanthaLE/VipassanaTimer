//
//  StatisticsExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 22.07.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import CoreData

//✅
// Statistiken für die Startseite
// werden asynchron aktualisiert
// stehen (nicht aktualisiert) ohne zeitverzögerung zur Verfügung
extension Statistics{
    // das Statistik Objekt holen oder erzeugen
    class func get()->Statistics{
        let request             = NSFetchRequest<Statistics>(entityName: "Statistics")
        return (try? context.fetch(request))?.first ?? NSEntityDescription.insertNewObject(forEntityName: "Statistics", into: context) as! Statistics
    }
    
    // CoreData aktualisieren
    static func setCoreDataStatisticsAsync(update:@escaping ()->Void){
        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .userInitiated).async {
            let start = Date()
            defer { print("setCoreDataStatisticsAsync -> \(Date().timeIntervalSince(start)) s") }
            
            let data = StatistikUeberblickDaten()
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                let statistics  = Statistics.get()
                statistics.regelmaessigZweimalAmTagMax      = Int16(data.regelmaessigkeit.zweiMalTaeglichMax)
                statistics.regelmaessigZweiMalAmTag         = Int16(data.regelmaessigkeit.zweiMalTaeglichBisHeute)
                statistics.regelmaessigEinmalAmTagMax       = Int16(data.regelmaessigkeit.taeglichEinmalMax)
                statistics.regelmaessigEinmalAmTag          = Int16(data.regelmaessigkeit.taeglichEinmalBisHeute)
                
                statistics.gesamtDauer                      = data.gesamt
                statistics.gesamtDauerOhneKurse             = data.gesamtOhneKurse
                statistics.kursTage                         = Int16(data.kursTage)
                
                statistics.gesamtVorletzterTag              = data.gesamtVorletzterTag
                statistics.gesamtVorletzteWoche             = data.gesamtVorletzteWoche
                statistics.gesamtVorletzterMonat            = data.gesamtVorletzterMonat
                statistics.gesamtVorherigWoche              = data.gesamtVorherigWoche
                statistics.gesamtVorherigTag                = data.gesamtVorherigTag
                statistics.gesamtVorherigMonat              = data.gesamtVorherigMonat
                statistics.gesamtAktuellWoche               = data.gesamtAktuellWoche
                statistics.gesamtAktuellTag                 = data.gesamtAktuellTag
                statistics.gesamtAktuellMonat               = data.gesamtAktuellMonat
                
                statistics.durchschnittWoche                = data.durchSchnittWoche
                statistics.durchschnittVorherigWoche        = data.gesamtVorherigWoche
                statistics.durchschnittVorherigTag          = data.gesamtVorherigTag
                statistics.durchschnittVorherigMonat        = data.gesamtVorherigMonat
                statistics.durchschnittTag                  = data.durchschnittTag
                statistics.durchschnittMonat                = data.durchSchnittMonat
                
                saveContext()
                update()
            }
        }
    }
    
    // Daten für Balkengraph auf Startseite holen
    func getGraphData(takt:StatistikTakt) -> StatistikUeberblickGraphData{
        return StatistikUeberblickGraphData(takt: takt,
                                            aktuell:       getValue(takt: takt, zeitraum: .aktuell) ,
                                            letzter:       getValue(takt: takt, zeitraum: .letzter) ,
                                            vorletzter:    getValue(takt: takt, zeitraum: .vorletzter),
                                            durchSchnitt:  getValue(takt: takt, zeitraum: .durchSchnitt))
    }
    
    //helper
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
}

