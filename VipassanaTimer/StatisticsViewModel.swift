//
//  StatisticsViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 13.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
// ViewModel für die Statistik Ansicht
// wahl des Typen (Gesamtdauer - tag,woche,monat)
// und angezeigter Zeitraum
class StatisticsViewModel{
    let vonTitle                    = MutableProperty<String>("")
    let bisTitle                    = MutableProperty<String>("")
    let datePickerIsHidden          = MutableProperty<Bool>(true)
    let datePickerDate              = MutableProperty<Date>(Date())
    
    let pickerDateSet               = MutableProperty<Date>(Date())
    let dateButtonPressed           = MutableProperty<DateButtonType>(.von)
    
    //selectedRow wird von view gesetzt -> setzt selGraphTyp
    let selectedRow                 = MutableProperty<Int>(0)
 
    //init
    private static var graphTypen   = [GraphTypen.GesamtdauerProWoche, GraphTypen.GesamtdauerProMonat, GraphTypen.GesamtdauerProTag]
     let pickerTitles:[NSAttributedString]
    init(){
        vonDate.value   = Meditation.firstMeditationNotInKurs?.start ?? Date()
        bisDate.value   = Meditation.getAll().last?.start ?? Date()
        pickerTitles    = StatisticsViewModel.graphTypen.map{$0.localizedString}
        
        vonTitle            <~ vonDate.producer.map{$0.string("dd.MM.yyyy")}
        bisTitle            <~ bisDate.producer.map{$0.string("dd.MM.yyyy")}
        
        selectedGraphTypen  <~ selectedRow.signal.map{StatisticsViewModel.graphTypen[$0]}
        datePickerIsHidden  <~ selectedGraphTypen.signal.map{_ in true}
        
        
        dateButtonPressed.signal.observeValues  { [weak self] typ in self?.dateButtonPressed(dateButtonType: typ) }
        pickerDateSet.signal.observeValues      { [weak self] date in self?.setDateByPicker(date: date) }
    }
    
    //helper - viewActions
    private var selectedDateType:DateButtonType?
    private func dateButtonPressed(dateButtonType:DateButtonType){
        datePickerIsHidden.value    = selectedDateType == dateButtonType ? true : false
        selectedDateType            = selectedDateType == dateButtonType ? nil : dateButtonType
        datePickerDate.value        = selectedDateType == .von ? vonDate.value : bisDate.value
    }
    private func setDateByPicker(date:Date){
        guard let selectedDateType = selectedDateType else {return}
        switch selectedDateType{
        case .von:  vonDate.value   = date
        case .bis:  bisDate.value   = date
        }
    }
    
    //ViewModels
    private let vonDate             = MutableProperty<Date>(Date())
    private let bisDate             = MutableProperty<Date>(Date())
    private let selectedGraphTypen  = MutableProperty<GraphTypen>(.GesamtdauerProWoche)
    func getViewModelForStatisticGraphView() -> StatisticGraphViewModel { return StatisticGraphViewModel(von: vonDate, bis: bisDate, selectedGraphTypen: selectedGraphTypen) }
}
