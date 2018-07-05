//
//  KursConfigView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 11.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

class KursConfigViewModel{
    let startDateText               = MutableProperty<String?>(nil)
    let endDateText                 = MutableProperty<String?>(nil)
    private let kursProtos          = MutableProperty<[PublicKursProto?]>([PublicKursProto?]())
    let pickerTitles                = MutableProperty<[String?]>([String?]())
    let selectedRow                 = MutableProperty<Int>(0)
    let selectedDate                = MutableProperty<Date>(Date())
    let erstellenButtonAction       = MutableProperty<Void>(Void())
    let stacksAreHidden             = MutableProperty<Bool>(true)
    let teacher                     = MutableProperty<String?>(nil)
    init(){
        FirebaseKursProto.getList(publicKursProtos: kursProtos)
        pickerTitles            <~ kursProtos.signal.map{ $0.map {$0?.kursNameD ?? "-----"} }
        startDateText           <~ selectedDate.producer.map{$0.string("dd.MM.yyyy")}
        stacksAreHidden         <~ selectedRow.map{$0 == 0}
        endDateText             <~ selectedDate.signal.map{[weak self] _ in (self?.endDate ?? Date()).string("dd.MM.yyyy") }
        endDateText             <~ selectedRow.signal.map{[weak self] _ in (self?.endDate ?? Date()).string("dd.MM.yyyy") }
        
        
        
        erstellenButtonAction.signal.observe{[weak self] _ in
            guard let kursProto =  self?.kursProtos.value[self?.selectedRow.value ?? 0] else {return}
            let kursData = KursData(publicKursProto: kursProto, startTag: self!.selectedDate.value, teacher: self?.teacher.value )
            _ = Kurs.new(kursData: kursData)
        }
    }
    
    var endDate:Date{
        guard let kursProto =  kursProtos.value[selectedRow.value] else {return selectedDate.value}
        return selectedDate.value.addDays(kursProto.days.count - 1)
    }
}



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
            
            viewModel.pickerTitles.producer.startWithValues{print($0.map{$0})}
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
            
            
            
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {  return 1  }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int                  { return viewModel.pickerTitles.value.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?   { return viewModel.pickerTitles.value[row]}

    
    func setHiddenForStacksToHide(isHidden:Bool){ for stack in stacksToHide{ stack.isHidden = isHidden } }
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var kursPickerView: UIPickerView!
    @IBOutlet weak var erstellenButton: UIButton!
    @IBOutlet weak var teacherTextField: UITextField!
    
    @IBOutlet var stacksToHide: [UIStackView]!
}

