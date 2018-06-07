//
//  MeditationsTimerVCModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 31.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

class MeditationsTimerVCModel{
    let model:MeditationsTimerModel
    init(model:MeditationsTimerModel){
        self.model          = model
    }
    
    
    func getTimerAsTimerViewModel() -> TimerAsTimerViewModel{
        return TimerAsTimerViewModel(model: model.getTimerAsTimerModel())
    }
    func getGeradeMeditiertViewModel() -> GeradeMeditiertViewModel{
        return GeradeMeditiertViewModel(model: model.getGeradeMeditiertModel())
    }
    func getTimerTableVCViewModel() -> TimerTableVCModel{
        return TimerTableVCModel( model: model.getMeineTimerModel())
    }
    
    deinit { print("deinit MeditationsTimerViewControllerModel") }
}
