//
//  TimerView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 10.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import YSRangeSlider
import AVFoundation

class TimerControl:TimerView{
    var meditationGestartetOderBeendet:((_ meditation:Meditation?)->())?
    var meditation:Meditation?
    override var timerConfig:TimerConfig?{didSet{if timerConfig != nil{setLabels()}}}
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    //MARK: Timer
    
    private var timerStartZeit:Date?
    private var pausenDauer:TimeInterval = 0
    private var pauseStartZeit: Date?
    private var gongTimer:GongTimer?
    private var sekundenTimer:Timer?
    private func startTimer(){
        timerStartZeit          = Date()
        //Meditation
        meditation              = Meditation.startNewActive(timerConfig: timerConfig!)
        meditationGestartetOderBeendet?(meditation!)
        
        //Buttons
        startenButton.setTitle(pauseString, for:.normal)
        beendenButton.isHidden  = false
        
        //Timer
        pausenDauer             = 0
        sekundenTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sekundenTicker(_:)), userInfo: nil, repeats: true)
        sekundenTimer?.fire()
        gongTimer   = GongTimer(gongDates)
    }
    private func pauseStartTimer(){
        startenButton.setTitle(continueString, for:.normal)
        pauseStartZeit = Date()
        sekundenTimer?.invalidate()
        gongTimer?.invalidateTimers()
    }
    private func pauseEndTimer(){
        meditation?.addPause(start: pauseStartZeit!, ende: Date())
        startenButton.setTitle(pauseString, for:.normal)
        pausenDauer += Date().timeIntervalSince(pauseStartZeit!)
        gongTimer       = GongTimer(gongDates)
        sekundenTimer   = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sekundenTicker(_:)), userInfo: nil, repeats: true)
    }
    private func endTimer(){
        meditation?.beendet(Date())
        meditationGestartetOderBeendet?(nil)
        meditation = nil
        setLabels()
        sekundenTimer?.invalidate()
        gongTimer?.invalidateTimers()
        rangeSlider.resetAblaufTimer()
    }
    @objc private func sekundenTicker(_ sender:Timer){
        guard let timerStartZeit    = timerStartZeit else {return}
        let mettaOpenEnd            = timerConfig?.mettaOpenEnd ?? false
        let abgelaufeneZeit         = Date().timeIntervalSince(timerStartZeit) - pausenDauer
        
        rangeSlider.setAblaufBalkenAndDaumen(abgelaufeneZeit)
        let restDauer = gesamtDauer - abgelaufeneZeit
        if  restDauer > 0{
            gesamtDauerLabel.text               = restDauer.hhmmssString
        }else{
            if mettaOpenEnd{
                startenButton.setTitle(finishString, for:.normal)
                gesamtDauerLabel.text           = abgelaufeneZeit.hhmmssString
            }else{
                endTimer()
            }
            beendenButton.isHidden                 = true
        }
    }
    
    //MARK: Button Actions
    override func startenPressed(_ sender: UIButton) {
        guard let title = sender.currentTitle else {return}
        switch title {
        case startString: startTimer()
        case pauseString: pauseStartTimer()
        case continueString: pauseEndTimer()
        case finishString:endTimer()
        default:break
        }
    }
    override func beendenPressed(_ sender: UIButton) {
        endTimer()
    }
    
    

    //MARK: Helper
    private var gongDates:[Date] //(gong1:Date,gong2:Date,gong3:Date)?
    {
        guard let timerStartZeit = timerStartZeit else{return [Date]()}
        
        
        let meditierteDauer     = Date().timeIntervalSince(timerStartZeit) - pausenDauer
        
        var gongs = [Date]()
        
        if anapanaLabel.dauer > 0 && anapanaLabel.dauer > meditierteDauer
            { gongs.append(timerStartZeit + anapanaLabel.dauer + pausenDauer)}
        if vipassanaLabel.dauer > 0 && anapanaLabel.dauer + vipassanaLabel.dauer > meditierteDauer
            { gongs.append(timerStartZeit + anapanaLabel.dauer + vipassanaLabel.dauer + pausenDauer) }
        if mettaLabel.dauer > 0 && anapanaLabel.dauer + vipassanaLabel.dauer + mettaLabel.dauer > meditierteDauer
            { gongs.append(timerStartZeit + anapanaLabel.dauer + vipassanaLabel.dauer + mettaLabel.dauer + pausenDauer) }
        
        return gongs
    }
    override func setLabels(){
        super.setLabels()
        //Buttons
        beendenButton.isHidden              = true
        startenButton.setTitle(startString, for: .normal)
        beendenButton.setTitle(finishString, for: .normal)
        
        zeigeSteuerungsPanel    = true
        blurView.isHidden       = true
        rangeSlider.isEnabled   = false
        
        //Slider Werte setzen
        setSlider(max: gesamtDauer, maxSel: anapanaLabel.dauer, minSel: anapanaLabel.dauer + vipassanaLabel.dauer)
    }
    
    private var gesamtDauer:TimeInterval{
        guard let timerConfig = timerConfig  else {return 0}
        return TimeInterval(timerConfig.dauerAnapana + timerConfig.dauerVipassana  + timerConfig.dauerMetta)
    }
    
    //MARK: Localization
    private let startString     = NSLocalizedString("TimerConfigViewStart", comment: "TimerConfigViewStart")
    private let stopString      = NSLocalizedString("TimerConfigViewStop", comment: "TimerConfigViewStop")
    private let pauseString     = NSLocalizedString("TimerConfigViewPause", comment: "TimerConfigViewPause")
    private let finishString    = NSLocalizedString("TimerConfigViewFinish", comment: "TimerConfigViewFinish")
    private let continueString  = NSLocalizedString("TimerConfigViewContinue", comment: "TimerConfigViewContinue")
    
    func invalidateTimers(){
        gongTimer?.invalidateTimers()
        sekundenTimer?.invalidate()
    }
    deinit {
        invalidateTimers()
        meditation?.beendet(Date())
        print("deinit TimerControl")
    }
}



private class GongTimer {
    var timers = [Timer]()
    func invalidateTimers(){
        for subTimer in timers{ subTimer.invalidate() }
        timers = [Timer]()
    }
    init(_ gongDates: [Date]) { setGongDates(gongDates) }
    
    func setGongDates(_ gongDates: [Date]){
        invalidateTimers()
        for gongDate in gongDates{
            if gongDate.isGreaterThanDate(dateToCompare: Date()){
                starteSubTimer(fireAt: gongDate, typ: "gong")
            }
        }
    }
    
    private func starteSubTimer(fireAt:Date,typ:String){
        let timer           = Timer(fireAt: fireAt, interval: 0, target: self, selector: #selector(zeitraumBeendet(_:)), userInfo: ["typ":typ], repeats: false)
        timers.append(timer)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    @objc private func zeitraumBeendet(_ sender:Timer){
        playSound()
        print("zeitraumBeendet")
    }
    
    //MARK: Gong
    var player: AVAudioPlayer?
    func playSound(){
        //Preparation to play
        do{
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            let url = Bundle.main.url(forResource: "tibetan-bell", withExtension: "wav")!
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.setVolume(0.4, fadeDuration: TimeInterval(5))
            player.prepareToPlay()
            player.play()
        }
        catch let error as NSError {
            print(error.description)
        }
    }
    deinit {
        invalidateTimers()
        print("GongTimer.deinit")
    }
}

protocol TimerConfigViewDelegate : class{
    func rechterDaumenBeiMettaOpenEndBewegt()
}


