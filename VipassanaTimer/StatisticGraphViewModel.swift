//
//  StatisticGraphViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 13.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
// ViewModel für den Graphen in der Statistikansicht
class StatisticGraphViewModel{
    private let vonDate             = MutableProperty<Date>(Date())
    private let bisDate             = MutableProperty<Date>(Date())
    private let selectedGraphTypen  = MutableProperty<GraphTypen>(.GesamtdauerProWoche)
    let redraw                      = MutableProperty<Void>(Void())
    let values                      = MutableProperty<[GraphValue]>([GraphValue]())
    
    var maxY:Double{ return values.value.map{$0.value}.max() ?? 0 }
    
    //init
    init(von:MutableProperty<Date>,bis:MutableProperty<Date>,selectedGraphTypen:MutableProperty<GraphTypen>){
        self.selectedGraphTypen <~ selectedGraphTypen.producer
        vonDate                 <~ von.producer
        bisDate                 <~ bis.producer
        
        values                  <~ selectedGraphTypen.producer.map{[weak self] _ in self?.getGraphValues() ?? [GraphValue]()}
        values                  <~ vonDate.producer.map{[weak self] _ in self?.getGraphValues() ?? [GraphValue]()}
        values                  <~ bisDate.producer.map{[weak self] _ in self?.getGraphValues() ?? [GraphValue]()}

        redraw                  <~ values.map{_ in Void()}
    }
    
    //helper
    private func getGraphValues() -> [GraphValue] { return Meditation.getGraphValuesFor(graphTyp: selectedGraphTypen.value, von: vonDate.value, bis: bisDate.value)}
}
