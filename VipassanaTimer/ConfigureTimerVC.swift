//
//  ConfigureTimerVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class ConfigureTimerVC: UIViewController,TimerConfigViewDelegate,UITextFieldDelegate {

    var timerConfig:TimerConfig?{
        didSet{
            timerConfigControl?.timerConfig = timerConfig
            
            let anteilAnapana   = timerConfig?.dauerAnapana ?? 0
            let anteilVipassana = timerConfig?.dauerVipassana ?? 0
            let anteilMetta     = timerConfig?.mettaOpenEnd == true ? 0: timerConfig?.dauerMetta ?? 0
            let gesamtDauer     = anteilAnapana + anteilVipassana + anteilMetta
            
            countDownTimePicker?.countDownDuration = TimeInterval.init(gesamtDauer)
            mettaOpenEndSwitch?.isOn = timerConfig?.mettaOpenEnd ?? false
            nameTextField?.text = timerConfig?.name
        }
    }
    
    
    @IBAction func mettaOpenEndSwitchValueChanged(_ sender: UISwitch) {
        timerConfigControl.mettaOpenEnd = sender.isOn
    }
    
    @IBAction func nameTextFieldCloses(_ sender: UITextField) {
        timerConfig?.name = sender.text
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBOutlet weak var nameTextField: UITextField!{
        didSet{
            nameTextField?.text = timerConfig?.name
        }
    }
    @IBOutlet private weak var mettaOpenEndSwitch: UISwitch!{
        didSet{
            mettaOpenEndSwitch?.isOn = timerConfig?.mettaOpenEnd ?? false
        }
    }
    @IBOutlet private weak var timerConfigControl: TimerConfigView!{
        didSet{
            timerConfigControl.isEnabled    = true
            timerConfigControl.timerConfig  = timerConfig
            timerConfigControl.delegate     = self
        }
    }
    
    @IBOutlet private weak var countDownTimePicker: UIDatePicker! {
        didSet{
            
            let anteilAnapana   = timerConfig?.dauerAnapana ?? 0
            let anteilVipassana = timerConfig?.dauerVipassana ?? 0
            let anteilMetta     = timerConfig?.mettaOpenEnd == true ? 0: timerConfig?.dauerMetta ?? 0
            let gesamtDauer     = Int(anteilAnapana + anteilVipassana + anteilMetta)
            let stunden         = gesamtDauer/60/60
            let minuten         = (gesamtDauer - stunden * 60 * 60) / 6
            
            //umgeht Bug, durch den die erste Wahl des Countdowns nichts bewirkt
            var dateComp : DateComponents = DateComponents()
            dateComp.hour           = stunden
            dateComp.minute         = minuten
            dateComp.timeZone       = NSTimeZone.system
            let calendar            = Calendar(identifier:Calendar.Identifier.gregorian)
            let date                = calendar.date(from: dateComp)!
            countDownTimePicker.setDate(date, animated: true)
        }
    }
    
    @IBAction private func countDownTimePickerValueChanged(_ sender: UIDatePicker) {
        timerConfigControl.gesamtDauer = Int32(sender.countDownDuration)
    }
    
    func rechterDaumenBeiMettaOpenEndBewegt() {
        mettaOpenEndSwitch?.isOn = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        countDownTimePicker.setValue(DesignPatterns.mocha, forKey: "textColor")
    }
}
