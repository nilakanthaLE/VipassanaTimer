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
    let reloadData                      = MutableProperty<Void>(Void())
    let popViewController               = MutableProperty<Void>(Void())
    let messageDownloadIsNotAllowed     = MutableProperty<Void>(Void())
    private let soundFileData:MutableProperty<SoundFileData?>
    init(soundFileData:MutableProperty<SoundFileData?>){
        self.soundFileData = soundFileData
        
        soundFilesDataSorted    <~ soundFilesDataUnsorted.signal.map{SoundFilesTableVCModel.sort(soundFilesData: $0)}
        soundFilesDataSorted    <~ downloadFinished.signal.map{[weak self] _ in SoundFilesTableVCModel.sort(soundFilesData: self?.soundFilesDataUnsorted.value) }
        reloadData  <~ soundFilesDataSorted.signal.map{_ in Void()}
       
        FireBaseSoundFiles.getList(soundFileDatas: soundFilesDataUnsorted)
    }
    
    let sectionHeaderTitle              = ["None","English","Eng-Ger","Eng-Hin","Hin","Other"]
    
    //private MutableProperties
    private var soundFilesDataSorted    = MutableProperty<[[SoundFileData]]>([[SoundFileData]]())
    private var soundFilesDataUnsorted  = MutableProperty<[SoundFileData]>([SoundFileData]())
    private let downloadProgressForRow  = MutableProperty<(tag:Int,progress:Double)>((0,0))
    private let downloadFinished        = MutableProperty<Void>(Void())
    
    //Table View
    func numberOfSections()-> Int               { return soundFilesDataSorted.value.count }
    func numberOfRows(for section:Int) -> Int   { return section == 0 ?  1 : soundFilesDataSorted.value.count > 0 ? soundFilesDataSorted.value[section].count : 0 }
    func didSelect(indexPath:IndexPath){
        if indexPath.section == 0{
            soundFileData.value = nil
            popViewController.value = Void()
        }
        else {
            let soundFile = soundFilesDataSorted.value[indexPath.section][indexPath.row]
            switch soundFile.isDownloaded {
            case true:
                soundFileData.value     = soundFile
                popViewController.value = Void()
            case false:
                //fals kein SoundFileZugriff erlaubt ist  -> Message
                let soundFileZugriff = AppConfig.get()?.soundFileZugriff ?? SoundFileAccess.none
                guard soundFileZugriff != SoundFileAccess.none else {
                    messageDownloadIsNotAllowed.value = Void()
                    return
                }
                if soundFileZugriff == SoundFileAccess.one {
                    AppConfig.get()?.soundFileZugriff = SoundFileAccess.none
                }
                downloadProgressForRow.value.tag = indexPath.row
                FireBaseSoundFilesStorage.download(soundFileData: soundFile, progress: downloadProgressForRow, finished: downloadFinished)
                reloadData.value = Void()
            }
        }
    }
    
    //helper
    private static func sort(soundFilesData:[SoundFileData]?) -> [[SoundFileData]]{
        
        guard let soundFilesData = soundFilesData else { return [[SoundFileData]]() }
        //none
        //englisch
        let eng     = soundFilesData.filter{$0.fireBaseTitle.contains("_E_") || $0.fireBaseTitle.contains("_E-only_")}.sorted{$0.isDownloaded && !$1.isDownloaded}
        //englisch-deutsch
        let eng_ger = soundFilesData.filter{$0.fireBaseTitle.contains("_E-Ge_")}.sorted{$0.isDownloaded && !$1.isDownloaded}
        //englisch-hindi
        let eng_hin = soundFilesData.filter{$0.fireBaseTitle.contains("_H-E_")}.sorted{$0.isDownloaded && !$1.isDownloaded}
        //hindi
        let hin     = soundFilesData.filter{$0.fireBaseTitle.contains("_H_") || $0.fireBaseTitle.contains("_H-only_")}.sorted{$0.isDownloaded && !$1.isDownloaded}
        //other
        let other   = soundFilesData.filter{!$0.fireBaseTitle.contains("_H_") && !$0.fireBaseTitle.contains("_H-only_") &&
                                            !$0.fireBaseTitle.contains("_E_") && !$0.fireBaseTitle.contains("_E-only_") &&
                                            !$0.fireBaseTitle.contains("_E-Ge_") &&
                                            !$0.fireBaseTitle.contains("_H-E_") }.sorted{$0.isDownloaded && !$1.isDownloaded}
        print("\([[SoundFileData](),eng,eng_ger,eng_hin,hin,other].map{$0.count})")
        return [[SoundFileData](),eng,eng_ger,eng_hin,hin,other]
    }
    
    //ViewModel (Cells)
    func getViewModelForTableViewCell(indexPath:IndexPath) -> SoundFileViewModel
        { return SoundFileViewModel(soundFileData: MutableProperty<SoundFileData?>(soundFilesDataSorted.value[indexPath.section][indexPath.row]), downloadProgress: downloadProgressForRow,tag:indexPath.row) }
    
    deinit {  print("deinit SoundFilesTableVCModel") }
}
