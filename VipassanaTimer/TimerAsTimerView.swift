//
//  TimerAsTimerView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
@IBDesignable class TimerAsTimerView:NibLoadingView{
    var viewModel:TimerAsTimerViewModel!{
        didSet{
            timerAnzeige.viewModel = viewModel
            
            beendenButton.reactive.isHidden <~ viewModel.beendenButtonIsHidden.producer
            startenButton.reactive.title    <~ viewModel.startButtonTitle.producer
            viewModel.beendenButtonPressed  <~ beendenButton.reactive.controlEvents(.touchUpInside).signal.map{_ in ()}
            viewModel.startButtonPressed    <~ startenButton.reactive.controlEvents(.touchUpInside).signal.map{_ in ()}

            //Timeranzeige in TimerAsTimer ohne Border und Hintergrund
            self.setStandardDesign()
            timerAnzeige.view.backgroundColor   = .clear
            timerAnzeige.backgroundColor        = .clear
            timerAnzeige.layer.borderWidth      = 0
        }
    }
    
    //IBOutlets
    @IBOutlet private weak var timerAnzeige: TimerAnzeigeView!
    @IBOutlet private weak var beendenButton: UIButton!
    @IBOutlet private weak var startenButton: UIButton!
    
    //IBActions
    @IBAction func timerAnzeigeTapped(_ sender: Any) { timerAnzeigeTapped?() }
    
    //Closure
    var timerAnzeigeTapped:(()->Void)?
    
    override var intrinsicContentSize: CGSize{ return CGSize(width: UIViewNoIntrinsicMetric, height: 100) }
    
    deinit {  print("deinit TimerAsTimerView") }
}
