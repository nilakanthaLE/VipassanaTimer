//
//  FlaggeWahlViewModels.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift


class FlaggeWahlVCViewModel{
    let flagge:MutableProperty<String>
    init(flagge:MutableProperty<String>){
        self.flagge = flagge
    }
    func getViewModelForFlaggeWahlView() -> FlaggeWahlViewModel{
        return FlaggeWahlViewModel(flag: flagge)
    }
}

class FlaggeWahlViewModel{
    var pickerValues:[String] = [String]()
    
    let suchRow             = MutableProperty<Int>(0)
    let suchString          = MutableProperty<String?>(nil)
    
    let userSelection       = MutableProperty<Int>(0)
    init(flag:MutableProperty<String>){
        let countryCodes    = NSLocale.isoCountryCodes as [String]
        let flags           = countryCodes.map{String(emoji(countryCode: $0))}
        let countries       = countryCodes.map{country(for: $0)}
        let localCountryCodeRow     = countryCodes.enumerated().filter{$0.element == NSLocale.current.regionCode}.map{$0.offset}.first ?? 0
        pickerValues        = flags.enumerated().map{$0.element + " " + countries[$0.offset]}
        
        
        
        //Suche
        suchRow.value       = flags.enumerated().filter{$0.element == flag.value}.map{$0.offset}.first ?? localCountryCodeRow
        func getRowInCountries(suchString:String?)->Int{
            guard let suchString = suchString else {return localCountryCodeRow}
            return countries.enumerated().filter{$0.element.uppercased().contains(suchString.uppercased())}.map{$0.offset}.first ?? localCountryCodeRow
        }
        suchRow <~ suchString.signal.map{getRowInCountries(suchString: $0)}
        
        //ergebnis
        flag <~ userSelection.signal.map{flags[$0]}
        flag <~ suchRow.signal.map{flags[$0]}
    }
}

//helper for flags and countries
func country(for countryCode:String) -> String{
    let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode])
    return NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(id)"
}

func emoji(countryCode: String) -> Character {
    let base = UnicodeScalar("🇦").value - UnicodeScalar("A").value
    
    var string = ""
    countryCode.uppercased().unicodeScalars.forEach {
        if let scala = UnicodeScalar(base + $0.value) {
            string.append(String(describing: scala))
        }
    }
    return Character(string)
}

func countryNameForFlag(flag:String?)->String?{
    guard let flag = flag else {return nil}
    let countryCodes    = NSLocale.isoCountryCodes as [String]
    let flags           = countryCodes.map{String(emoji(countryCode: $0))}
    let countries       = countryCodes.map{country(for: $0)}
    guard let id = (flags.enumerated().filter{$0.element == flag}.first?.offset) else {return nil}
    return countries[id]
}
