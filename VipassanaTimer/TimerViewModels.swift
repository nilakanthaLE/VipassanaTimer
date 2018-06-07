//
//  TimerViewModels.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 01.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift



//MARK: TimerSettingsViewModel
//ViewModel für die Konfiguration des Timers
class TimerSettingsViewModel{
    let settingsForTimerViewModel:SettingsForTimerViewModel
    let soundFileViewModel:SoundFileViewModel
    init(model:TimerSettingsModel){
        settingsForTimerViewModel   = SettingsForTimerViewModel(model: model)
        soundFileViewModel          = SoundFileViewModel(soundFileData: model.soundFileData)
        
        
//        model.timerData.value = model.timerData.value.setSoundFileData(<#T##soundFileData: SoundFileData?##SoundFileData?#>)
    }
    
//    func setSoundFileData(soundFileData:SoundFileData){
//        model.timerData.value = model.timerData.value.setGesamtDauer(dauer)
//    }
    deinit {  print("deinit TimerSettingsViewModel") }
}



//MARK: TimerAnzeigeViewModel
// zentrales ViewModel - SuperClass
class TimerAnzeigeViewModel{
    let zeitAnzeige         = MutableProperty<String> ("1:00")
    let anapanaWidth        = MutableProperty<CGFloat> (20.0)
    let mettaWidth          = MutableProperty<CGFloat> (20)
    let ablaufWidth         = MutableProperty<CGFloat> (0)
    let anapanaDauerTitle   = MutableProperty<String> ("5")
    let vipassanaDauerTitle = MutableProperty<String> ("5")
    let mettaDauerTitle     = MutableProperty<String> ("5")
    let timerTitle          = MutableProperty<String?>   ("")
    let hasSoundFileLabelIsHidden   = MutableProperty<Bool> (false)
    
    
    let viewWidth           = MutableProperty<CGFloat> (0)
    init(model:TimerAnzeigeModel){
        print("init TimerAnzeigeViewModel")
        
        //Anzeige
        timerTitle          <~ model.meditationTitle.producer
        anapanaWidth        <~ model.anapanaAnteil.producer.map { [weak self] value in value * (self?.viewWidth.value ?? 0)}
        mettaWidth          <~ model.mettaAnteil.producer.map   { [weak self] value in  value * (self?.viewWidth.value ?? 0)}
        zeitAnzeige         <~ model.anzeigeDauer.producer
        anapanaDauerTitle   <~ model.anapanaDauer.producer.map{"\(Int($0 / 60))"}
        vipassanaDauerTitle <~ model.vipassanaDauer.producer.map{"\(Int($0 / 60))"}
        mettaDauerTitle     <~ model.mettaDauer.producer.map{"\(Int($0 / 60))"}
        
        mettaDauerTitle     <~ model.mettaEndlos.producer.map{$0 ? "∞" : "\(Int(model.mettaDauer.value / 60))"}
        hasSoundFileLabelIsHidden <~ model.hasSoundFile.producer.map{!$0}
        
        anapanaWidth        <~ viewWidth.map{ model.anapanaAnteil.value * $0 }
        mettaWidth          <~ viewWidth.map{ model.mettaAnteil.value * $0 }

        // Timer
        ablaufWidth     <~ model.verdeckAnteil.producer.map{[weak self] value in value * (self?.viewWidth.value ?? 0)}
        ablaufWidth     <~ viewWidth.map{ model.verdeckAnteil.value * $0 }
        
        model.vipassanaDauer.producer.startWithValues{print("vipassanaDauer : \($0.hhmmss)")}
    }
    deinit { print("deinit TimerAnzeigeViewModel") }
}


class TimerInPublicMeditationInfoViewModel:TimerAnzeigeViewModel{
    let model:TimerInPublicMeditationInfoModel
    init(model:TimerInPublicMeditationInfoModel){
        self.model = model
        super.init(model: model) }
    
    deinit {
        model.timerBeenden()
        print("deinit TimerInPublicMeditationInfoViewModel")
    }
}

//MARK: TimerAsTimerViewModel
class TimerAsTimerViewModel:TimerAnzeigeViewModel{
    //view relevant
    let beendenButtonIsHidden   = MutableProperty<Bool>(true)
    let startButtonTitle        = MutableProperty<String>("starten")
    let anapanaBeendet          = MutableProperty<Void>(Void())
    let vipassanaBeendet        = MutableProperty<Void>(Void())
    let meditationBeendet       = MutableProperty<Void>(Void())
    
    //Actions
    let startButtonPressed      = MutableProperty<Void>(Void())
    let beendenButtonPressed    = MutableProperty<Void>(Void())
    
    let model:TimerAsTimerModel
    init(model:TimerAsTimerModel){
        self.model = model
        super.init(model: model)
        //starten und pausieren
        model.timerState        <~ startButtonPressed.signal.map    {_ in model.timerState.value.nextStartPressed}
        //beenden
        model.timerState        <~ beendenButtonPressed.signal.map  {_ in .nichtGestartet}
        
        startButtonTitle        <~ model.timerState.producer.map{$0.startButtonTitle}
        beendenButtonIsHidden   <~ model.timerState.producer.map{$0.beendenButtonIsHidden}
        
        anapanaBeendet          <~ model.anapanaBeendet.signal
        vipassanaBeendet        <~ model.vipassanaBeendet.signal
        meditationBeendet       <~ model.meditationBeendet.signal
    }
    
    deinit {
        model.timerBeenden()
        print("deinit TimerAsTimerViewModel") }
}

//MARK: SeetingsForTimer ViewModel
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
        
        //SoundFileData
        hasSoundFile                <~ model.soundFileData.map{$0 != nil}    }
    deinit { print("deinit SettingsForTimerViewModel") }
    
    
    func setGesamtDauerPickerValue(dauer:TimeInterval){
        model.timerData.value = model.timerData.value.setGesamtDauer(dauer)
    }
    func setNewSliderValues(dauer:TimeInterval,meditationsTyp:MeditationsTyp){
        model.timerData.value = model.timerData.value.setAnapanaUndMetta(newValue: dauer, meditationTyp: meditationsTyp)
    }
    func setTitle(title:String?){
        model.timerData.value = model.timerData.value.setTitle(title)
    }
    func setMettaEndlos(isEndlos:Bool){
        model.timerData.value   = model.timerData.value.setMettaEndlos(isEndlos)
    }
    func setSoundSchalenAreOn(areOn:Bool){
        model.timerData.value   = model.timerData.value.setSoundSchalenAreOn(areOn)
    }
}




