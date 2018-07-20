//
//  TimerSettingsVCModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation

//✅
class TimerSettingsViewControllerModel{
    let timerSettingsModel:TimerSettingsModel
    init(timerData:TimerData){ timerSettingsModel = TimerSettingsModel(timerData: timerData) }
    
    //ViewModels
    func getViewModelForSettingsView() -> TimerSettingsViewModel        { return TimerSettingsViewModel(model: timerSettingsModel) }
    func getViewModelForSoundFilesTableVC() -> SoundFilesTableVCModel   { return SoundFilesTableVCModel(soundFileData:timerSettingsModel.soundFileData)  }
    
    deinit { print("deinit TimerSettingsVCModel")  }
}
