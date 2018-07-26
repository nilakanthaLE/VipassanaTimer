//
//  FreundeTableViewCell.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 25.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

class FreundeTableViewCellModel{
    let labelText:String?
    let buttonText:String?
    let buttonIsHidden:Bool
    let buttonPressed = MutableProperty<Void>(Void())
    init(freund:Freund){
        labelText       = freund.freundNick
        buttonText      = NSLocalizedString("freundschaftBestaetigen", comment: "freundschaftBestaetigen")
        buttonIsHidden  = freund.meinFreundStatus == FreundStatus.granted
        buttonPressed.signal.observeValues{_ in
            FirUserConnections.setFreundschaftsstatus(withUserID: freund.freundID,
                                                      userStatus: FreundStatus.granted.rawValue,
                                                      meinStatus: FreundStatus.granted.rawValue)
        }
    }
    
}


class FreundeTableViewCell: UITableViewCell {
    var viewModel:FreundeTableViewCellModel!{
        didSet{
            label.text     = viewModel.labelText
            button.setTitle(viewModel.buttonText, for: .normal)
            button.backgroundColor  = gruen
            button.isHidden         = viewModel.buttonIsHidden
            viewModel.buttonPressed <~ button.reactive.controlEvents(UIControlEvents.touchUpInside).signal.map{_ in Void()}
        }
    }
    @IBOutlet weak var button: UIButton!  
    @IBOutlet weak var label: UILabel!
}
