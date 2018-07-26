//
//  HauptmenuButton.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 04.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
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

//✅
//BadgeButton
// zeigt FreundesAnfragen
class HauptmenuBadgeButton:NibLoadingView{
    let buttonPressed = MutableProperty<Void> (Void())
    var viewModel:HauptmenuBadgeButtonViewModel!{
        didSet{
            //in
            button.setTitle(viewModel.title, for: .normal)
            badgeLabel.reactive.text        <~ viewModel.badgeText.producer
            badgeLabel.reactive.isHidden    <~ viewModel.badgeIsHidden.producer
            
            //out
            buttonPressed <~ button.reactive.controlEvents(.touchUpInside).map{_ in Void()}
            
            //design
            self.setStandardDesign()
        }
    }

    //IBOutlets
    @IBOutlet weak var button: UIButton!
    @IBOutlet fileprivate weak var badgeLabel: CircleLabel!
    override func layoutSubviews() { badgeLabel.circle() }
}
private class CircleLabel:UILabel{
    override func layoutSubviews() { circle() }
    func circle(){
        layer.cornerRadius  = bounds.width / 2
        clipsToBounds       = true
    }
}

//HauptMenuButton
// StandardButton
//✅
@IBDesignable class HauptMenuButton:UIButton{
    @IBInspectable var hasStyle:Bool = true{
        didSet{
            backgroundColor = standardBackgroundFarbe
            self.setStandardDesign()
        }
    }
}

