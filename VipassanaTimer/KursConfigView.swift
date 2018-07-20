//
//  KursConfigView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 11.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
@IBDesignable class KursConfigView:NibLoadingView,UIPickerViewDataSource,UIPickerViewDelegate{
    var viewModel:KursConfigViewModel!{
        didSet{
            kursPickerView.reactive.reloadAllComponents <~ viewModel.pickerTitles.producer.map{_ in Void()}
            startDateLabel.reactive.text                <~ viewModel.startDateText.producer
            endDateLabel.reactive.text                  <~ viewModel.endDateText.producer
            viewModel.stacksAreHidden.producer.startWithValues{[weak self] isHidden in self?.setHiddenForStacksToHide(isHidden: isHidden)}
            
            viewModel.selectedRow           <~ kursPickerView.reactive.selections.map{$0.row}
            viewModel.selectedDate          <~ startDatePicker.reactive.dates
            viewModel.erstellenButtonAction <~ erstellenButton.reactive.controlEvents(UIControlEvents.touchUpInside).map{_ in Void()}
            viewModel.teacher               <~ teacherTextField.reactive.textValues
            
            self.setStandardDesign()
        }
    }
    //Picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int                                                 { return 1  }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int                  { return viewModel.pickerTitles.value.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?   { return viewModel.pickerTitles.value[row]}

    //IBOutlets
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var kursPickerView: UIPickerView!
    @IBOutlet weak var erstellenButton: UIButton!
    @IBOutlet weak var teacherTextField: UITextField!
    
    //helper
    @IBOutlet var stacksToHide: [UIStackView]!
    func setHiddenForStacksToHide(isHidden:Bool){ for stack in stacksToHide{ stack.isHidden = isHidden } }
}

