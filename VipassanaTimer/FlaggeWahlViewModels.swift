//
//  FlaggeWahlViewModels.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

//✅
//ViewModel für Wahl der Flagge
// Picker und Suchfeld
class FlaggeWahlViewModel{
    var pickerValues:[String]   = [String]()
    let suchRow                 = MutableProperty<Int>(0)
    let suchString              = MutableProperty<String?>(nil)
    let userSelection           = MutableProperty<Int>(0)
    
    //init
    init(flag:MutableProperty<String>){
        let countryCodes        = NSLocale.isoCountryCodes as [String]
        let flags               = countryCodes.map{String(emoji(countryCode: $0))}
        let countries           = countryCodes.map{country(for: $0)}
        let localCountryCodeRow = countryCodes.enumerated().filter{$0.element == NSLocale.current.regionCode}.map{$0.offset}.first ?? 0
        pickerValues            = flags.enumerated().map{$0.element + " " + countries[$0.offset]}
        
        //Suche
        suchRow.value           = flags.enumerated().filter{$0.element == flag.value}.map{$0.offset}.first ?? localCountryCodeRow
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
