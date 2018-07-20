//
//  StatistikUeberblickGraphViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 13.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
//ViewModel für BalkenGraph (Startseite)
class StatistikUeberblickGraphViewModel{
    //texte unter Balken für täglich, wöchentlich, monatlich
    //(z.B. vorgestern,gestern,heute)
    let aktuellLabelText            = MutableProperty<String?>(nil)
    let letzterLabelText            = MutableProperty<String?>(nil)
    let vorletzterLabelText         = MutableProperty<String?>(nil)
    
    //Werte an Balken
    let aktuellValueLabelText       = MutableProperty<String?>(nil)
    let letzterValueLabelText       = MutableProperty<String?>(nil)
    let vorletzterValueLabelText    = MutableProperty<String?>(nil)
    let durchschnittValueLabelText  = MutableProperty<String?>(nil)
    
    //Balken Werte
    let maxValue            = MutableProperty<Double>(0)
    let maxGraphValue       = MutableProperty<Double>(0)
    let aktuellHeight       = MutableProperty<CGFloat>(0)
    let letzterHeight       = MutableProperty<CGFloat>(0)
    let vorletzterHeight    = MutableProperty<CGFloat>(0)
    let durchSchnittHeight  = MutableProperty<CGFloat>(0)
    
    //wird von View gesetzt
    let viewHeight          = MutableProperty<CGFloat>(0)
    
    //init
    let data:MutableProperty<StatistikUeberblickGraphData>
    init(data:MutableProperty<StatistikUeberblickGraphData>){
        self.data   = MutableProperty<StatistikUeberblickGraphData>(data.value)
        self.data   <~ data.signal
        
        aktuellLabelText    <~ data.producer.map{$0.takt.aktuellString}
        letzterLabelText    <~ data.producer.map{$0.takt.letzterString}
        vorletzterLabelText <~ data.producer.map{$0.takt.vorletzterString}
        
        aktuellValueLabelText       <~ data.producer.map{($0.aktuell * 3600).hhmm}
        letzterValueLabelText       <~ data.producer.map{($0.letzter * 3600).hhmm}
        vorletzterValueLabelText    <~ data.producer.map{($0.vorletzter * 3600).hhmm}
        durchschnittValueLabelText  <~ data.producer.map{($0.durchSchnitt * 3600).hhmm}
        
        maxValue            <~ data.producer.map{$0.maxValue}
        maxGraphValue       <~ data.producer.map{StatistikUeberblickGraphViewModel.getMaxGraphValue(max: $0.maxValue)}
        
        aktuellHeight       <~ data.producer.map{[weak self] data in self?.getHeight(zeitRaum: .aktuell) ?? 0 }
        letzterHeight       <~ data.producer.map{[weak self] data in self?.getHeight(zeitRaum: .letzter) ?? 0 }
        vorletzterHeight    <~ data.producer.map{[weak self] data in self?.getHeight(zeitRaum: .vorletzter) ?? 0 }
        durchSchnittHeight  <~ data.producer.map{[weak self] data in self?.getHeight(zeitRaum: .durchSchnitt) ?? 0 }
        
        aktuellHeight       <~ viewHeight.signal.map{[weak self] data in self?.getHeight(zeitRaum: .aktuell) ?? 0 }
        letzterHeight       <~ viewHeight.signal.map{[weak self] data in self?.getHeight(zeitRaum: .letzter) ?? 0 }
        vorletzterHeight    <~ viewHeight.signal.map{[weak self] data in self?.getHeight(zeitRaum: .vorletzter) ?? 0 }
        durchSchnittHeight  <~ viewHeight.signal.map{[weak self] data in self?.getHeight(zeitRaum: .durchSchnitt) ?? 0 }
    }
    
    //helper
    private func getHeight(zeitRaum:StatistikZeitraum) -> CGFloat{
        guard viewHeight.value > 0 else {return 0}
        let max     = maxGraphValue.value
        let value   = data.value.get(for: zeitRaum)
        guard max > 0 else {return 0}
        return CGFloat(value / max) * viewHeight.value
    }
    static private func getMaxGraphValue(max:Double) -> Double{ return Double(GraphBackGroundViewModel.anzahlInStack(maxValue: max)) * GraphBackGroundViewModel.steps(maxValue: max) }
    
    //ViewModels
    func getViewModelForBackGroundView() -> GraphBackGroundViewModel{ return GraphBackGroundViewModel(maxValue: maxValue) }
}
