//
//  TimerConfigView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 04.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit
import YSRangeSlider


@IBDesignable
class TimerConfigView: NibLoadingView,YSRangeSliderDelegate {
    //publics
    var zeigeSteuerungsPanel = false{
        didSet{
            hoeheSteuerungPanel?.constant   = zeigeSteuerungsPanel ? 40 : 0
            tapGestureRecognizer.isEnabled  = zeigeSteuerungsPanel
        }
    }
    var isEnabled:Bool = false{ didSet{ rangeSlider.isEnabled   = isEnabled } }
    
    var timerConfig:TimerConfig?{
        didSet{
            resetTimer()
            initSlider                          = true
            
            mettaOpenEnd                        = timerConfig?.mettaOpenEnd ?? false
            
            anapanaAnteil                       = timerConfig?.dauerAnapana ?? 0
            vipassanaAnteil                     = timerConfig?.dauerVipassana ?? 0
            mettaAnteil                         = timerConfig?.dauerMetta ?? 0
            
            gesamtDauer                         = Int32(mettaAnteil!) + Int32(anapanaAnteil!) + Int32(vipassanaAnteil!)
            
            //Slider wird gesetzt
            setSlider()
            
            initSlider                           = false
            
            nameLabel?.text     = timerConfig?.name
        }
    }
    var mettaOpenEnd=false{
        didSet{
            if !initSlider{
                
                timerConfig?.mettaOpenEnd   = mettaOpenEnd
                if mettaOpenEnd == true && oldValue == false{
                    vipassanaAnteil = (vipassanaAnteil ?? 0) + (mettaAnteil ?? 0)
                }
                
                setSlider()
            }
        }
    }
    var gesamtDauerWirdGesetzt = false
    var gesamtDauer:Int32 = 3600{
        willSet{
            if !initSlider{
                gesamtDauerWirdGesetzt = true
                
                if (anapanaAnteil ?? 0) > newValue {
                    vipassanaAnteil = 0
                    anapanaAnteil   = newValue
                }else if (vipassanaAnteil ?? 0) + (anapanaAnteil ?? 0) > newValue{
                    vipassanaAnteil = newValue - (anapanaAnteil ?? 0)
                }

                if mettaOpenEnd &&  newValue > gesamtDauer{
                    vipassanaAnteil = newValue - (anapanaAnteil ?? 0)
                }
            }
        }
        didSet{
            setSlider()
            let stunden                 = Int(gesamtDauer / 60 / 60)
            let minuten                 = (gesamtDauer - stunden * 60 * 60) / Int32(60)
            let minutenText             = minuten>9 ? "\(minuten)" : "0\(minuten)"
            gesamtDauerLabel.text       = "\(stunden):"+minutenText
            gesamtDauerWirdGesetzt = false
        }
    }
    private var initSlider = false
    private func setSlider(){
        rangeSlider.maximumValue            = CGFloat(gesamtDauer)
        rangeSlider.maximumSelectedValue    = CGFloat((anapanaAnteil ?? 0) + (vipassanaAnteil ?? 0))
        rangeSlider.minimumSelectedValue    = CGFloat(anapanaAnteil ?? 0)
    }
    
    //private Variablen
    private var anapanaAnteil:Int32?{
        didSet{
            anapanaLabel.text               = "\((anapanaAnteil ?? 0) / 60)"
            timerConfig?.dauerAnapana       = anapanaAnteil ?? 0
        }
    }
    private var vipassanaAnteil:Int32?{
        didSet{
            vipassanaLabel.text             = "\((vipassanaAnteil ?? 0) / 60)"
            timerConfig?.dauerVipassana     = vipassanaAnteil ?? 0
        }
    }
    private var mettaAnteil:Int32?{
        didSet{
            mettaLabel.text                 = mettaOpenEnd ? "\u{221E}" : "\((mettaAnteil ?? 0) / 60)"
            timerConfig?.dauerMetta         = mettaAnteil ?? 0
        }
    }
    
    
    //Outlets
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!{ didSet{ tapGestureRecognizer.isEnabled  = zeigeSteuerungsPanel}}
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        controlTappedDelegate?.controlTapped()
    }
    @IBOutlet weak var nameLabel: UILabel!{didSet{ nameLabel?.text     = timerConfig?.name }}
    @IBOutlet weak var anapanaLabel: UILabel!
    @IBOutlet weak var vipassanaLabel: UILabel!
    @IBOutlet weak var mettaLabel: UILabel!
    @IBOutlet weak var gesamtDauerLabel: UILabel!
    @IBOutlet weak var rangeSlider: YSRangeSlider!{
        didSet{
            rangeSlider.delegate    = self
            rangeSlider.isEnabled   = isEnabled
            
            //Rahmen
            layer.borderColor   = UIColor.lightGray.cgColor
            layer.borderWidth   = 1
            layer.cornerRadius  = 10.0
            clipsToBounds       = true
        }
    }
    @IBOutlet weak var startenButton: UIButton!
    @IBOutlet weak var beendenButton: UIButton!
    @IBAction func startenButtonPressed(_ sender: UIButton) {
        if sender.currentTitle == "starten"{
            starteTimer()
            sender.setTitle("pausieren", for:.normal)
            beendenButton.isHidden  = false
        }else if sender.currentTitle == "pausieren"{
            pauseTimer()
            sender.setTitle("fortsetzen", for:.normal)
        }else if sender.currentTitle == "fortsetzen"{
            restartTimer()
            sender.setTitle("pausieren", for:.normal)
        }else if sender.currentTitle == "fertig"{
            endWithMettaOpenEnd()
            resetTimer()
        }
    }
    
    private func endWithMettaOpenEnd(){
        if let backgroundInfo = BackgroundInfo.getInfo(), let vipassanaEnde = backgroundInfo.vipassanaEnde as? Date{
                let now = Date()
                backgroundInfo.meditation?.dauerMetta   = Int32(now.timeIntervalSince(vipassanaEnde))
                backgroundInfo.meditation?.ende         = now as NSDate?
                let _timerConfig = timerConfig
                timerConfig = _timerConfig
            }
    }
    @IBAction func beendenButtonPressed(_ sender: UIButton) {
        sender.isHidden                 = true
        if startenButton.currentTitle == "fertig"{
            endWithMettaOpenEnd()
        }else{
            BackgroundInfo.getInfo()?.meditation?.earlyEnd(date:Date())
        }
        startenButton.isHidden  = false
        startenButton.setTitle("starten", for:.normal)
        resetTimer()
    }
    @IBOutlet weak var hoeheSteuerungPanel: NSLayoutConstraint!{ didSet{ hoeheSteuerungPanel?.constant = zeigeSteuerungsPanel ? 40 : 0 } }
    
    
    //Delegates
    func rangeSliderDidChange(_ rangeSlider: YSRangeSlider, minimumSelectedValue: CGFloat, maximumSelectedValue: CGFloat) {
        //User Eingabe
        if !initSlider{
            anapanaAnteil   = Int32(minimumSelectedValue)
            vipassanaAnteil = Int32(maximumSelectedValue) - Int32(minimumSelectedValue)
            mettaAnteil     = Int32(rangeSlider.maximumValue) - Int32(maximumSelectedValue)
        }
        
        //rechter Daumen wird bei mettaOpenEnd = true bewegt
        if mettaOpenEnd && rangeSlider.maximumValue != maximumSelectedValue && gesamtDauerWirdGesetzt == false {
            
            mettaOpenEnd = false
            delegate?.rechterDaumenBeiMettaOpenEndBewegt()
        }
        

    }
    var delegate:TimerConfigViewDelegate?
    var controlTappedDelegate:TimerConfigViewDelegateControlTapped?
    
    //MARK: TIMER FUNCTIONS
    //Timer Funktionalität
    private var startTime:Date?
    private var startPauseTime:Date?
    private var pausenDauer = TimeInterval(0)
    private var subTimers = [Timer]()
    
    private var sekundenTimer:Timer?
    private func starteTimer(){
        if startPauseTime == nil{
            startTime                           = Date()
            let backgroundInfo                  = BackgroundInfo.getInfo()
            backgroundInfo?.meditationsStart    = Date() as NSDate?
            backgroundInfo?.meditation          = Meditation.new(start: startTime!,mettaOpenEnd: mettaOpenEnd, name: timerConfig?.name)
            initAblaufBalken()
        }
        //Endzeitpunkte berechnen für "Bings"
        let anapanaDauer    = TimeInterval(anapanaAnteil ?? 0)
        let vipassanaDauer  = TimeInterval(vipassanaAnteil ?? 0)
        let mettaDauer      = TimeInterval(mettaAnteil ?? 0)
        
        let anapanaEnde     = startTime!.addingTimeInterval(anapanaDauer+pausenDauer)
        let vipassanaEnde   = anapanaEnde.addingTimeInterval(vipassanaDauer)
        let meditationsEnde = vipassanaEnde.addingTimeInterval(mettaDauer)
        
        let backgroundInfo  = BackgroundInfo.set(anapana: anapanaEnde, vipassana: vipassanaEnde, ende: meditationsEnde)
        backgroundInfo?.meditation?.dauerAnapana    = Int32(anapanaDauer)
        backgroundInfo?.meditation?.dauerVipassana  = Int32(vipassanaDauer)
        backgroundInfo?.meditation?.dauerMetta      = Int32(mettaDauer)
        backgroundInfo?.meditation?.ende            = meditationsEnde as NSDate?

        //Timer, der sekündlich tickt - für Anzeige Countdown
        sekundenTimer       = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(sekundenTicker(_:)), userInfo: nil, repeats: true)
        sekundenTimer?.fire()
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.scheduleForegroundTimers()
        delegate?.saveContext()
        
        guard let backgroundInfos = backgroundInfo else{return}
        print("anapanaEnde:\((backgroundInfos.anapanaEnde as! Date).string("hh:mm")) vipassanaEnde:\((backgroundInfos.vipassanaEnde as! Date).string("hh:mm")) meditationsEnde:\((backgroundInfos.meditationsEnde as! Date).string("hh:mm"))")
    }
    
    func resetTimer(){
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.invalidateForegroundTimers()
        
        sekundenTimer?.invalidate()
        beendenButton.isHidden              = true
        startenButton.setTitle("starten", for: .normal)
        
        startTime                           = nil
        startPauseTime                      = nil
        pausenDauer                         = TimeInterval(0)
        
        rangeSlider.resetAblaufTimer()
    }
    func pauseTimer(){
        startPauseTime = Date()
        sekundenTimer?.invalidate()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.invalidateForegroundTimers()
    }
    func restartTimer(){
        let now = Date()
        let aktuellePause = now.timeIntervalSince(startPauseTime!)
        pausenDauer += aktuellePause
        BackgroundInfo.getInfo()?.meditation?.addPause(start: startPauseTime!, ende: now)
        starteTimer()
    }
    @objc private func sekundenTicker(_ sender:Timer){
        setAblaufBalkenAndDaumen()
    }
    private func setAblaufBalkenAndDaumen(){
        let backgroundInfo      = BackgroundInfo.getInfo()
        if let start = backgroundInfo?.meditationsStart, let ende  = backgroundInfo?.meditationsEnde, let anapanaEnde = backgroundInfo?.anapanaEnde, let vipassanaEnde = backgroundInfo?.vipassanaEnde{
            let ergebnis = rangeSlider.setAblaufBalkenAndDaumen(start: start as Date, ende: ende as Date, pausenDauer: pausenDauer, gesamtDauerLabel: gesamtDauerLabel, anapanaEnde: anapanaEnde as Date, vipassanaEnde: vipassanaEnde as Date,mettaOpenEnd: mettaOpenEnd)
            if ergebnis.finish{
                
                //zurücksetzen
                if mettaOpenEnd{
                    startenButton.setTitle("fertig", for:.normal)
                    startenButton.isHidden = true
                }else{
                    sekundenTimer?.invalidate()
                    beendenButton.isHidden                 = true
                    startenButton.setTitle("starten", for:.normal)
                    //resetTimer()
                }
            }
            
//            if ergebnis.gong{
//                guard let delegate = UIApplication.shared.delegate as? AppDelegate else{return}
//                if delegate.playSound(){mettaLabel.text = "played Sound"}else{mettaLabel.text = "Fehler"}
//            }
            
        }
    }
    private func initAblaufBalken(){
        rangeSlider.coverSlider()
    }
}
protocol TimerConfigViewDelegate {
    func rechterDaumenBeiMettaOpenEndBewegt()
}

protocol TimerConfigViewDelegateControlTapped {
    func controlTapped()
}



