//
//  TimerAsTimerViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift

//✅
class TimerAsTimerViewModel:TimerAnzeigeViewModel{
    //angezeigt
    let beendenButtonIsHidden   = MutableProperty<Bool>(true)
    let startButtonTitle        = MutableProperty<String>("starten")
    //Actions
    let startButtonPressed      = MutableProperty<Void>(Void())
    let beendenButtonPressed    = MutableProperty<Void>(Void())
    
    let model:TimerAsTimerModel
    init(model:TimerAsTimerModel){
        self.model = model
        super.init(model: model)
        
        //angezeigt
        startButtonTitle        <~ model.timerState.producer.map{$0.startButtonTitle}
        beendenButtonIsHidden   <~ model.timerState.producer.map{$0.beendenButtonIsHidden}
        
        //starten und pausieren
        model.timerState        <~ startButtonPressed.signal.map    {_ in model.timerState.value.nextStartPressed}
        
        //beenden
        model.timerState        <~ beendenButtonPressed.signal.map  {_ in .nichtGestartet}
    }
    
    deinit { print("deinit TimerAsTimerViewModel") }
}
