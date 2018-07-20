//
//  TimerAnzeigeView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
@IBDesignable class TimerAnzeigeView:NibLoadingView{
    var viewModel:TimerAnzeigeViewModel!{
        didSet{
            anapanaWidth.reactive.constant      <~ viewModel.anapanaWidth.signal
            mettaWidth.reactive.constant        <~ viewModel.mettaWidth.signal
            verdeckAnteil.reactive.constant     <~ viewModel.ablaufWidth.signal
            zeitAnzeigeLabel.reactive.text      <~ viewModel.zeitAnzeige.producer
            anapanaDauerLabel.reactive.text     <~ viewModel.anapanaDauerTitle.producer
            vipassanaDauerLabel.reactive.text   <~ viewModel.vipassanaDauerTitle.producer
            mettaDauerLabel.reactive.text       <~ viewModel.mettaDauerTitle.producer
            timerTitleLabel.reactive.text       <~ viewModel.timerTitle.producer
            hasSoundFileLabel.reactive.isHidden <~ viewModel.hasSoundFileLabelIsHidden.producer
            
            self.setStandardDesign()
        }
    }
    
    //Outlets
    @IBOutlet weak private var anapanaView: UIView!
    @IBOutlet weak private var mettaView: UIView!
    @IBOutlet weak private var verdeckView: UIView!
    @IBOutlet weak private var vipassanaView: UIView!
    @IBOutlet weak private var anapanaDauerLabel: UILabel!
    @IBOutlet weak private var vipassanaDauerLabel: UILabel!
    @IBOutlet weak private var mettaDauerLabel: UILabel!
    @IBOutlet weak private var timerTitleLabel: UILabel!
    @IBOutlet weak private var hasSoundFileLabel: UILabel!
    @IBOutlet private weak var zeitAnzeigeLabel: UILabel!
    @IBOutlet private weak var anapanaWidth: NSLayoutConstraint!
    @IBOutlet private weak var mettaWidth: NSLayoutConstraint!
    @IBOutlet private weak var verdeckAnteil: NSLayoutConstraint!
    @IBOutlet private weak var roundetView: BothSideRoundedView!
    
    //intrinsicContentSize
    override var intrinsicContentSize: CGSize{ return CGSize(width: UIViewNoIntrinsicMetric, height: 80) }
    
    //layout Subviews
    override func layoutSubviews() { viewModel?.viewWidth.value      = roundetView.frame.width  }
    
    //Abgerundetes View für Timer Ablaufbalken
    @IBDesignable private class BothSideRoundedView:UIView{
        override func layoutSubviews() {
            layer.cornerRadius  = frame.height / 2
            clipsToBounds = true
        }
    }
    
    deinit { print("deinit TimerAnzeigeView") }
}






