//
//  TimerSettingsView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
@IBDesignable class SettingsForTimerView:NibLoadingView{
    var viewModel:SettingsForTimerViewModel!{
        didSet{
            //get
            anapanaSlider.reactive.value        <~ viewModel.anapanaSliderValue.producer
            mettaSlider.reactive.value          <~ viewModel.mettaSliderValue.producer
            anapanaSlider.reactive.maximumValue <~ viewModel.anapanaSliderMax.producer
            mettaSlider.reactive.maximumValue   <~ viewModel.mettaSliderMax.producer
            mettaOhneEndeSwitch.reactive.isOn   <~ viewModel.mettaEndlosSwitchIsOn.producer
            timerTitleTextField.reactive.text   <~ viewModel.titleTextFieldText.producer
            klangSchalenSwitch.reactive.isOn    <~ viewModel.soundSchalenSwitchIson.producer
            
            viewModel.gesamtDauerDatePicker.producer.startWithValues{[weak self] dauer in
                DispatchQueue.main.async { self?.gesamtDauerDatePicker.countDownDuration = dauer }//Apple Bug?
            }
            //SoundFileData
            mettaSlider.reactive.isEnabled              <~ viewModel.hasSoundFile.producer.map{!$0}
            mettaOhneEndeSwitch.reactive.isEnabled      <~ viewModel.hasSoundFile.producer.map{!$0}
            gesamtDauerDatePicker.reactive.isEnabled    <~ viewModel.hasSoundFile.producer.map{!$0}
            klangSchalenStack.reactive.isHidden         <~ viewModel.hasSoundFile.producer.map{!$0}
            mettaOhneEndeStack.reactive.isHidden        <~ viewModel.hasSoundFile.producer
            
            
            //set
            anapanaSlider.reactive.values.observeValues {[weak self] newValue in self?.viewModel.setNewSliderValues(dauer: TimeInterval(round(newValue) * 60), meditationsTyp: .anapana)}
            mettaSlider.reactive.values.observeValues   {[weak self] newValue in  self?.viewModel.setNewSliderValues(dauer: TimeInterval(round(newValue) * 60), meditationsTyp: .metta)}
            mettaOhneEndeSwitch.reactive.isOnValues.observeValues           {[weak self] newValue in  self?.viewModel.setMettaEndlos(isEndlos: newValue)}
            timerTitleTextField.reactive.continuousTextValues.observeValues {[weak self] newValue in  self?.viewModel.setTitle(title: newValue)}
            klangSchalenSwitch.reactive.isOnValues.observeValues            {[weak self] newValue in  self?.viewModel.setSoundSchalenAreOn(areOn: newValue)}
            gesamtDauerDatePicker.reactive.controlEvents(.valueChanged).signal.observeValues
                {[weak self] picker in self?.viewModel.setGesamtDauerPickerValue(dauer: picker.countDownDuration)}
            
            //Schriftfarbe des Pickers
            gesamtDauerDatePicker.setValue(standardSchriftFarbe, forKey: "textColor")
            
            self.setStandardDesign()
        }
    }
    
    //IBOutlets
    @IBOutlet weak var anapanaSlider: UISlider!
    @IBOutlet weak var mettaSlider: UISlider!
    @IBOutlet weak var mettaOhneEndeSwitch: UISwitch!
    @IBOutlet weak var timerTitleTextField: UITextField!
    @IBOutlet weak var gesamtDauerDatePicker: UIDatePicker!
    @IBOutlet weak var mettaOhneEndeStack: UIStackView!
    @IBOutlet weak var klangSchalenStack: UIStackView!
    @IBOutlet weak var klangSchalenSwitch: UISwitch!
    
    deinit { print("deinit SettingsForTimerView") }
}

//✅
// Timer Settings View - enthält SettingsForTimerView
@IBDesignable class TimerSettingsView:NibLoadingView{
    var viewModel:TimerSettingsViewModel!{
        didSet{
            timerAnzeige.viewModel      = viewModel.settingsForTimerViewModel
            settingsForTimer.viewModel  = viewModel.settingsForTimerViewModel
            soundFileView.viewModel     = viewModel.soundFileViewModel
        }
    }
    
    //IBOutlets
    @IBOutlet weak var timerAnzeige: TimerAnzeigeView!
    @IBOutlet weak var settingsForTimer: SettingsForTimerView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var soundFileView: SoundFileView!
    
    deinit { print("deinit TimerSettingsView") }
}
