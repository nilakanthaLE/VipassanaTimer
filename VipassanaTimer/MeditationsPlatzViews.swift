//
//  MeditationsPlatzView.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 08.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
@IBDesignable class MeditationsPlatzView: NibLoadingView {
    var viewModel:MeditationsPlatzViewModel!{
        didSet{
            userNameLabel.reactive.text <~ viewModel.meditationsPlatzTitle.producer
            viewModel.meditationsPlatzTitle.signal.observeValues{[weak self] _ in self?.setFontSize()}
            viewModel.mettaEffektHasStarted.producer.filter{$0 == true}.startWithValues(){  [weak self] _ in self?.mettaEffektHasStarted() }
        }
    }
    
    //IBOutlets
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var backGroundView: UIView!{ didSet{ backGroundView.setStandardDesign()} }
    
    //layoutSubviews
    var currentLabelSize:CGSize = CGSize.zero
    override func layoutSubviews() {
        if currentLabelSize != userNameLabel.frame.size{ setFontSize() }
        currentLabelSize = userNameLabel.frame.size
    }
    
    //Metta Effekt Animation
    private func mettaEffektHasStarted(){
        self.view.layer.add(pulseAnimation(keyPath: "transform.scale.x"), forKey: nil)
        self.view.layer.add(pulseAnimation(keyPath: "transform.scale.y"), forKey: nil)
    }
    
    //helper
    private func setFontSize(){
        guard let text      = userNameLabel.text, !text.isEmpty else {return}
        let fontSize        = userNameLabel.font.getFontSize(for: userNameLabel.text, in: userNameLabel.frame)
        userNameLabel.font  = UIFont(name: userNameLabel.font.fontName, size: fontSize )
    }
    private func pulseAnimation(keyPath:String) -> CABasicAnimation{
        let pulseAnimation =  CABasicAnimation(keyPath: keyPath)
        pulseAnimation.duration     = 3
        pulseAnimation.fromValue    = 0.8
        pulseAnimation.toValue      = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = Float.greatestFiniteMagnitude
        return pulseAnimation
    }
    
    deinit { print("deinit MeditationsPlatzView") }
}

//✅
@IBDesignable class MeditationsPlatzCell: UICollectionViewCell {
    @IBOutlet weak var meditationsPlatzView: MeditationsPlatzView!
    deinit {  print("deinit MeditationsPlatzCell") }
}



