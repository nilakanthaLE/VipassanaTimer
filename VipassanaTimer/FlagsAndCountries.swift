//
//  FlagsAndCountries.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 19.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation

//✅
//MARK: helper for flags and countries
func country(for countryCode:String) -> String{
    let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: countryCode])
    return NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(id)"
}
func emoji(countryCode: String) -> Character {
    let base    = UnicodeScalar("🇦").value - UnicodeScalar("A").value
    var string  = ""
    countryCode.uppercased().unicodeScalars.forEach { if let scala = UnicodeScalar(base + $0.value) { string.append(String(describing: scala))  } }
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

