//
//  TimerTableVCModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
class TimerTableVCModel{
    private let model:MeineTimerModel
    let updateTable = MutableProperty<Void>(Void())
    init(model:MeineTimerModel){
        self.model          = model
        updateTable         <~ model.timerDatas.signal.map{_ in Void()}
    }
    
    //TableView DataSource
    var numberOfRows:Int  {return  model.timerDatas.value.count }
    
    //TableView Delegate Actions
    func selectMeditationsTimer(indexPath:IndexPath){ model.gewaehlterTimerFuerMeditation.value   = model.timerDatas.value[indexPath.row] }
    func deleteTimer(at row:Int){ model.removeTimerData(at: row) }
    
    //ViewModels
    func getViewModelForCell(indexPath:IndexPath) -> TimerAnzeigeViewModel{ return TimerAnzeigeViewModel(model: TimerAnzeigeModel(timerData: model.timerDatas.value[indexPath.row])) }
    func getTimerSettingsViewControllerModel(row:Int?) -> TimerSettingsViewControllerModel{
        let timerData:TimerData = {
            guard let row = row else {return model.addTimerData()}
            return model.timerDatas.value[row]
        }()
        return TimerSettingsViewControllerModel(timerData: timerData)
    }
    
    deinit { print("deinit TimerTableVCModel")  }
}
