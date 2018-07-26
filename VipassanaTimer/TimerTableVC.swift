//
//  TimerTableVC.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 03.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
class TimerTableVC: DesignTableViewControllerPortrait {
    var viewModel:TimerTableVCModel!

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int                                { return 1 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int    { return viewModel.numberOfRows }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell.contentView.subviews.first as? TimerAnzeigeView)?.viewModel = viewModel.getViewModelForCell(indexPath: indexPath)
        cell.selectionStyle = .none
        cell.contentView.subviews.first?.setNeedsLayout()
        cell.contentView.subviews.first?.layoutIfNeeded()
        return cell
    }
    
    //TableView Delegates
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{ viewModel.deleteTimer(at: indexPath.row)  }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectMeditationsTimer(indexPath: indexPath)
        navigationController?.popViewController(animated: true)
    }
    
    //VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 44
        viewModel.updateTable.signal.observeValues{ [weak self] _ in self?.tableView.reloadData() }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    //Segues (--> Timersettings)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination.contentViewController as? TimerSettingsVC else {return}
        // falls segue per klick auf accessoryButton --> row
        // sonst per addButton --> row = nil
        var row:Int?{
            guard let sender = sender as? UITableViewCell else {return nil}
            return tableView.indexPath(for: sender)?.row
        }
        destination.viewModel   = viewModel.getTimerSettingsViewControllerModel(row: row)
    }
    
    deinit { print("deinit TimerTableVC") }
}


