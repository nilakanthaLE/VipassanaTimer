//
//  Meditation.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 17.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import Foundation


//MARK: Protokolle

//✅
//Basis aller Meditationsobjekte
// z.B: TimerData
protocol MeditationConfigProto{
    var meditationTitle:String?    {get set}
    var gesamtDauer:TimeInterval   {get set}
    var anapanaDauer:TimeInterval  {get set}
    var mettaDauer:TimeInterval    {get set}
    var mettaEndlos:Bool           {get set}
}
extension MeditationConfigProto{ var vipassanaDauer:TimeInterval{ return gesamtDauer - anapanaDauer - mettaDauer } }

//✅
//Erweiterung der Basis
// hat start und ende
// --> konkrete Meditation
protocol MeditationProto:MeditationConfigProto{
    var startDate:Date              {get set}
    var rating:Rating?              {get set}
}
extension MeditationProto{
    var gesamtDauer:TimeInterval    { return anapanaDauer + vipassanaDauer + mettaDauer }
    var startZeitMetta:Date         { return startDate + anapanaDauer + vipassanaDauer }
    var endeDate:Date               { return startDate + gesamtDauer }
    var latestMeditationsende:Date{
        let mettaEndlosDauer:TimeInterval = mettaEndlos ? 10 * 60 : 0
        return startDate + gesamtDauer + mettaEndlosDauer
    }
    
}


//MARK: BasisKlasse

//✅
//Basisklasse für Meditationen
class MeditationBasis:MeditationProto{
    var startDate: Date
    var rating: Rating?
    var meditationTitle: String?
    var gesamtDauer: TimeInterval
    var anapanaDauer: TimeInterval
    var mettaDauer: TimeInterval
    var mettaEndlos: Bool
    
    //init mit MeditationsConfig(protokol)
    // z.B. TimerData
    init(meditationConfig:MeditationConfigProto){
        meditationTitle = meditationConfig.meditationTitle
        gesamtDauer     = meditationConfig.gesamtDauer
        anapanaDauer    = meditationConfig.anapanaDauer
        mettaDauer      = meditationConfig.mettaDauer
        mettaEndlos     = meditationConfig.mettaEndlos
        startDate       = Date()
    }
    
    //standard init (mit Werten)
    // gesamtDauer und start sind mindestens erforderlich
    init(gesamtDauer:TimeInterval,start:Date,anapana:TimeInterval = 5*60, metta:TimeInterval = 5*60, mettaEndlos:Bool = false ){
        self.gesamtDauer    = gesamtDauer
        self.startDate      = start
        
        self.anapanaDauer   = anapana
        self.mettaDauer     = metta
        self.mettaEndlos    = mettaEndlos
    }
}

//MARK: enums
enum Rating{ case null,eins,zwei,drei,vier,fuenf }
