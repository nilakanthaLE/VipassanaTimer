//
//  HauptMenuStatistikenViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 13.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
// ViewModel für die Statistiken der Startseite
// ermöglicht durchblättern
class HauptMenuStatistikenViewModel{
    let taeglichStats       : MutableProperty<StatistikUeberblickGraphData>
    let woechentlichStats   : MutableProperty<StatistikUeberblickGraphData>
    let monatlichStats      : MutableProperty<StatistikUeberblickGraphData>
    let updateRegelmaessigkeit  = MutableProperty<Void>(Void())
    let infoButtonAction        = MutableProperty<Void>(Void())
    
    //init
    init(statistics:MutableProperty<Statistics>,infoButtonAction:MutableProperty<Void>){
        taeglichStats       =  MutableProperty<StatistikUeberblickGraphData>(statistics.value.getGraphData(takt: .taeglich))
        woechentlichStats   =  MutableProperty<StatistikUeberblickGraphData>(statistics.value.getGraphData(takt: .woechentlich))
        monatlichStats      =  MutableProperty<StatistikUeberblickGraphData>(statistics.value.getGraphData(takt: .monatlich))
        taeglichStats           <~ statistics.signal.map{$0.getGraphData(takt: .taeglich)}
        woechentlichStats       <~ statistics.signal.map{$0.getGraphData(takt: .woechentlich)}
        monatlichStats          <~ statistics.signal.map{$0.getGraphData(takt: .monatlich)}
        updateRegelmaessigkeit  <~ statistics.signal.map{_ in Void()}
        infoButtonAction        <~ self.infoButtonAction.signal
    }
    
    //ViewModels
    func getViewModelForStatistikUeberlick1View(takt:StatistikTakt) -> StatistikUeberblickBalkenViewModel{
        let property:MutableProperty<StatistikUeberblickGraphData> = {
            switch takt{
            case .taeglich:     return taeglichStats
            case .woechentlich: return woechentlichStats
            case .monatlich:    return monatlichStats
            }
        }()
        return StatistikUeberblickBalkenViewModel(data: property, infoButtonAction: infoButtonAction)
    }
    func getViewModelForStatistikUeberblick2View() -> StatistikUeberblickRegelmaessigkeitViewModel{ return StatistikUeberblickRegelmaessigkeitViewModel(update: updateRegelmaessigkeit) }
}
