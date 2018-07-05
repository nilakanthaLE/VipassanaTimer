//
//  KursErstellenVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 30.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class KursErstellenVC: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {
    let kursTemplates = KursTemplate.getAll()
    
    var selectedKursTemplate:KursTemplate?
    var startDate:Date?{
        didSet{
            erstellenButton.isHidden    = false
            startDateLabel.text         = startDate?.string("dd.MM.yyyy")
            //setzt Ende Datum Label
            let sortedMeditations       = selectedKursTemplate?.sortedMeditations
            guard let last = sortedMeditations?.last?.start, let first = sortedMeditations?.first?.start?.firstSecondOfDay else {return}
            let endeDate                = startDate?.addingTimeInterval(last.timeIntervalSince(first as Date))
            endeDateLabel.text          = endeDate?.string("dd.MM.yyyy")
        }
    }
    
    @IBOutlet weak var overlayView: UIView!{
        didSet{
            overlayView.setControlDesignPatterns()
        }
    }
    
    @IBOutlet weak var ueberschriftLabel: UILabel!
    @IBOutlet weak var erstellenButton: UIButton!{ didSet{ erstellenButton.isHidden = true } }
    @IBOutlet weak var kursTemplatePicker: UIPickerView!
    @IBOutlet weak var startDatePicker: UIDatePicker!{
        didSet{
            startDatePicker.isHidden = true
        }
        
    }
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endeDateLabel: UILabel!
    @IBOutlet weak var vonDatumStack: UIStackView!{
        didSet{
            vonDatumStack.isHidden = true
        }
    }
    @IBOutlet weak var bisDatumStack: UIStackView!{
        didSet{
            bisDatumStack.isHidden = true
        }
    }
    
    
    @IBAction func erstellenButtonPressed(_ sender: UIButton) {
        guard let startDate = startDate, let selectedKursTemplate = selectedKursTemplate else {  return }
        _ = Kurs.new(template: selectedKursTemplate, start: startDate)
        _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK: PickerView DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return kursTemplates.count + 1
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = row == 0 ? "--------" : kursTemplates[row - 1].name ?? "Fehler - Name fehlt"
        let attributedString = NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor : DesignPatterns.mocha])
        return attributedString
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0{
            selectedKursTemplate        = kursTemplates[row - 1]
            startDatePicker.isHidden    = false
            vonDatumStack.isHidden      = false
            bisDatumStack.isHidden      = false
            startDate                   = Date()
        }else{
            selectedKursTemplate        = nil
            startDatePicker.isHidden    = true
            vonDatumStack.isHidden      = true
            bisDatumStack.isHidden      = true
        }
        
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        startDate = sender.date
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        kursTemplatePicker.setValue(DesignPatterns.mocha, forKey: "textColor")
        startDatePicker.setValue(DesignPatterns.mocha, forKey: "textColor")
        view.backgroundColor = DesignPatterns.mainBackground
    }
    deinit {
        print("deinit KursErstellenVC")
    }
}
