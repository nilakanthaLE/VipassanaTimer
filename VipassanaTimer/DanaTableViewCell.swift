//
//  DanaTableViewCell.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 25.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift
import StoreKit



class DanaTableViewCellModel{
    let buttonAction    = MutableProperty<Void>(Void())
    let labelText       = MutableProperty<String?>(nil)
    init(product:SKProduct){
        labelText.value = getPrice(for: product)
        buttonAction.signal.observeValues { DanaProducts.store.buyProduct(product) }
    }
    
    //helper
    private func getPrice(for product:SKProduct) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale      = product.priceLocale
        return numberFormatter.string(from: product.price) ?? ""
    }
}

class DanaTableViewCell: UITableViewCell {
    var viewModel:DanaTableViewCellModel!{
        didSet{
            viewModel.buttonAction  <~ button.reactive.controlEvents(.touchUpInside).signal.map{_ in Void()}
            label.reactive.text     <~ viewModel.labelText.producer
            designBackgroundView.setStandardDesign()
        }
    }
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var designBackgroundView: UIView!
}



class DanaEinzelFreischaltCellModel {
    let schalterAction  = MutableProperty<Void>(Void())
    let labelText       = MutableProperty<String?>(nil)
    let reloadTable     = MutableProperty<Void>(Void())
    init(){
        labelText.value = NSLocalizedString("danaEinzelErlaubnisCell", comment: "danaEinzelErlaubnisCell")
        schalterAction.signal.observeValues{[weak self] _ in
            AppConfig.get()?.soundFileZugriff   = .one
            self?.reloadTable.value             = Void()
        }
    }
}

class DanaEinzelFreischaltCell: UITableViewCell {
    var viewModel:DanaEinzelFreischaltCellModel!{
        didSet{
            viewModel.schalterAction    <~ schalter.reactive.isOnValues.signal.map{_ in Void()}
            label.reactive.text         <~ viewModel.labelText.producer
            designBackgroundView.setStandardDesign()
        }
    }
    @IBOutlet weak var schalter: UISwitch!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var designBackgroundView: UIView!
}
