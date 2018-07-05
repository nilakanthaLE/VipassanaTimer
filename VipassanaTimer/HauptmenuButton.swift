//
//  HauptmenuButton.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 04.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

class HauptmenuBadgeButtonViewModel{
    let title:String
    let badgeIsHidden   = MutableProperty<Bool>(true)
    let badgeText       = MutableProperty<String>("0")
    init(title:String,badgeCount:MutableProperty<Int>) {
        self.title = title
        badgeIsHidden   <~ badgeCount.producer.map{$0 <= 0}
        badgeText       <~ badgeCount.producer.map{"\($0)"}
    }
}

class HauptmenuBadgeButton:NibLoadingView{
    var viewModel:HauptmenuBadgeButtonViewModel!{
        didSet{
            button.setTitle(viewModel.title, for: .normal)
            badgeLabel.reactive.text        <~ viewModel.badgeText.producer
            badgeLabel.reactive.isHidden    <~ viewModel.badgeIsHidden.producer
            buttonPressed <~ button.reactive.controlEvents(.touchUpInside).map{_ in Void()}
            
            
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
        }
    }

    @IBOutlet weak var button: UIButton!{
        didSet{
            button.setTitleColor(standardSchriftFarbe, for: .normal)
        }
    }
    @IBOutlet weak var badgeLabel: CircleLabel!{ didSet{ badgeLabel.backgroundColor      = .red }  }
    let buttonPressed = MutableProperty<Void> (Void())
}
class CircleLabel:UILabel{
    override func layoutSubviews() {
        layer.cornerRadius  = bounds.width / 2
        clipsToBounds = true
    }
}


@IBDesignable class HauptMenuButton:UIButton{
    @IBInspectable var hasStyle:Bool = true{
        didSet{
            backgroundColor = standardBackgroundFarbe
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds       = true
        }
    }
    
    //    let badgeCount = MutableProperty<Int>(0)
    //    private var badgeLabel:UILabel?
    //    @IBInspectable var hasBadge:Bool = false{
    //        didSet{
    //            guard hasBadge else {return}
    //            createBadgeLabel()
    //            badgeCount.producer.startWithValues{[weak self] count in self?.setBadge(badgeCount: count)}
    //        }
    //    }
    //    private func setBadge(badgeCount:Int){
    //        badgeLabel?.isHidden    = badgeCount <= 0
    //        badgeLabel?.text        = "\(badgeCount)"
    //    }
    //
    //    private func createBadgeLabel(){
    //        badgeLabel                      = badgeLabel ?? UILabel()
    //        addSubview(badgeLabel!)
    //        setBadgeLabelFrame()
    //    }
    //
    //    override func layoutSubviews() {
    ////        setBadgeLabelFrame()
    //    }
    //    private func setBadgeLabelFrame(){
    //        let rand:CGFloat = 1
    //        badgeLabel?.frame.size.height   = bounds.height / 3
    //        badgeLabel?.frame.size.width    = bounds.height / 3
    //        badgeLabel?.frame.origin.x      = bounds.width - bounds.height / 3 - rand
    //        badgeLabel?.frame.origin.y      = rand
    //        badgeLabel?.layer.cornerRadius  = (badgeLabel?.frame.width ?? 0 ) / 2
    //        badgeLabel?.clipsToBounds       = true
    //    }
}
