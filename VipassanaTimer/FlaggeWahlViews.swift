//
//  FlaggeWahlView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift


class FlaggeWahlVC:UIViewController{
    var viewModel:FlaggeWahlVCViewModel!
    @IBOutlet weak var flaggWahlView: FlaggeWahlView!{didSet{ flaggWahlView.viewModel =  viewModel.getViewModelForFlaggeWahlView()}}
    @IBAction func doneButtonAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor            = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        navigationController?.navigationBar.setDesignPattern()
    }
}

class FlaggeWahlView:NibLoadingView,UIPickerViewDataSource,UIPickerViewDelegate{
    var viewModel:FlaggeWahlViewModel!{
        didSet{
            picker.reactive.selectedRow(inComponent: 0) <~ viewModel.suchRow
            viewModel.suchString                        <~ suchFeld.reactive.continuousTextValues
            viewModel.userSelection                     <~ picker.reactive.selections.map{$0.row}
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
        }
    }
    
    //PickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return viewModel.pickerValues.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{ return viewModel.pickerValues[row] }
    
    //IBOutlets
    @IBOutlet weak var suchFeld: UITextField!
    @IBOutlet weak var picker: UIPickerView!
}









