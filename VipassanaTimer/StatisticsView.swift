//
//  StatisticsView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 26.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
@IBDesignable class StatisticsView:NibLoadingView,UIPickerViewDataSource,UIPickerViewDelegate{
    var viewModel:StatisticsViewModel!{
        didSet{
            //in
            vonButton.reactive.title        <~ viewModel.vonTitle.producer
            bisButton.reactive.title        <~ viewModel.bisTitle.producer
            datePicker.reactive.date        <~ viewModel.datePickerDate.producer
            datePicker.reactive.isHidden    <~ viewModel.datePickerIsHidden.producer
        
            //out
            viewModel.pickerDateSet         <~ datePicker.reactive.dates.signal
            viewModel.selectedRow           <~ graphTypPicker.reactive.selections.map{$0.row}
            viewModel.dateButtonPressed     <~ vonButton.reactive.controlEvents(.touchUpInside).signal.map{_ in .von}
            viewModel.dateButtonPressed     <~ bisButton.reactive.controlEvents(.touchUpInside).signal.map{_ in .bis}
            
            //design
            self.setStandardDesign()
            
            //viewModel
            statisticGraph.viewModel = viewModel.getViewModelForStatisticGraphView()
        }
    }
    
    //IBOutlets
    @IBOutlet weak var vonButton: UIButton!
    @IBOutlet weak var bisButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var graphTypPicker: UIPickerView!
    @IBOutlet weak var statisticGraph: StatisticGraphView!
    
    //GraphTypenPicker
    func numberOfComponents(in pickerView: UIPickerView) -> Int                                                                     { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int                                      { return viewModel.pickerTitles.count }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView  { return getLabel(text: viewModel.pickerTitles[row]) }
    
    //helper
    private func getLabel(text:NSAttributedString) -> UILabel{
        let label               = UILabel()
        label.font              = UIFont.systemFont(ofSize: 15.0)
        label.attributedText    = text
        label.sizeToFit()
        return label
    }
}



//MARK: enums
enum DateButtonType{ case von,bis }
enum GraphTypen:String{
    case GesamtdauerProWoche    = "StatistikGesamtdauerProWoche"
    case GesamtdauerProMonat    = "StatistikGesamtdauerProMonat"
    case GesamtdauerProTag      = "StatistikGesamtdauerProTag"
    var localizedString:NSAttributedString{
        let string              = NSLocalizedString(self.rawValue, comment: self.rawValue)
        return NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor: standardSchriftFarbe])
    }
    var takt:StatistikTakt{
        switch self{
        case .GesamtdauerProWoche:  return .woechentlich
        case .GesamtdauerProMonat:  return .monatlich
        case .GesamtdauerProTag:    return .taeglich
        }
    }
}
