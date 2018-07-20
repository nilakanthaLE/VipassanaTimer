//
//  SoundFilesTableVCModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
class SoundFilesTableVCModel{
    let reloadData              = MutableProperty<Void>(Void())
    let popViewController       = MutableProperty<Void>(Void())
    private let soundFileData:MutableProperty<SoundFileData?>
    init(soundFileData:MutableProperty<SoundFileData?>){
        self.soundFileData = soundFileData
        reloadData  <~ soundFilesData.signal.map{_ in Void()}
        reloadData  <~ downloadFinished
        FireBaseSoundFiles.getList(soundFileDatas: soundFilesData)
        soundFilesData.signal.observeValues{print($0)}
    }
    
    //private MutableProperties
    private var soundFilesData  = MutableProperty<[SoundFileData]>([SoundFileData]())
    private let downloadProgressForRow  = MutableProperty<(tag:Int,progress:Double)>((0,0))
    private let downloadFinished        = MutableProperty<Void>(Void())
    
    //Table View
    func numberOfRows(for section:Int) -> Int{ return section == 1 ? soundFilesData.value.count : 1  }
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
    
    //ViewModel (Cells)
    func getViewModelForTableViewCell(indexPath:IndexPath) -> SoundFileViewModel
        { return SoundFileViewModel(soundFileData: MutableProperty<SoundFileData?>(soundFilesData.value[indexPath.row]), downloadProgress: downloadProgressForRow,tag:indexPath.row) }
    
    deinit {  print("deinit SoundFilesTableVCModel") }
}
