//
//  FreundeTableVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 22.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
class FreundeTableVC: DesignTableViewControllerPortrait {
    var viewModel:FreundeTableVCModel!{ didSet{ viewModel.updateTableView.signal.observeValues {[weak self] _ in self?.tableView.reloadData() } } }

    // MARK: - Table view data source && delgate
    override func numberOfSections(in tableView: UITableView) -> Int                                    { return 2 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int        { return viewModel.numberOfRows(section: section)}
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                    = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FreundeTableViewCell
        cell.viewModel              = viewModel.getViewModelForCell(indexPath: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?  { return viewModel.getHeaderTitel(section: section) }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool        { return true }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { if editingStyle == .delete { viewModel.deleteAction(indexPath: indexPath)  } }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? { return viewModel.deleteButtonTitle(indexPath: indexPath) }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor                                                  = headerBackground
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor    = standardSchriftFarbe
    }
    
    //segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { (segue.destination.contentViewController as? MeineFreundesAnfragenTableVC)?.viewModel = MeineFreundesAnfragenTableVCModel() }
    
    deinit { print("deinit FreundeTableVC") }
}
