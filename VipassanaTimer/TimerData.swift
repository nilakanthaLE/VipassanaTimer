//
//  EnumsAndDataTypes.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 05.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation

class TimerData:MeditationConfigProto{
    var meditationTitle:String?         = "Eine Stunde - 5 min Anapana und Metta"
    var gesamtDauer:TimeInterval        = 60*60
    var anapanaDauer:TimeInterval       = 5*60
    var mettaDauer:TimeInterval         = 5*60
    var mettaEndlos:Bool                = false
    var soundFileData:SoundFileData?    = nil
    var soundSchalenAreOn:Bool          = true
    
    let timerConfig:TimerConfig?
    init(){ timerConfig = nil }
    init(timerConfig:TimerConfig){
        self.timerConfig = timerConfig
        meditationTitle     = timerConfig.name
        gesamtDauer         = timerConfig.gesamtDauer
        anapanaDauer        = timerConfig.anapanaDauer
        mettaDauer          = timerConfig.mettaDauer
        mettaEndlos         = timerConfig.mettaEndlos
        soundFileData       = timerConfig.soundFileDataCD?.soundFileData
    }
    
    //Initialisierung für PublicMeditationInfoView
    init(publicMeditation:PublicMeditation){
        meditationTitle     = "Gesamt Dauer: \(publicMeditation.gesamtDauer.hhmm)"
        gesamtDauer         = publicMeditation.gesamtDauer
        anapanaDauer        = publicMeditation.anapanaDauer
        mettaDauer          = publicMeditation.mettaDauer
        mettaEndlos         = publicMeditation.mettaEndlos
        timerConfig         = nil
    }
    func  setTimerConfig(){
        print("setTimerConfig")
        timerConfig?.name               = meditationTitle
        timerConfig?.gesamtDauer        = gesamtDauer
        timerConfig?.anapanaDauer       = anapanaDauer
        timerConfig?.mettaDauer         = mettaDauer
        timerConfig?.mettaEndlos        = mettaEndlos
        timerConfig?.soundFileDataCD    = SoundFileDataCD.get(soundFileData: soundFileData)
        saveContext()
    }
    func deleteTimerConfig()        { timerConfig?.delete() }
    func setTimerConfigToActive()   { timerConfig?.setActive() }
    func setAnapanaUndMetta(newValue:TimeInterval,meditationTyp:MeditationsTyp) -> TimerData{
        
        switch meditationTyp{
        case .anapana:
            anapanaDauer    = newValue
            if gesamtDauer - newValue < mettaDauer  {mettaDauer      = gesamtDauer - newValue}
        case .metta:
            mettaDauer      = newValue
            if gesamtDauer - newValue < mettaDauer  { anapanaDauer    = gesamtDauer - newValue }
            mettaEndlos     = false
        case .vipassana:
            break
        }
        setTimerConfig()
        return self
    }
    func setGesamtDauer(_ newValue:TimeInterval) -> TimerData{
        gesamtDauer = newValue < (soundFileData?.duration ?? newValue) ? soundFileData?.duration ?? newValue : newValue
        
        // wenn gesamtDauer geringer als aktuelle VipassanaDauer
        var mettaUndAnapanaDauerNeedUpdate:Bool {return gesamtDauer - anapanaDauer - mettaDauer < 0}
        //1) MettaDauer anpassen
        if mettaUndAnapanaDauerNeedUpdate   { mettaDauer = (gesamtDauer - anapanaDauer) > 0 ? (gesamtDauer - anapanaDauer) : 0 }
        //2) AnapanaDauer anpassen
        if mettaUndAnapanaDauerNeedUpdate   { anapanaDauer = gesamtDauer }
        
        if soundFileData != nil             { anapanaDauer = gesamtDauer - (soundFileData?.duration ?? gesamtDauer) }
        setTimerConfig()
        return self
    }
    func setMettaEndlos(_ isEndlos:Bool) -> TimerData{
        mettaEndlos = isEndlos
        mettaDauer  = isEndlos ? 0 : 5*60
        setTimerConfig()
        return self
    }
    func setTitle(_ newTitle:String?) -> TimerData{
        meditationTitle = newTitle
        setTimerConfig()
        return self
    }
    func setSoundFileData(_ soundFileData:SoundFileData?) -> TimerData{
        self.soundFileData = soundFileData
        _ = setData(for: soundFileData)
        setTimerConfig()
        return self
    }
    func setSoundSchalenAreOn(_ soundSchalenAreOn:Bool) -> TimerData{
        self.soundSchalenAreOn  = soundSchalenAreOn
        setTimerConfig()
        return self
    }
    
    private func setData(for soundFileData:SoundFileData?) -> TimerData{
        gesamtDauer         = soundFileData?.duration ?? 60 * 60
        anapanaDauer        = soundFileData != nil ? 0 : 5 * 60
        mettaDauer          = soundFileData?.mettaDuration  ?? 5 * 60
        soundSchalenAreOn   = soundFileData == nil
        mettaEndlos         = false
        return self
    }
}

enum TimerDataChangeTyp { case gesamtDauer, anapanaDauer, mettaDauer, title, mettaEndlos, soundFileData, none }
enum MeditationsTyp     { case anapana,metta,vipassana }
enum TimerState{
    case nichtGestartet,laueft,pausiert
    
    var startButtonTitle:String{
        switch self{
        case .nichtGestartet:   return "starten"
        case .laueft:           return "pause"
        case .pausiert:         return "fortsetzen"
        }
    }
    var beendenButtonIsHidden:Bool{ return self == .nichtGestartet }
    var nextStartPressed:TimerState{
        switch self{
        case .nichtGestartet:   return .laueft
        case .laueft:           return .pausiert
        case .pausiert:         return .laueft
        }
    }
}
