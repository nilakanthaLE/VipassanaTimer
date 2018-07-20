//
//  DanaTableVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 04.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import StoreKit
import ReactiveSwift



// in Progress
class DanaTableVCModel{
    var products:[SKProduct] = [SKProduct]()
    let reloadTable = MutableProperty<Void>(Void())
    init(){
        DanaProducts.store.requestProducts { [weak self] (success, products) in
            self?.products      = products ?? [SKProduct]()
            self?.reloadTable.value   = Void()
        }
    }
}

class DanaTableVC: UITableViewController {
    var viewModel:DanaTableVCModel!{
        didSet{
            viewModel.reloadTable.producer.start() { [weak self] _ in self?.tableView.reloadData() }
        }
    }
        
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = DanaTableVCModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int { return 1  }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return viewModel.products.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let product = viewModel.products[indexPath.row]
        
        let price:String = {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.locale      = product.priceLocale
            return numberFormatter.string(from: product.price) ?? ""
        }()
        
        var button  = UIButton()
        var label   = UILabel()
        for subview in cell.contentView.subviews{
            if let _label = subview as? UILabel     { label = _label }
            if let _button = subview as? UIButton   {  button = _button }
        }
        
        label.text  = "dana " + "\(price)"
        button.tag  = indexPath.row
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        
        if DanaProducts.store.isProductPurchased(product.productIdentifier){
            cell.accessoryType  = .checkmark
            button.isHidden     = true
        }
        else if IAPHelper.canMakePayments(){
            cell.accessoryType  = .none
        }
        else{
            cell.accessoryType  = .none
            button.isHidden     = true
            label.text          = "Keine Zahlung möglich"
        }
        return cell
    }
    
    @objc func buttonPressed(sender:UIButton){
       DanaProducts.store.buyProduct(viewModel.products[sender.tag])
    }
}
