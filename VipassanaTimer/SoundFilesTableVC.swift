//
//  SoundFilesTableVC.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 07.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

class SoundFilesTableVCModel{
    
    func getViewModelForTableViewCell(indexPath:IndexPath) -> SoundFileViewModel{
        return SoundFileViewModel(soundFileData: MutableProperty<SoundFileData?>(soundFilesData.value[indexPath.row]), downloadProgress: downloadProgressForRow,tag:indexPath.row)
    }

    func numberOfRows(for section:Int) -> Int{
        return section == 1 ? soundFilesData.value.count : 1
    }
    
    
    
    private var soundFilesData  = MutableProperty<[SoundFileData]>([SoundFileData]())
    let popViewController       = MutableProperty<Void>(Void())
    let reloadData              = MutableProperty<Void>(Void())
    let soundFileData:MutableProperty<SoundFileData?>
    init(soundFileData:MutableProperty<SoundFileData?>){
        self.soundFileData = soundFileData
        reloadData <~ soundFilesData.signal.map{_ in Void()}
        FireBaseSoundFiles.getList(soundFileDatas: soundFilesData)
        soundFilesData.signal.observeValues{print($0)}
        reloadData <~ downloadFinished
    }
    
    let downloadProgressForRow  = MutableProperty<(tag:Int,progress:Double)>((0,0))
    let downloadFinished        = MutableProperty<Void>(Void())
    func didSelect(indexPath:IndexPath){
        if indexPath.section == 0{
            soundFileData.value = nil
            popViewController.value = Void()
        }
        else {
            let soundFile = soundFilesData.value[indexPath.row]
            switch soundFile.isDownloaded {
            case true:
                soundFileData.value = soundFile
                popViewController.value = Void()
            case false:
                downloadProgressForRow.value.tag = indexPath.row
                FireBaseSoundFilesStorage.download(soundFileData: soundFile, progress: downloadProgressForRow,finished: downloadFinished)
                reloadData.value = Void()
            }
        }
    }
    
    
    //zum testen
    func deleteSoundFileDataCD(row:Int){
        SoundFileDataCD.get(soundFileData: soundFilesData.value[row])?.delete()
        reloadData.value = Void()
    }
    func canDelete(indexPath:IndexPath) -> Bool{
        return indexPath.section == 1 && soundFilesData.value[indexPath.row].isDownloaded == true
    }
}

class SoundFilesTableVC: UITableViewController {
    var viewModel:SoundFilesTableVCModel!{
        didSet{
            tableView.reactive.reloadData <~ viewModel.reloadData.producer
            viewModel.popViewController.signal.observe{[weak self] _ in self?.navigationController?.popViewController(animated: true)}
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait  }
    
    override func viewDidLoad() {
        print("SoundFilesTableVC viewDidLoad")
        super.viewDidLoad()
        
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 44
        
        view.backgroundColor            = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
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
            label?.layer.borderColor    = standardRahmenFarbe.cgColor
            label?.layer.borderWidth    = standardBorderWidth
            label?.layer.cornerRadius   = standardCornerRadius
            label?.clipsToBounds        = true
            
        }
        else {
            (cell.contentView.subviews[0] as? SoundFileView)?.viewModel = viewModel.getViewModelForTableViewCell(indexPath: indexPath)
            (cell.contentView.subviews[0] as? SoundFileView)?.tapOnBluerViewGesture.isEnabled = false
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelect(indexPath: indexPath)
    }
    
    
    //zum Testen
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return viewModel.canDelete(indexPath: indexPath) }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { if editingStyle == .delete{ viewModel.deleteSoundFileDataCD(row: indexPath.row) }  }
    
    
}
