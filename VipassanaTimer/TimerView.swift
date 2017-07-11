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

class TimerView:NibLoadingView,YSRangeSliderDelegate{
    var timerConfig:TimerConfig?
    override var nibName: String{
        return "TimerView"
    }
    var zeigeSteuerungsPanel = false{
        didSet{
            hoeheSteuerungPanel?.constant   = zeigeSteuerungsPanel ? 40 : 0
            tapGestureRecognizer?.isEnabled  = zeigeSteuerungsPanel
        }
    }
    
    //MARK: Buttons & Actions
    @IBOutlet weak var startenButton: UIButton!
    @IBOutlet weak var beendenButton: UIButton!
    @IBAction func startenPressed(_ sender: UIButton) { }
    @IBAction func beendenPressed(_ sender: UIButton) { }
    @IBAction func controlTapped(_ sender: UITapGestureRecognizer) { controlTappedDelegate?.controlTapped() }
    
    //MARK: Outlets
    @IBOutlet weak var anapanaLabel: UILabel!
    @IBOutlet weak var vipassanaLabel: UILabel!
    @IBOutlet weak var mettaLabel: UILabel!
    @IBOutlet weak var gesamtDauerLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rangeSlider: YSRangeSlider!{
        didSet{
            rangeSlider.delegate = self
            rangeSlider.coverSlider()
        }
    }
    @IBOutlet weak var blurView: UIVisualEffectView!{
        didSet{
            //abgerudnete Ecken (init ... irgendwo)
            layer.borderColor       = DesignPatterns.mocha.cgColor
            layer.borderWidth       = 0.5
            layer.cornerRadius      = 10.0
            clipsToBounds           = true
        }
    }
    
    @IBOutlet weak var hoeheSteuerungPanel: NSLayoutConstraint!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
        { didSet{ tapGestureRecognizer.isEnabled  = zeigeSteuerungsPanel}}
    
    
    func rangeSliderDidChange(_ rangeSlider: YSRangeSlider, minimumSelectedValue: CGFloat, maximumSelectedValue: CGFloat) { }
    
    
    weak var controlTappedDelegate:TimerConfigViewDelegateControlTapped?
    
    func setSlider(max:TimeInterval,maxSel:TimeInterval,minSel:TimeInterval){
        rangeSlider.maximumValue            = CGFloat(max)
        rangeSlider.maximumSelectedValue    = CGFloat(maxSel)
        rangeSlider.minimumSelectedValue    = CGFloat(minSel)
    }
    
    @IBAction func tappedOnEmptyTimer(_ sender: UITapGestureRecognizer) {
        controlTappedDelegate?.controlTapped()
    }
    
    func setLabels(){
        guard let timerConfig = timerConfig  else {return}
        
        //Labels setzen
        nameLabel.text                      = timerConfig.name
        anapanaLabel.dauer                  = TimeInterval( timerConfig.dauerAnapana )
        vipassanaLabel.dauer                = TimeInterval( timerConfig.dauerVipassana )
        mettaLabel.dauer                    = TimeInterval( timerConfig.dauerMetta )
        gesamtDauerLabel.text               = timerConfig.gesamtDauer.hhmmString
        if timerConfig.mettaOpenEnd{
            mettaLabel.text                 = "\u{221E}"
        }
    }
}

protocol TimerConfigViewDelegateControlTapped : class {
    func controlTapped()
}

extension UILabel{
    var dauer:TimeInterval{
        get{
            guard let _text = text,let dauer = TimeInterval(_text) else {return 0}
            return dauer * 60
        }
        set{
            text = String(Int(newValue / 60))
        }
    }
}
