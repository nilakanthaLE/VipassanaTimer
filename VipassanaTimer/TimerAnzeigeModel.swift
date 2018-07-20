//
//  TimerAnzeigeModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 11.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
class TimerAnzeigeModel{
    let anzeigeDauer    = MutableProperty<String> (TimeInterval(60*60).hhmm)
    
    //MeditationsDaten
    let meditationTitle = MutableProperty<String?>      ("Eine Stunde - 5 min Anapana und Metta")
    let gesamtDauer     = MutableProperty<TimeInterval> (60*60)
    let anapanaDauer    = MutableProperty<TimeInterval> (5*60)
    let mettaDauer      = MutableProperty<TimeInterval> (5*60)
    let mettaEndlos     = MutableProperty<Bool>         (false)
    let vipassanaDauer  = MutableProperty<TimeInterval> (5*60)
    let hasSoundFile    = MutableProperty<Bool>         (false)
    let klangschalenAreOn   = MutableProperty<Bool>         (false)
    
    //Anteile (calc)
    let anapanaAnteil   = MutableProperty<CGFloat>(5/60)
    let mettaAnteil     = MutableProperty<CGFloat>(5/60)
    let verdeckAnteil   = MutableProperty<CGFloat>(0)
    
    //init
    let timerData:MutableProperty<TimerData>
    init(timerData:TimerData){
        self.timerData = MutableProperty<TimerData>(timerData)
        self.timerData.value = timerData
        self.timerData.producer.startWithValues{[weak self] timerData in  self?.setValues(for: timerData)}
    }
    
    
    //helper
    private func setValues(for timerData:TimerData?){
        guard let timerData = timerData else {return}
        // Values aus TimerData setzen
        verdeckAnteil.value     = 0
        meditationTitle.value   = timerData.meditationTitle
        anapanaDauer.value      = timerData.anapanaDauer
        mettaDauer.value        = timerData.mettaDauer
        mettaEndlos.value       = timerData.mettaEndlos
        gesamtDauer.value       = timerData.gesamtDauer
        vipassanaDauer.value    = timerData.gesamtDauer - timerData.anapanaDauer - timerData.mettaDauer
        anapanaAnteil.value     = CGFloat(timerData.anapanaDauer / timerData.gesamtDauer)
        mettaAnteil.value       = CGFloat(timerData.mettaDauer  / timerData.gesamtDauer)
        anzeigeDauer.value      = timerData.gesamtDauer.hhmm
        hasSoundFile.value      = timerData.soundFileData != nil
        klangschalenAreOn.value = timerData.soundSchalenAreOn
    }
    
    deinit { print("deinit TimerAnzeigeModel") }
}
