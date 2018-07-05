//
//  ProfilConfigView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 04.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift



@IBDesignable class ProfilConfigView:NibLoadingView{
    var viewModel:ProfilConfigViewModel!{
        didSet{
            spitzNameTextFeld.reactive.text             <~ viewModel.spitzNameText.producer
            flaggeButton.reactive.title                 <~ viewModel.flaggeButtonTitle.producer
            spitznameSichtbarSwitch.reactive.isOn       <~ viewModel.spitznameIstSichtbar.producer
            flaggeSichtbarSwitch.reactive.isOn          <~ viewModel.flaggeIstSichtbar.producer
            statisticsSichtbarSwitch.reactive.isOn      <~ viewModel.statistikIstSichtbar.producer
            nickNamePruefenButton.reactive.isEnabled    <~ spitzNameTextFeld.reactive.continuousTextValues.map{$0 != nil && !$0!.isEmpty }
            spitznameIstVergebenLabel.reactive.text     <~ viewModel.spitzNameVergebenLabelText.producer
            messageTextField.reactive.text              <~ viewModel.message.producer
            
            sitzplatzView.viewModel = viewModel.getViewModelForSitzPlatzView()
            
            
            viewModel.model.spitznameIstSichtbar    <~ spitznameSichtbarSwitch.reactive.isOnValues
            viewModel.model.flaggeIstSichtbar       <~ flaggeSichtbarSwitch.reactive.isOnValues
            viewModel.model.statistikIstSichtbar    <~ statisticsSichtbarSwitch.reactive.isOnValues
            viewModel.flaggeButtonPressed           <~ flaggeButton.reactive.controlEvents(UIControlEvents.touchUpInside).map{_ in Void()}
            viewModel.model.spitzName               <~ nickNamePruefenButton.reactive.controlEvents(UIControlEvents.touchUpInside).map{[weak self] _ in self?.spitzNameTextFeld.text }
            viewModel.model.message                 <~ messageTextField.reactive.continuousTextValues
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
        }
        
    }
    
    @IBAction func sitzPlatzTapped(_ sender: UITapGestureRecognizer) { viewModel.meditationsPlatzTapped.value  = Void() }
    @IBOutlet weak var spitzNameTextFeld: UITextField!
    @IBOutlet weak var spitznameIstVergebenLabel: UILabel!
    @IBOutlet weak var flaggeButton: UIButton!
    @IBOutlet weak var sitzplatzView: MeditationsPlatzView!
    @IBOutlet weak var spitznameSichtbarSwitch: UISwitch!
    @IBOutlet weak var flaggeSichtbarSwitch: UISwitch!
    @IBOutlet weak var statisticsSichtbarSwitch: UISwitch!
    @IBOutlet weak var nickNamePruefenButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    
}
