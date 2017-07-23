//
//  StatistikVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 31.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

enum GraphTypen:String{
    case GesamtdauerProWoche    = "StatistikGesamtdauerProWoche"
    case GesamtdauerProMonat    = "StatistikGesamtdauerProMonat"
    case GesamtdauerProTag      = "StatistikGesamtdauerProTag"
}

class StatistikVC: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate {

    private var vonDatum:Date?
    private var bisDatum:Date?
    private var selectedGraphenTyp:GraphTypen? = .GesamtdauerProTag
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignPatterns.mainBackground
        navigationController?.navigationBar.setDesignPattern()
    }
    
    @IBOutlet weak var statistikView: StatistikView!
    @IBOutlet weak var overlayView: UIView!{
        didSet {
            overlayView.setControlDesignPatterns()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datePicker.setValue(DesignPatterns.mocha, forKey: "textColor")
    }
    override func viewDidAppear(_ animated: Bool) {
        statistikView.primaereTeiler        = [3600,1800,900,600]
        statistikView.farben                = [UIColor.orange,UIColor.green]
        statistikView.achsenBeschriftung    = (xAchse:"Wochen",yAchse:"h")
        statistikView.yAchseLabelsText      = {(wert:Double) in return wert.hhmmString}
        drawGraph()
    }
    @IBOutlet weak var constraintHeightDatePicker: NSLayoutConstraint!{
        didSet{
            constraintHeightDatePicker.constant = 0.0
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15.0)
        let string              = NSLocalizedString(typen[row].rawValue, comment: typen[row].rawValue)
        let attributedString    = NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor : DesignPatterns.mocha])
        label.attributedText = attributedString
        label.sizeToFit()
        return label
    }
    @IBOutlet weak var graphTypPicker: UIPickerView!{
        didSet{
            graphTypPicker.selectRow(2, inComponent: 0, animated: true)
        }
    }
    @IBOutlet weak var vonButton: UIButton!{
        didSet{
            standardButtonBlau = vonButton.tintColor
            vonButton.setTitle(Date().startOfMonth.string("dd.MM.yyyy"), for: .normal)
            vonDatum = Date().startOfMonth
        }
    }
    @IBOutlet weak var bisButton: UIButton!{
        didSet{
            bisButton.setTitle(Date().string("dd.MM.yyyy"), for: .normal)
            bisDatum = Date()
        }
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var standardButtonBlau:UIColor!
    @IBAction func vonButtonPressed(_ sender: UIButton) {
        datePicker.setDate(vonDatum ?? Date(), animated: false)
        let andererButtonIsOn = bisButton.tintColor == UIColor.red
        vonButton.tintColor = constraintHeightDatePicker.constant == 0 ? UIColor.red : andererButtonIsOn ? UIColor.red : standardButtonBlau
        constraintHeightDatePicker.constant = constraintHeightDatePicker.constant == 0 ? 100 : andererButtonIsOn ? 100 :0
        bisButton.tintColor = standardButtonBlau
    }
    @IBAction func bisButtonPressed(_ sender: UIButton) {
        datePicker.setDate(bisDatum ?? Date(), animated: false)
        let andererButtonIsOn = vonButton.tintColor == UIColor.red
        bisButton.tintColor = constraintHeightDatePicker.constant == 0 ? UIColor.red : andererButtonIsOn ? UIColor.red : standardButtonBlau
        constraintHeightDatePicker.constant = constraintHeightDatePicker.constant == 0 ? 100 : andererButtonIsOn ? 100 :0
        vonButton.tintColor = standardButtonBlau
    }
    @IBAction func datePickerDidChanged(_ sender: UIDatePicker) {
        let title = sender.date.string("dd.MM.yyyy")
        if vonButton.tintColor == UIColor.red{
            vonButton.setTitle(title, for: .normal)
            vonDatum = sender.date
        }else if bisButton.tintColor == UIColor.red{
            bisButton.setTitle(title, for: .normal)
            bisDatum = sender.date
        }
        drawGraph()
    }
    
    let typen = [GraphTypen.GesamtdauerProWoche,GraphTypen.GesamtdauerProMonat,GraphTypen.GesamtdauerProTag]
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typen.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGraphenTyp = typen[row]
        drawGraph()
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string              = NSLocalizedString(typen[row].rawValue, comment: typen[row].rawValue)
        let attributedString    = NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor : DesignPatterns.mocha])
        return attributedString
    }
    
    private func drawGraph(){
        guard let start             = vonDatum, let ende = bisDatum, let selectedGraphenTyp = selectedGraphenTyp else {return}
        let value                   = Meditation.getValuesFor(graphTyp: selectedGraphenTyp, von: start, bis: ende)
        statistikView.werte         = [value.werte]
        statistikView.xAchsenLabel  = value.xAchsenBeschriftung
    }
    


}
