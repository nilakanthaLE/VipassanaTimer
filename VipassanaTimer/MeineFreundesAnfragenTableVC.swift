//
//  MeineFreundesAnfragenTableVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 22.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
class MeineFreundesAnfragenTableVC: DesignTableViewControllerPortrait {
    var viewModel:MeineFreundesAnfragenTableVCModel!    { didSet{ viewModel.updateTableView.signal.observeValues {[weak self] _ in self?.tableView.reloadData() } } }
    
    // MARK: - Table view data source && delegate
    override func numberOfSections(in tableView: UITableView) -> Int                                        { return 2 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int            { return viewModel.numberOfRows(in: section) }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                    = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MeineFreundesAnfragenTableViewCell
        cell.title                  = viewModel.getCellTitle(for: indexPath)
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?                                  { return viewModel.header(for: section) }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool                                        { return true }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)  { if editingStyle == .delete { viewModel.deleteAction(indexPath: indexPath) } }
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = headerBackground
        (view as? UITableViewHeaderFooterView)?.textLabel?.textColor = standardSchriftFarbe
    }
    
    //segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? FreundeFindenVC)?.viewModel = FreundeFindenVCModel()
    }
    
    
    deinit { print("deinit: MeineFreundesAnfragenTableVC")}
}

//✅
class MeineFreundesAnfragenTableViewCell:UITableViewCell{
    var title:String?{
        didSet{
            textLabel?.text         = title
            textLabel?.textColor    = standardSchriftFarbe
            backgroundColor         = standardBackgroundFarbe
        }
    }
}
