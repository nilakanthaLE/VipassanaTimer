//
//  SoundFileData.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 17.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import Firebase

//✅
//Daten der Soundfiles
// name, dauer usw.
// Filename, wie er in FireStore gespeichert ist
struct SoundFileData:Equatable{
    var title: String
    var duration:TimeInterval
    var mettaDuration:TimeInterval
    var fireBaseTitle:String
    
    //calc Properties
    var loacalSoundfileURL:URL?{
        let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
        return  docURL?.appendingPathComponent("\(title).mp3")
    }
    var isDownloaded:Bool{ return SoundFileDataCD.get(soundFileData: self) != nil }
    
    //MARK: init
    init(title: String,duration:TimeInterval,mettaDuration:TimeInterval,fireBaseTitle:String){
        self.title          = title
        self.duration       = duration
        self.mettaDuration  = mettaDuration
        self.fireBaseTitle  = fireBaseTitle
    }
    init?(snapshot:DataSnapshot?){
        guard
            let value           = snapshot?.value as? NSDictionary,
            let _title          = (value["title"] as? String),
            let _firebaseTitle  = (value["fireBaseTitle"] as? String),
            let _duration       = value["duration"] as? TimeInterval,
            let _mettaDuration  = value["mettaDuration"] as? TimeInterval   else { return nil }
        title           = _title
        fireBaseTitle   = _firebaseTitle
        duration        = _duration
        mettaDuration   = _mettaDuration
    }
    
    //FirbaseSnapshot
    var firebaseData:[String:Any] {
        return ["title"         : title,
                "duration"      : duration,
                "mettaDuration" : mettaDuration,
                "fireBaseTitle" : fireBaseTitle
        ]
    }
}
