//
//  TimerControlConfig.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 13.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import YSRangeSlider


class TimerControlConfig:TimerView{
    override var timerConfig:TimerConfig?{didSet{setSlider()}}
    weak var delegate:TimerConfigViewDelegate?
    
    private var willSetSlider = false
    private func setSlider(){
        guard let timerConfig = timerConfig else{return}
        willSetSlider = true
        rangeSlider.maximumValue            = CGFloat(timerConfig.gesamtDauer)
        rangeSlider.maximumSelectedValue    = CGFloat(timerConfig.dauerAnapana + timerConfig.dauerVipassana)
        rangeSlider.minimumSelectedValue    = CGFloat(timerConfig.dauerAnapana)
        willSetSlider       = false
        
        setLabels()
        blurView.isHidden       = true
        zeigeSteuerungsPanel    = false
    }
    
    override func rangeSliderDidChange(_ rangeSlider: YSRangeSlider, minimumSelectedValue: CGFloat, maximumSelectedValue: CGFloat) {
        //nur bei User Eingabe
        guard !willSetSlider, let timerConfig = timerConfig else{return}
        timerConfig.dauerAnapana           = Int32(minimumSelectedValue)
        timerConfig.dauerVipassana         = Int32(maximumSelectedValue - minimumSelectedValue)
        timerConfig.dauerMetta             = Int32(rangeSlider.maximumValue - maximumSelectedValue)
        
        //rechter Daumen wird bei mettaOpenEnd = true bewegt
        if timerConfig.mettaOpenEnd == true{
            mettaOpenEnd = false
            delegate?.rechterDaumenBeiMettaOpenEndBewegt()
        }
        setLabels()
    }
    
    var mettaOpenEnd=false{
        didSet{
            guard let timerConfig       = timerConfig else{return}
            timerConfig.mettaOpenEnd    = mettaOpenEnd
            if mettaOpenEnd == true && oldValue == false{
                timerConfig.dauerVipassana      += Int32(timerConfig.dauerMetta)
                timerConfig.dauerMetta          = 0
            }
            setSlider()
        }
    }
    
    private var gesamtDauerWirdGesetzt = false
    var gesamtDauer:TimeInterval = 3600{
        willSet{
            guard let timerConfig = timerConfig else{return}
            let newValue = Int32(newValue)
            if newValue <= timerConfig.dauerAnapana{
                timerConfig.dauerAnapana            = newValue
                timerConfig.dauerVipassana          = 0
                timerConfig.dauerMetta              = 0
            }else if newValue <=  timerConfig.dauerAnapana + timerConfig.dauerVipassana{
                timerConfig.dauerVipassana          = newValue - timerConfig.dauerAnapana
                timerConfig.dauerMetta              = 0
            }else{
                timerConfig.dauerMetta              = newValue - timerConfig.dauerAnapana - timerConfig.dauerVipassana
            }
        }
        didSet{
            setSlider()
            gesamtDauerLabel.text       = gesamtDauer.hhmmString
            gesamtDauerLabel.sizeToFit()
            gesamtDauerWirdGesetzt = false
        }
    }
    
    deinit {
        print("deinit TimerControlConfig")
    }

}
