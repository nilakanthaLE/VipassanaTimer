//
//  TimerSettingsModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 11.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
class TimerSettingsModel:TimerAnzeigeModel{
    let soundFileData           = MutableProperty<SoundFileData?>(nil)
    let soundSchalenSwitchIsOn  = MutableProperty<Bool>(false)
    
    override init(timerData: TimerData) {
        super.init(timerData: timerData)
        soundFileData.value             = timerData.soundFileData
        soundSchalenSwitchIsOn.value    = timerData.soundSchalenAreOn
        soundFileData.signal.observeValues{[weak self] soundFileData in
            guard let strongSelf        = self else {return}
            strongSelf.timerData.value  = strongSelf.timerData.value.setSoundFileData(soundFileData)
        }
    }
    deinit { print("deinit TimerSettingsModel") }
}
