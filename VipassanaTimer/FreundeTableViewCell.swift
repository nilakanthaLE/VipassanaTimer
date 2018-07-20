//
//  FreundeTableViewCell.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
class FreundeTableViewCellModel{
    let confirmButtonPressed    = MutableProperty<Void>(Void())
    let nickName:String?
    let hasButton:Bool
    let freund:Freund
    init(freund:Freund){
        self.freund = freund
        nickName    = freund.freundNick
        hasButton   = freund.status != FreundStatus.granted
        confirmButtonPressed.signal.observeValues { [weak self] _ in  self?.confirmButtonPressedAction() }
    }
    
    
    private func confirmButtonPressedAction(){
        FirUserConnections.setFreundschaftsstatus(withUserID: freund.freundID,
                                                  userStatus: FreundStatus.granted.rawValue,
                                                  meinStatus: FreundStatus.granted.rawValue)
    }
}

//✅
class FreundeTableViewCell:UITableViewCell{
    var viewModel:FreundeTableViewCellModel!{
        didSet{
            textLabel?.textColor    = standardSchriftFarbe
            backgroundColor         = standardBackgroundFarbe
            textLabel?.text         = viewModel.nickName
            accessoryView           = viewModel.hasButton ? getButton() : nil
        }
    }
    
    //helper
    func getButton() -> UIButton{
        let button              = UIButton()
        button.backgroundColor  = gruen
        button.setTitle(" bestätigen ", for: .normal)
        viewModel.confirmButtonPressed <~ button.reactive.controlEvents(.touchUpInside).map { _ in Void()}
        button.sizeToFit()
        return button
    }
}

