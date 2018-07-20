//
//  MeditationsTimerVCModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 31.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift

//✅
// starten und beenden einer Meditation
// Anzeige gerade meditierend
class MeditationsTimerVCModel{
    private let gewaehlterTimerFuerMeditation   = MutableProperty<TimerData>(TimerData())
    let tappedMeditationsPlatz                  = MutableProperty<PublicMeditation?>(nil)
    let firebaseActiveMeditationsListModel      = FireBaseActiveMeditationsListModel()
    init(){
        var activeTimer:TimerData{
            guard let active = TimerConfig.getActive() else { return TimerData() }
            return TimerData(timerConfig: active)
        }
        gewaehlterTimerFuerMeditation.value = activeTimer
        gewaehlterTimerFuerMeditation.signal.observeValues{ $0.setTimerConfigToActive() }
    }
    
    //ViewModels
    func getGeradeMeditiertViewModel() -> GeradeMeditiertViewModel  { return GeradeMeditiertViewModel(tappedMeditationsPlatz: tappedMeditationsPlatz,aktuelleMeditationen:firebaseActiveMeditationsListModel.aktuelleMeditationen) }
    func getTimerAsTimerViewModel() -> TimerAsTimerViewModel        { return TimerAsTimerViewModel(model: TimerAsTimerModel(gewaehlerTimer: gewaehlterTimerFuerMeditation,myMeditation:firebaseActiveMeditationsListModel.myMeditation) ) }
    func getTimerTableVCViewModel() -> TimerTableVCModel            { return TimerTableVCModel( model: MeineTimerModel(gewaehlerTimer: gewaehlterTimerFuerMeditation)) }
    
    deinit { print("deinit MeditationsTimerVCModel") }
}
