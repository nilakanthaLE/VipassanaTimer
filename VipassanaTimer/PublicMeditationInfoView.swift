//
//  PublicMeditationInfoView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import UIKit

//✅
@IBDesignable class PublicMeditationInfoView:NibLoadingView{
    var viewModel:PublicMeditationInfoViewModel!{
        didSet{
            //in
            timerView.viewModel                     = viewModel.getViewModelForTimerView()
            publicStatisticsView.publicStatistics   = viewModel.publicStatistics
            meditationsPlatzView.viewModel          = viewModel.getViewModelForMeditationsPlatz()
            countryName.text                        = viewModel.countryName
            freundesAnfrageButton.isHidden          = viewModel.freundschaftsAnfrageButtonIsHidden
            messageLabel.text                       = viewModel.message
            messageLabel.isHidden                   = viewModel.message == nil
            flaggeView.isHidden                     = viewModel.flagge == nil
            flaggeView.setTitle(viewModel.flagge, for: .normal)
            flaggeView.reactive.controlEvents(.touchUpInside).signal.observeValues{[weak self] _ in
                self?.countryName.alpha = 1
                UIView.animate(withDuration: 3) {  self?.countryName.alpha = 0 }
            }
            
            //design
            countryName.alpha   = 0
            self.setStandardDesign()
        }
    }
    
    //IBOutlets
    @IBOutlet weak var timerView: TimerInPublicMeditationInfoView!
    @IBOutlet weak var publicStatisticsView: PublicStatisticsView!
    @IBOutlet weak var meditationsPlatzView: MeditationsPlatzView!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var freundesAnfrageButton: UIButton!
    @IBOutlet weak var flaggeView: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    //IBAction
    @IBAction func freundschaftsAnfrageButtonAction(_ sender: UIButton) { viewModel.freundSchaftsAnfrageButtonPressed()  }
}
