//
//  TimerAnzeigeViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
// zentrales ViewModel - SuperClass

import ReactiveSwift

//✅
class TimerAnzeigeViewModel{
    //angezeigt
    let zeitAnzeige                 = MutableProperty<String> ("1:00")
    let anapanaWidth                = MutableProperty<CGFloat> (20.0)
    let mettaWidth                  = MutableProperty<CGFloat> (20)
    let ablaufWidth                 = MutableProperty<CGFloat> (0)
    let anapanaDauerTitle           = MutableProperty<String> ("5")
    let vipassanaDauerTitle         = MutableProperty<String> ("5")
    let mettaDauerTitle             = MutableProperty<String> ("5")
    let timerTitle                  = MutableProperty<String?>   ("")
    let hasSoundFileLabelIsHidden   = MutableProperty<Bool> (false)
    
    //gesetzt
    let viewWidth                   = MutableProperty<CGFloat> (0)
    
    init(model:TimerAnzeigeModel){
        //Anzeige
        timerTitle                  <~ model.meditationTitle.producer
        anapanaWidth                <~ model.anapanaAnteil.producer.map { [weak self] value in value * (self?.viewWidth.value ?? 0)}
        mettaWidth                  <~ model.mettaAnteil.producer.map   { [weak self] value in  value * (self?.viewWidth.value ?? 0)}
        zeitAnzeige                 <~ model.anzeigeDauer.producer
        anapanaDauerTitle           <~ model.anapanaDauer.producer.map{"\(Int($0 / 60))"}
        vipassanaDauerTitle         <~ model.vipassanaDauer.producer.map{"\(Int($0 / 60))"}
        mettaDauerTitle             <~ model.mettaDauer.producer.map{"\(Int($0 / 60))"}
        mettaDauerTitle             <~ model.mettaEndlos.producer.map{$0 ? "∞" : "\(Int(model.mettaDauer.value / 60))"}
        hasSoundFileLabelIsHidden   <~ model.hasSoundFile.producer.map{!$0}
        anapanaWidth                <~ viewWidth.map{ model.anapanaAnteil.value * $0 }
        mettaWidth                  <~ viewWidth.map{ model.mettaAnteil.value * $0 }
        
        // Timer
        ablaufWidth         <~ model.verdeckAnteil.producer.map{[weak self] value in value * (self?.viewWidth.value ?? 0)}
        ablaufWidth         <~ viewWidth.map{ model.verdeckAnteil.value * $0 }
    }
    deinit { print("deinit TimerAnzeigeViewModel") }
}
