//
//  TimerInPublicMeditationInfoViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation

//✅
class TimerInPublicMeditationInfoViewModel:TimerAnzeigeViewModel{
    let model:TimerInPublicMeditationInfoModel
    init(model:TimerInPublicMeditationInfoModel){
        self.model = model
        super.init(model: model)
    }
    deinit { print("deinit TimerInPublicMeditationInfoViewModel") }
}
