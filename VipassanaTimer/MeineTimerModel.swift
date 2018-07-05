//
//  MeineTimerModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 31.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

//MARK: MainModel
class MeineTimerModel{
    let gewaehlterTimerFuerMeditation   = MutableProperty<TimerData>(TimerData())
    init(gewaehlerTimer:MutableProperty<TimerData>)     { gewaehlerTimer <~ gewaehlterTimerFuerMeditation.signal }
    
    let timerDatas                      = MutableProperty<[TimerData]>(TimerConfig.getAll().map{TimerData(timerConfig: $0)})
    func addTimerData() -> TimerData{
        print("addTimerData")
        let new = TimerData(timerConfig: TimerConfig.create())
        timerDatas.value.append(new)
        return new
    }
    func removeTimerData(at index:Int){
        let toRemove = timerDatas.value[index]
        toRemove.deleteTimerConfig()
        timerDatas.value.remove(at: index)
    }
    
}
