//
//  EditMeditationVCViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
// Meditationen im Kalender anpassen/löschen
class EditMeditationVCViewModel{
    let loeschenButtonIsHidden:Bool
    let startZeit       = MutableProperty<Date>(Date())
    let eintragenAction = MutableProperty<Void>(Void())
    let loeschenAction  = MutableProperty<Void>(Void())
    
    //init
    var meditation:Meditation?
    private let timerData:TimerData
    private let timerAnzeigeModel:TimerAnzeigeModel
    init(meditation:Meditation?,date:Date = Date()){
        timerData               = TimerData(meditation: meditation) ?? TimerData()
        timerAnzeigeModel       = TimerAnzeigeModel(timerData: timerData)
        self.meditation         = meditation
        loeschenButtonIsHidden  = meditation == nil
        startZeit.value         = meditation?.start ?? date
        
        eintragenAction.signal.observe{[weak self] _ in self?.meditationEintragenAction()}
        loeschenAction.signal.observe{[weak self] _ in self?.loeschenActionFunc()}
    }
    
    //ViewActions
    func meditationEintragenAction() {
        meditation = meditation?.update(with: timerData) ?? Meditation.new(timerData: timerData, start: startZeit.value)
        HealthManager().saveMeditationIfNeeded(meditation: meditation!)
        FirMeditations.update(meditation: meditation!)
        saveContext()
    }
    func loeschenActionFunc() {
        FirMeditations.deleteMeditation(meditation:meditation)
        meditation?.delete(inFirebaseToo: true)
    }
    func updateTimerData()                                                                          { timerAnzeigeModel.timerData.value = timerData }
    
    //viewModels
    func getViewModelForTimerAnzeigeView() -> TimerAnzeigeViewModel                                 { return TimerAnzeigeViewModel(model: timerAnzeigeModel)  }
    func getViewModelForKalenderMeditationTimerSettingsVC() -> TimerSettingsViewControllerModel     { return TimerSettingsViewControllerModel(timerData: timerData)  }
    
    deinit {  print("deinit EditMeditationVCViewModel") }
}
