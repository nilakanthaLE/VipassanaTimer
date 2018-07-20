//
//  SoundFilesTableVC.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 07.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
class SoundFilesTableVC: DesignTableViewControllerPortrait {
    var viewModel:SoundFilesTableVCModel!{
        didSet{
            tableView.reactive.reloadData <~ viewModel.reloadData.producer
            viewModel.popViewController.signal.observe{[weak self] _ in self?.navigationController?.popViewController(animated: true)}
        }
    }
    
    //ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 44
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int                                { return 2 }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int    {  return viewModel.numberOfRows(for: section) }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = indexPath.section == 1 ? "cell" : "NoSoundFileCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if indexPath.section == 0 {
            let label                   = cell.contentView.subviews[0] as? UILabel
            label?.text                 = "Kein Soundfile"
            label?.setStandardDesign()
        }
        else {
            (cell.contentView.subviews[0] as? SoundFileView)?.viewModel                         = viewModel.getViewModelForTableViewCell(indexPath: indexPath)
            (cell.contentView.subviews[0] as? SoundFileView)?.tapOnBluerViewGesture.isEnabled   = false
        }
        cell.selectionStyle = .none
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { viewModel.didSelect(indexPath: indexPath) }
    
    deinit { print("deinit SoundFilesTableVC") }
}



