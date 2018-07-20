//
//  FireBaseSoundFiles.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 17.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Firebase
import ReactiveSwift

//✅
// SoundFileData aus Firebase holen
class FireBaseSoundFiles{
    static let ref  = database.reference(withPath: "soundFiles")
    static func insertNew(soundFileData:SoundFileData){ ref.child(soundFileData.fireBaseTitle).setValue(soundFileData.firebaseData) }
    
    static func getList(soundFileDatas:MutableProperty<[SoundFileData]>) {
        //enthält letzte Daten (von Disk!)
        ref.keepSynced(true)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {return}
            soundFileDatas.value = snapshot.children.map{ SoundFileDataCD.update(soundFileData: SoundFileData(snapshot: $0 as? DataSnapshot)) }.compactMap{$0}
        }
    }
}

//✅
// SoundFile Downloader
class FireBaseSoundFilesStorage{
    static let ref  = storage.reference(withPath: "meditationSoundFiles")
    
    static func download(soundFileData:SoundFileData,progress:MutableProperty<(tag:Int,progress:Double)>?,finished:MutableProperty<Void>?){
        guard let localUrl =  soundFileData.loacalSoundfileURL else {return}
        
        
        let downloadTask = ref.child(soundFileData.fireBaseTitle + ".mp3").write(toFile: localUrl) {url, error in if let error = error{ print("FireBaseSoundFilesStorage error: \(error) ") } }
        
        downloadTask.observe(.success) { snapshot in
            print("// Download completed successfully")
            _ = SoundFileDataCD.create(soundFileData: soundFileData)
            finished?.value = Void()
        }
        downloadTask.observe(.progress) { snapshot in
            // Download reported progress
            let complete =  Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            progress?.value.progress = complete
        }
        downloadTask.observe(.failure) { snapshot in
            guard let errorCode = (snapshot.error as NSError?)?.code else { return }
            guard let error = StorageErrorCode(rawValue: errorCode) else { return }
            switch (error) {
            case .objectNotFound:   print("File doesn't exist")
            case .unauthorized:     print("User doesn't have permission to access file")
            case .cancelled:        print("User cancelled the download")
            case .unknown:          print("Unknown error occurred, inspect the server response")
            default:                print("Another error occurred. This is a good place to retry the download")
            }
        }
    }
}

//SoundFileDaten
let SoundFileDubaiLongEnglish = SoundFileData(title: "Dubai Long English", duration: 3925, mettaDuration: 710, fireBaseTitle: "Dubai_Long-Instr_E_GS")
