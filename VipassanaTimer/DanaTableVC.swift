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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
