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
let reloadDanaAfterPurchase     = MutableProperty<Void>(Void())
let startDanaRequest            = MutableProperty<Void>(Void())
let endDanaRequest              = MutableProperty<Void>(Void())
class DanaTableVCModel{
    var products:[SKProduct]        = [SKProduct]()
    let reloadTable                 = MutableProperty<Void>(Void())
    let presentPleaseWait           = MutableProperty<Bool>(false)
    init(){
        DanaProducts.store.requestProducts { [weak self] (success, products) in
            self?.products              = products ?? [SKProduct]()
            self?.reloadTable.value     = Void()
        }
        reloadTable                 <~ reloadDanaAfterPurchase.signal
        
        presentPleaseWait           <~ startDanaRequest.signal.map{_ in true }
        presentPleaseWait           <~ endDanaRequest.signal.map{_ in false }
    }
    
    var haseinzelnFreischaltenCell:Bool         { return AppConfig.get()?.soundFileZugriff  == SoundFileAccess.none }
    var numberOfSections:Int                    { return haseinzelnFreischaltenCell ? 2 : 1 }
    func numberOfRows(in section:Int) -> Int    { return numberOfSections == 2 && section == 0 ? 1 : products.count }
    
    //viewModels
    func getViewModelForDanaCell(indexPath:IndexPath) -> DanaTableViewCellModel{ return DanaTableViewCellModel(product: products[indexPath.row]) }
    func getViewModelForDanaEinzelFreischaltCell() -> DanaEinzelFreischaltCellModel{
        let model = DanaEinzelFreischaltCellModel()
        reloadTable <~ model.reloadTable.signal
        return model
    }
    
    deinit { print("deinit DanaTableVCModel") }
}

class DanaTableVC: DesignTableViewControllerPortrait {
    var viewModel:DanaTableVCModel!{
        didSet{
            viewModel.reloadTable.producer.start()          { [weak self] _ in self?.tableView.reloadData() }
            reloadDanaAfterPurchase.signal.observeValues    { [weak self] _ in self?.presentThankYou() }
            viewModel.presentPleaseWait.signal.observeValues{ [weak self] isPresenting in self?.presentPleaseWaitAction(isPresenting: isPresenting) }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = DanaTableVCModel()
        tableView.register(UINib(nibName: "DanaTableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "DanaEinzelFreischaltCell", bundle: .main), forCellReuseIdentifier: "einzelnFreischaltenCell")
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int                                { return viewModel.numberOfSections  }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int    { return viewModel.numberOfRows(in: section) }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.haseinzelnFreischaltenCell && indexPath.section == 0 {
            let cell        = tableView.dequeueReusableCell(withIdentifier: "einzelnFreischaltenCell", for: indexPath) as! DanaEinzelFreischaltCell
            cell.viewModel  = viewModel.getViewModelForDanaEinzelFreischaltCell()
            return cell
        }
        let cell        = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DanaTableViewCell
        cell.viewModel = viewModel.getViewModelForDanaCell(indexPath: indexPath)
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 80 }
    
    @IBAction func infoButtonPressed(_ sender: UIBarButtonItem) {
        let alertView = UIAlertController(title: "Dana Info",
                                          message: NSLocalizedString("danaInfoMessage", comment: ("danaInfoMessage")),
                                          preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    //helper
    
    private func presentThankYou(){
        let alertView = UIAlertController(title: "Thank you", message: "🙏", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    private func presentPleaseWaitAction(isPresenting:Bool){
        switch isPresenting{
            
        case true:
            let alertView = UIAlertController(title: "Please wait", message: " ... ", preferredStyle: .alert)
            present(alertView, animated: true, completion: nil)
        case false:
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    deinit { print("deinit DanaTableVC") }
}




