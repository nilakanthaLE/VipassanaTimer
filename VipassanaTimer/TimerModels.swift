//
//  TimerModels.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 02.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result








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
    
    //Anteile (calc)
    let anapanaAnteil   = MutableProperty<CGFloat>(5/60)
    let mettaAnteil     = MutableProperty<CGFloat>(5/60)
    let verdeckAnteil   = MutableProperty<CGFloat>(0)
    
    //init
    let timerData = MutableProperty<TimerData>(TimerData())
    init(timerData:TimerData){
        print("init TimerAnzeigeModel")
        self.timerData.value = timerData
        self.timerData.producer.startWithValues{[weak self] timerData in  self?.setValues(for: timerData)}
    }
    
    
    //helper
    private func setValues(for timerData:TimerData?){
        guard let timerData = timerData else {return}
        //config Values setzen
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
    }
    
    deinit { print("deinit TimerAnzeigeModel") }
}


class TimerInPublicMeditationInfoModel:TimerAnzeigeModel{
    private let now         = MutableProperty<Date?>(nil)
    
    
    private var timer:Timer?
    init (publicMeditation:PublicMeditation){
        startZeit = publicMeditation.startDate
        super.init(timerData: TimerData(publicMeditation: publicMeditation))
        
        //  Updates, wenn Timer läuft
        anzeigeDauer            <~ now.signal.map{[weak self] _ in self?._restDauer.hhmmss ?? "??"}
        verdeckAnteil           <~ now.signal.map{[weak self] _ in self?._ablaufAnteil ?? 0}
        timer  = Timer.scheduledTimer(timeInterval: 0.5 , target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
    }
    @objc private func update() { now.value = Date() }
    
    private var startZeit:Date
    var abgelaufen:TimeInterval{
        guard let now = now.value else { return 0}
        return now.timeIntervalSince(startZeit)
    }
    var _ablaufAnteil: CGFloat  {
        guard abgelaufen <= gesamtDauer.value else { return 1}
        return CGFloat(abgelaufen / gesamtDauer.value)
    }
    var _restDauer:TimeInterval {
        //bei metta endlos --> Anzeige wechselt nach regulärem Ende zu GesamtDauer
        if gesamtDauer.value - abgelaufen <= 0{ return  abgelaufen }
        return gesamtDauer.value - abgelaufen
    }
    func timerBeenden()         {  timer?.invalidate()  }
    deinit { print("deinit TimerInPublicMeditationInfoModel") }
}

class TimerSettingsModel:TimerAnzeigeModel{
    let soundFileData           = MutableProperty<SoundFileData?>(nil)
    let soundSchalenSwitchIsOn  = MutableProperty<Bool>(false)
    
    override init(timerData: TimerData) {
        super.init(timerData: timerData)
        soundFileData.value = timerData.soundFileData
        
        //self.soundFileData wird gesetzt
        // --> self.timerData update
        
        
        soundFileData.signal.observeValues{[weak self] soundFileData in
            guard let strongSelf = self else {return}
            strongSelf.timerData.value = strongSelf.timerData.value.setSoundFileData(soundFileData)
        }
    }
}

class TimerAsTimerModel:TimerAnzeigeModel{
    //Signale für Klänge
    let anapanaBeendet      = MutableProperty<Void>(Void())
    let vipassanaBeendet    = MutableProperty<Void>(Void())
    let meditationBeendet   = MutableProperty<Void>(Void())
    let meditationGestartet = MutableProperty<Void>(Void())
    
    //Timer
    let timerState          = MutableProperty<TimerState>(.nichtGestartet)
    private let now         = MutableProperty<Date?>(nil)
    
    //init
    convenience init(gewaehlerTimer:MutableProperty<TimerData>){
        self.init(timerData:gewaehlerTimer.value)
        self.timerData <~ gewaehlerTimer.signal
    }
    
    override init(timerData:TimerData = TimerData()){
        print("init TimerAsTimerModel")
        super.init(timerData: timerData)
        
        //  Timer starten, pausieren und beenden
        timerState.signal.combinePrevious(TimerState.nichtGestartet).observeValues{[weak self](lastState,nowState) in self?.timerControl(lastTimerState: lastState, newTimerState: nowState)}

        //  Updates, wenn Timer läuft
        anzeigeDauer            <~ now.signal.map{[weak self] _ in self?._restDauer.hhmmss ?? "??"}
        verdeckAnteil           <~ now.signal.map{[weak self] _ in self?._ablaufAnteil ?? 0}

        //  Klangschalen Sound Ereignisse
        let audioPlayer = AudioPlayer()
        now.signal.filter{$0 != nil}.observeValues{[weak self] now in self?.setEndeEreignisse(now: now!) }
        let observer = Signal<Void,NoError>.Observer{ _ in if timerData.soundSchalenAreOn{ audioPlayer.playKlangSchale() }}
        anapanaBeendet.signal.observe(observer)
        meditationBeendet.signal.observe(observer)
        vipassanaBeendet.signal.observe(observer)
        meditationGestartet.signal.observe(observer)

        //  initial
        resetTimerValues()
    }
    
    
    
    //Timer
    private var timer:Timer?
    private var startZeit:Date?
    private var pauseStartZeit:Date?
    private var pausenDauer:TimeInterval    = 0
    private func timerStarten() { timer  = Timer.scheduledTimer(timeInterval: 0.5 , target: self, selector: #selector(update), userInfo: nil, repeats: true) }
    func timerBeenden()         { timer?.invalidate()  }
    @objc private func update() { now.value = Date() }
    
    //helper
    var abgelaufen:TimeInterval{
        guard let now = now.value, let start = startZeit else { return 0}
        return now.timeIntervalSince(start) - pausenDauer
    }
    var _ablaufAnteil: CGFloat  {
        guard abgelaufen <= gesamtDauer.value else { return 1}
        return CGFloat(abgelaufen / gesamtDauer.value)
    }
    var _restDauer:TimeInterval {
        //bei metta endlos --> Anzeige wechselt nach regulärem Ende zu GesamtDauer
        if gesamtDauer.value - abgelaufen <= 0{ return  abgelaufen }
        return gesamtDauer.value - abgelaufen
    }
    
    private var anapanaEndeErreicht:Bool    = false
    private var vipassanaEndeErreicht:Bool  = false
    private var meditationMitEndlosMettaVipassanaEndeErreicht = false
    private func setEndeEreignisse(now:Date){
        if !anapanaEndeErreicht && abgelaufen > anapanaDauer.value && anapanaDauer.value > 0{
            anapanaBeendet.value    = Void()
            anapanaEndeErreicht     = true
        }
        if !vipassanaEndeErreicht && vipassanaDauer.value > 0  && abgelaufen > anapanaDauer.value + vipassanaDauer.value {
            vipassanaBeendet.value  = Void()
            vipassanaEndeErreicht   = true
        }
        if abgelaufen >= gesamtDauer.value{
            if !meditationMitEndlosMettaVipassanaEndeErreicht { meditationBeendet.value                         = Void()}
            meditationMitEndlosMettaVipassanaEndeErreicht   = true
            if !timerData.value.mettaEndlos { timerState.value = .nichtGestartet }
        }
    }
    private func resetTimerValues(){
        startZeit               = nil
        pauseStartZeit          = nil
        anzeigeDauer.value      = gesamtDauer.value.hhmm
        anapanaEndeErreicht     = false
        vipassanaEndeErreicht   = false
        meditationMitEndlosMettaVipassanaEndeErreicht = false
        verdeckAnteil.value     = 0
        timerBeenden()
        mainModel.pauseDates.value          = (pauseStartZeit,Date())
        mainModel.myActiveMeditation.value  = nil
    }
    private func timerControl(lastTimerState:TimerState,newTimerState:TimerState){
        switch newTimerState{
        case .nichtGestartet:   resetTimerValues()
        case .laueft:
            //nach Pause gestartet
            if lastTimerState == .pausiert{
                var dauerNeuePause:TimeInterval{
                    guard let pausenStart = pauseStartZeit else {return 0}
                    return Date().timeIntervalSince(pausenStart)
                }
                mainModel.pauseDates.value = (pauseStartZeit,Date())
                pausenDauer     += dauerNeuePause
                pauseStartZeit  = nil
                
            }
            //neuer start
            else{
                meditationGestartet.value   = Void()
                startZeit                   = Date()}
                timerStarten()
                mainModel.myActiveMeditation.value = PublicMeditation(meditationConfig: timerData.value)
        case .pausiert:
            pauseStartZeit      = Date()
            timerBeenden()
        }
    }
    
    deinit {
        timer?.invalidate()
        print("deinit TimerAsTimerModel") }
}
