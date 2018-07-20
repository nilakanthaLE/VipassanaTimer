//
//  TimerSettingsViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
//ViewModel für die Konfiguration des Timers
class TimerSettingsViewModel{
    let settingsForTimerViewModel:SettingsForTimerViewModel
    let soundFileViewModel:SoundFileViewModel
    init(model:TimerSettingsModel){
        settingsForTimerViewModel   = SettingsForTimerViewModel(model: model)
        soundFileViewModel          = SoundFileViewModel(soundFileData: model.soundFileData)
    }
    deinit {  print("deinit TimerSettingsViewModel") }
}
class SettingsForTimerViewModel:TimerAnzeigeViewModel{
    let anapanaSliderMax            = MutableProperty<Float>(60)
    let mettaSliderMax              = MutableProperty<Float>(60)
    let anapanaSliderValue          = MutableProperty<Float>(5)
    let mettaSliderValue            = MutableProperty<Float>(5)
    let gesamtDauerDatePicker       = MutableProperty<TimeInterval>(0)
    let mettaEndlosSwitchIsOn       = MutableProperty<Bool>(false)
    let titleTextFieldText          = MutableProperty<String?>(nil)
    let soundSchalenSwitchIson      = MutableProperty<Bool>(false)
    let hasSoundFile                = MutableProperty<Bool>(false)
    
    let model:TimerSettingsModel
    init(model:TimerSettingsModel){
        self.model = model
        super.init(model: model)
        
        //get
        anapanaSliderValue          <~ model.anapanaDauer.map{Float($0 / 60)}
        mettaSliderValue            <~ model.mettaDauer.map{Float($0 / 60)}
        anapanaSliderMax            <~ model.gesamtDauer.producer.map{Float($0 / 60)}
        mettaSliderMax              <~ model.gesamtDauer.producer.map{Float($0 / 60)}
        gesamtDauerDatePicker       <~ model.gesamtDauer.producer
        mettaEndlosSwitchIsOn       <~ model.mettaEndlos.producer
        titleTextFieldText          <~ model.meditationTitle.producer
        soundSchalenSwitchIson      <~ model.soundSchalenSwitchIsOn.producer
        hasSoundFile                <~ model.soundFileData.map{$0 != nil}
    }
    
    //set Actions (von View aufgerufen)
    func setGesamtDauerPickerValue(dauer:TimeInterval)                          { model.timerData.value = model.timerData.value.setGesamtDauer(dauer) }
    func setNewSliderValues(dauer:TimeInterval,meditationsTyp:MeditationsTyp)   { model.timerData.value = model.timerData.value.setAnapanaUndMetta(newValue: dauer, meditationTyp: meditationsTyp) }
    func setTitle(title:String?)                                                { model.timerData.value = model.timerData.value.setTitle(title) }
    func setMettaEndlos(isEndlos:Bool)                                          { model.timerData.value = model.timerData.value.setMettaEndlos(isEndlos) }
    func setSoundSchalenAreOn(areOn:Bool)                                       { model.timerData.value = model.timerData.value.setSoundSchalenAreOn(areOn)  }
    
    deinit { print("deinit SettingsForTimerViewModel") }
}
