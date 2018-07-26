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
let DubaiLongEng                   = SoundFileData(title: "Dubai Long English - 1999",      duration: 3917, mettaDuration: 702, fireBaseTitle: "Dubai_Long-Instr_E_GS")
let MinimalShortEng                = SoundFileData(title: "Minimal Short - 1985",           duration: 3904, mettaDuration: 310, fireBaseTitle: "Minimal_Short-Instr_E_GS")
let JuhuShortEng                   = SoundFileData(title: "Juhu (Mumbai) Short - 1987",     duration: 3928, mettaDuration: 337, fireBaseTitle: "Juhu_Short-Instr_E-only_GS")
let KhettaShortEng                 = SoundFileData(title: "Dhamma Khetta Short - 1984",     duration: 3907, mettaDuration: 383, fireBaseTitle: "Khetta_Short-Instr_E_GS")
let SalilaLongEng                  = SoundFileData(title: "Dhamma Salila Long - 1998",      duration: 3874, mettaDuration: 577, fireBaseTitle: "Salila_Long-Instr_E_GS")
let SalilaShortEng                 = SoundFileData(title: "Dhamma Salila Short - 1998",     duration: 3957, mettaDuration: 510, fireBaseTitle: "Salila_Short-Instr_E_GS")
let SikharaShortEng                = SoundFileData(title: "Dhamma Sikhara Short - 2000",    duration: 3901, mettaDuration: 376, fireBaseTitle: "Sikhara_Short-Instr_E_GS")
let VIALongEng                     = SoundFileData(title: "(VIA) Dhamma Giri Long - 1992",  duration: 3901, mettaDuration: 807, fireBaseTitle: "VIA_Long-Instr_E_GS")
let SetuLongEng                    = SoundFileData(title: "Dhamma Setu Long - 2000",        duration: 3900, mettaDuration: 539, fireBaseTitle: "Setu_Long-Instr_E_GS")
