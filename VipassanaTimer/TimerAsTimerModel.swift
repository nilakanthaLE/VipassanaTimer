//
//  TimerAsTimerModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 11.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift
import Result

//✅
class TimerAsTimerModel:TimerAnzeigeModel{
    let coreDataModel       = CoreDataModel()
    
    let myActiveMeditation  = MutableProperty<PublicMeditation?>(nil)
    let timerState          = MutableProperty<TimerState>(.nichtGestartet)
    let pauseDates          = MutableProperty<(start:Date?,ende:Date?)>((nil,nil))
    
    //Signale für Klänge
    let anapanaBeendet      = MutableProperty<Void>(Void())
    let vipassanaBeendet    = MutableProperty<Void>(Void())
    let meditationBeendet   = MutableProperty<Void>(Void())
    let meditationGestartet = MutableProperty<Void>(Void())
    
    
    
    //Timer
    private let ticker      = SignalProducer.timer(interval: DispatchTimeInterval.seconds(1), on: QueueScheduler.main)
    private let now         = MutableProperty<Date?>(nil)
    
    //init
    convenience init(gewaehlerTimer:MutableProperty<TimerData>, myMeditation:MutableProperty<PublicMeditation?>){
        self.init(timerData:gewaehlerTimer.value)
        self.timerData <~ gewaehlerTimer.signal
        myMeditation <~ self.myActiveMeditation
    }
    override init(timerData:TimerData = TimerData()){
        super.init(timerData: timerData)
        
        //aktive Meditation
        // und Pausen
        myActiveMeditation.producer.startWithValues{[weak self] meditation in
//            fireBaseActiveMeditationsListModel.updateMyMeditation(myMeditation: meditation)
            self?.coreDataModel.updateMyMeditation(myMeditation: meditation)
        }
        pauseDates.producer.startWithValues { [weak self] pause in self?.coreDataModel.addPause(start: pause.start, ende: pause.ende) }
        
        //  Timer starten, pausieren und beenden
        timerState.signal.combinePrevious(TimerState.nichtGestartet).observeValues{[weak self](lastState,nowState) in self?.timerControl(lastTimerState: lastState, newTimerState: nowState)}
        
        //  Updates, wenn Timer läuft
        anzeigeDauer            <~ now.signal.map{[weak self] _ in self?._restDauer.hhmmss ?? "??"}
        verdeckAnteil           <~ now.signal.map{[weak self] _ in self?._ablaufAnteil ?? 0}
        
        //  Klangschalen Sound Ereignisse
        let audioPlayer = AudioPlayer()
        now.signal.filter{$0 != nil}.observeValues{[weak self] now in self?.setEndeEreignisse(now: now!) }
        let observer = Signal<Void,NoError>.Observer{[weak self] _ in if self?.klangschalenAreOn.value == true { audioPlayer.playKlangSchale()  } }
        anapanaBeendet.signal.observe(observer)
        meditationBeendet.signal.observe(observer)
        vipassanaBeendet.signal.observe(observer)
        meditationGestartet.signal.observe(observer)
        
        //  initial
        resetTimerValues()
        ticker.start()
    }
    
    //Timer
    private var tickerNowDispose:Disposable?
    private var startZeit:Date?
    private var pauseStartZeit:Date?
    private var pausenDauer:TimeInterval    = 0
    private func timerStarten() { tickerNowDispose = now <~ ticker }
    private func timerBeenden() { tickerNowDispose?.dispose()  }
    
    //helper calc properties
    private var abgelaufen:TimeInterval{
        guard let now = now.value, let start = startZeit else { return 0}
        return now.timeIntervalSince(start) - pausenDauer
    }
    private var _ablaufAnteil: CGFloat  {
        guard abgelaufen <= gesamtDauer.value else { return 1}
        return CGFloat(abgelaufen / gesamtDauer.value)
    }
    private var _restDauer:TimeInterval {
        //bei metta endlos --> Anzeige wechselt nach regulärem Ende zu GesamtDauer
        if gesamtDauer.value - abgelaufen <= 0{ return  abgelaufen }
        return gesamtDauer.value - abgelaufen
    }
    
    // EndeEreignisse
    // ... prüft sekündlich, ob ein Meditationsabschnitt beendet ist
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
            if !meditationMitEndlosMettaVipassanaEndeErreicht   { meditationBeendet.value                         = Void()}
            meditationMitEndlosMettaVipassanaEndeErreicht   = true
            if !timerData.value.mettaEndlos                     { timerState.value = .nichtGestartet }
        }
    }
    
    //werte zurücksetzen und initial setzen
    // wird in init aufgerufen
    // wird aufgerufen, wenn die Meditation beendet wurde
    private func resetTimerValues(){
        startZeit               = nil
        pauseStartZeit          = nil
        anzeigeDauer.value      = gesamtDauer.value.hhmm
        anapanaEndeErreicht     = false
        vipassanaEndeErreicht   = false
        meditationMitEndlosMettaVipassanaEndeErreicht = false
        verdeckAnteil.value     = 0
        timerBeenden()
        pauseDates.value          = (pauseStartZeit,Date())
        myActiveMeditation.value  = nil
        soundFileAudioPlayer.soundFileData.value = nil
    }
    
    // Änderung des timerZustands
    // --> stoppen, starten, pausieren
    private func timerControl(lastTimerState:TimerState,newTimerState:TimerState){
        switch newTimerState{
        case .nichtGestartet:   //stoppen
            resetTimerValues()
        case .laueft:           //starten + starten nach Pause
            //nach Pause gestartet
            if lastTimerState == .pausiert{
                var dauerNeuePause:TimeInterval{
                    guard let pausenStart = pauseStartZeit else {return 0}
                    return Date().timeIntervalSince(pausenStart)
                }
                pauseDates.value = (pauseStartZeit,Date())
                pausenDauer     += dauerNeuePause
                pauseStartZeit  = nil
                soundFileAudioPlayer.startNachPause()
            }
                //neuer start
            else{
                meditationGestartet.value   = Void()
                startZeit                   = Date()
                myActiveMeditation.value          = PublicMeditation(meditationConfig: timerData.value)
                soundFileAudioPlayer.soundFileData.value    = timerData.value.soundFileData
            }
            timerStarten()
        case .pausiert:         //pausieren
            pauseStartZeit      = Date()
            soundFileAudioPlayer.pause()
            timerBeenden()
        }
    }
    
    deinit {
        timerBeenden()
        coreDataModel.updateMyMeditation(myMeditation: nil)
        myActiveMeditation.value = nil
        print("deinit TimerAsTimerModel") }
}
