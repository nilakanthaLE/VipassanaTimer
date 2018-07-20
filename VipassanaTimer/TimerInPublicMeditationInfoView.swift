//
//  TimerInPublicMeditationInfoView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
@IBDesignable class TimerInPublicMeditationInfoView:NibLoadingView{
    var viewModel:TimerInPublicMeditationInfoViewModel!{ didSet{ timerAnzeigeView.viewModel  = viewModel } }
    
    //IBOutlets
    @IBOutlet weak var timerAnzeigeView: TimerAnzeigeView!
    
    override var intrinsicContentSize: CGSize{ return CGSize(width: UIViewNoIntrinsicMetric, height: 80) }
    deinit { print("deinit TimerInPublicMeditationInfoView") }
}
