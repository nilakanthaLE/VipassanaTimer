//
//  MeditationsTimerModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 31.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

class MeditationsTimerModel{
    private let gewaehlterTimerFuerMeditation = MutableProperty<TimerData>(TimerData())
    
    init(){
        var activeTimer:TimerData{
            guard let active = TimerConfig.getActive() else { return TimerData() }
            return TimerData(timerConfig: active)
        }
        gewaehlterTimerFuerMeditation.value = activeTimer
        
        gewaehlterTimerFuerMeditation.signal.observeValues{ $0.setTimerConfigToActive() }
        
    }
    
    func getTimerAsTimerModel() -> TimerAsTimerModel            { return TimerAsTimerModel(gewaehlerTimer: gewaehlterTimerFuerMeditation) }
    func getMeineTimerModel() -> MeineTimerModel                { return MeineTimerModel(gewaehlerTimer: gewaehlterTimerFuerMeditation) }
    func getGeradeMeditiertModel() -> GeradeMeditiertModel      { return GeradeMeditiertModel() }
    
    deinit { print("deinit MeditationsTimerModel") }
}
