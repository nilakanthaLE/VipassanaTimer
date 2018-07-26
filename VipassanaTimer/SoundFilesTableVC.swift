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
            viewModel.popViewController.signal.observeValues{[weak self] _ in self?.navigationController?.popViewController(animated: true)}
            viewModel.messageDownloadIsNotAllowed.signal.observeValues{ [weak self] _ in self?.presentSoundFileDownloadNotAllowed() }
        }
    }
    
    //ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 44
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int                                { return viewModel.numberOfSections() }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int    { return viewModel.numberOfRows(for: section) }
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)              { viewModel.didSelect(indexPath: indexPath) }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label               = UILabel()
        label.text              = viewModel.sectionHeaderTitle[section]
        label.textAlignment     = .center
        label.backgroundColor   = standardBackgroundFarbe.withAlphaComponent(1)
        label.textColor         = standardSchriftFarbe
        return label
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.numberOfRows(for: section) > 0 ?  25 : CGFloat.leastNonzeroMagnitude }
    
    //SoundFile Download nicht erlaubt
    private func presentSoundFileDownloadNotAllowed(){
        let notificationVC = UIAlertController(title:   NSLocalizedString("noSoundfileDownloadTitle", comment: "noSoundfileDownloadTitle"),
                                               message: NSLocalizedString("noSoundfileDownloadMessage", comment: "noSoundfileDownloadMessage"),
                                               preferredStyle: .alert)
        notificationVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(notificationVC, animated: true, completion: nil)
    }
    
    
    deinit { print("deinit SoundFilesTableVC") }
}



