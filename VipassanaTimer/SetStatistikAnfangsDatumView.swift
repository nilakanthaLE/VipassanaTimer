//
//  SetStatistikAnfangsDatumView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
//Setzen des Anfangsdatums für Statistiken
// Korrektur, falls Kurse nachgetragen wurden
class SetStatistikAnfangsDatumView:NibLoadingView{
    var viewModel:SetStatistikAnfangsDatumViewModel!{
        didSet{
            //in
            datumLabel.reactive.text                <~ viewModel.datumText.producer
            datePicker.reactive.date                <~ viewModel.datumPickerDate.producer
            zuruecksetzenButton.reactive.isHidden   <~ viewModel.zurueckSetzenButtonIsHidden.producer
            //out
            viewModel.zuruckSetzenButtonPressed     <~ zuruecksetzenButton.reactive.controlEvents(.touchUpInside).map{ _ in Void() }
            viewModel.datumPickerDate               <~ datePicker.reactive.dates.signal
            //design
            self.setStandardDesign()
            datePicker.setValue(standardSchriftFarbe, forKey: "textColor")
        }
    }
    //IBOutlets
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var datumLabel: UILabel!
    @IBOutlet weak var zuruecksetzenButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
}
