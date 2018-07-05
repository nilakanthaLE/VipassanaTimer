//
//  StatisticsView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 26.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift



class StatisticsViewModel{
    private let vonDate         = MutableProperty<Date>(Date())
    private let bisDate         = MutableProperty<Date>(Date())
    let vonTitle                = MutableProperty<String>("")
    let bisTitle                = MutableProperty<String>("")
    let datePickerIsHidden      = MutableProperty<Bool>(true)
    let datePickerDate          = MutableProperty<Date>(Date())
    
    init(){
        print("init StatisticsViewModel")
        vonDate.value   = Meditation.firstMeditationNotInKurs?.start ?? Date()
        bisDate.value   = Meditation.getAll().last?.start ?? Date()
        
        vonTitle            <~ vonDate.producer.map{$0.string("dd.MM.yyyy")}
        bisTitle            <~ bisDate.producer.map{$0.string("dd.MM.yyyy")}
        pickerTitles = StatisticsViewModel.graphTypen.map{$0.localizedString}
        selectedGraphTypen  <~ selectedRow.signal.map{StatisticsViewModel.graphTypen[$0]}
        datePickerIsHidden  <~ selectedGraphTypen.signal.map{_ in true}
    }
    
    
    
    
    private var selectedDateType:DateButtonType?
    fileprivate func dateButtonPressed(dateButtonType:DateButtonType){
        datePickerIsHidden.value    = selectedDateType == dateButtonType ? true : false
        selectedDateType            = selectedDateType == dateButtonType ? nil : dateButtonType
        datePickerDate.value        = selectedDateType == .von ? vonDate.value : bisDate.value
    }
    fileprivate func setDateByPicker(date:Date){
        guard let selectedDateType = selectedDateType else {return}
        switch selectedDateType{
            case .von:  vonDate.value   = date
            case .bis:  bisDate.value   = date
        }
    }
    
    //GraphTypen
    let selectedRow = MutableProperty<Int>(0)
    let pickerTitles:[NSAttributedString]
    private static var graphTypen   = [GraphTypen.GesamtdauerProWoche, GraphTypen.GesamtdauerProMonat, GraphTypen.GesamtdauerProTag]
    private let selectedGraphTypen  = MutableProperty<GraphTypen>(.GesamtdauerProWoche)
    //ViewModels
    func getViewModelForStatisticGraphView() -> StatisticGraphViewModel {
        return StatisticGraphViewModel(von: vonDate, bis: bisDate, selectedGraphTypen: selectedGraphTypen)
    }
}

@IBDesignable class StatisticsView:NibLoadingView,UIPickerViewDataSource,UIPickerViewDelegate{
    var viewModel:StatisticsViewModel!{
        didSet{
            statisticGraph.viewModel = viewModel.getViewModelForStatisticGraphView()
            vonButton.reactive.title        <~ viewModel.vonTitle.producer
            bisButton.reactive.title        <~ viewModel.bisTitle.producer
            datePicker.reactive.date        <~ viewModel.datePickerDate.producer
            datePicker.reactive.isHidden    <~ viewModel.datePickerIsHidden.producer
            
            datePicker.reactive.dates.signal.observeValues{[weak self] date in self?.viewModel.setDateByPicker(date: date)}
            viewModel.selectedRow           <~ graphTypPicker.reactive.selections.map{$0.row}
            vonButton.reactive.controlEvents(.touchUpInside).signal.observeValues{[weak self] _ in self?.viewModel.dateButtonPressed(dateButtonType: .von) }
            bisButton.reactive.controlEvents(.touchUpInside).signal.observeValues{[weak self] _ in self?.viewModel.dateButtonPressed(dateButtonType: .bis) }
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
        }
    }
    
    //IBOutlets
    @IBOutlet weak var vonButton: UIButton!
    @IBOutlet weak var bisButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var graphTypPicker: UIPickerView!
    @IBOutlet weak var statisticGraph: StatisticGraphView!
    
    //GraphTypenPicker
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return viewModel.pickerTitles.count }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label               = UILabel()
        label.font              = UIFont.systemFont(ofSize: 15.0)
        label.attributedText    = viewModel.pickerTitles[row]
        label.sizeToFit()
        return label
    }
}


fileprivate enum DateButtonType{ case von,bis }
enum GraphTypen:String{
    case GesamtdauerProWoche    = "StatistikGesamtdauerProWoche"
    case GesamtdauerProMonat    = "StatistikGesamtdauerProMonat"
    case GesamtdauerProTag      = "StatistikGesamtdauerProTag"
    
    var localizedString:NSAttributedString{
        let string              = NSLocalizedString(self.rawValue, comment: self.rawValue)
        return NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor: DesignPatterns.mocha])
    }
    var takt:StatistikTakt{
        switch self{
        case .GesamtdauerProWoche:  return .woechentlich
        case .GesamtdauerProMonat:  return .monatlich
        case .GesamtdauerProTag:    return .taeglich
        }
    }
}
