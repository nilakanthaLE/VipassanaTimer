//
//  DatenTypen.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 10.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import Firebase
import ReactiveSwift

enum Rating{
    case null,eins,zwei,drei,vier,fuenf
}

protocol MeditationConfigProto{
    var meditationTitle:String?    {get set}
    var gesamtDauer:TimeInterval   {get set}
    var anapanaDauer:TimeInterval  {get set}
    var mettaDauer:TimeInterval    {get set}
    var mettaEndlos:Bool           {get set}
}
extension MeditationConfigProto{
    var vipassanaDauer:TimeInterval{ return gesamtDauer - anapanaDauer - mettaDauer }

}

protocol MeditationProto:MeditationConfigProto{
    var startDate:Date              {get set}
    var endeDate:Date?              {get set}
    var rating:Rating?              {get set}
}
extension MeditationProto{
    var gesamtDauer:TimeInterval{
        return anapanaDauer + vipassanaDauer + mettaDauer
    }
    var latestMeditationsende:Date{
        let mettaEndlosDauer:TimeInterval = mettaEndlos ? 10 * 60 : 0
        return startDate + gesamtDauer + mettaEndlosDauer
    }
    var startZeitMetta:Date{
        return startDate + anapanaDauer + vipassanaDauer
    }
}





class MeditationNewVersion:MeditationProto{
    var startDate: Date
    var endeDate: Date?
    var rating: Rating?
    
    var meditationTitle: String?
    var gesamtDauer: TimeInterval
    var anapanaDauer: TimeInterval
    var mettaDauer: TimeInterval
    var mettaEndlos: Bool
    
    init(meditationConfig:MeditationConfigProto){
        meditationTitle = meditationConfig.meditationTitle
        gesamtDauer     = meditationConfig.gesamtDauer
        anapanaDauer    = meditationConfig.anapanaDauer
        mettaDauer      = meditationConfig.mettaDauer
        mettaEndlos     = meditationConfig.mettaEndlos
        startDate       = Date()
    }
    
    
    init(meditation:Meditation){
        startDate       = meditation.start ?? Date()
        meditationTitle = meditation.name
        gesamtDauer     = meditation.gesamtDauer
        anapanaDauer    = TimeInterval(meditation.dauerAnapana)
        mettaDauer      = TimeInterval(meditation.dauerMetta)
        mettaEndlos     = meditation.mettaOpenEnd
    }
    
    init(gesamtDauer:TimeInterval,start:Date,anapana:TimeInterval = 5*60, metta:TimeInterval = 5*60, mettaEndlos:Bool = false ){
        self.gesamtDauer    = gesamtDauer
        self.startDate      = start
        
        self.anapanaDauer   = anapana
        self.mettaDauer     = metta
        self.mettaEndlos    = mettaEndlos
    }

    
}






//öffentliche Meditation
// SitzPlätze!
class PublicMeditation:MeditationNewVersion,Equatable,Hashable{
    var hashValue: Int
    
    static func == (lhs: PublicMeditation, rhs: PublicMeditation) -> Bool {
        return lhs.meditator.name == rhs.meditator.name
    }
    
    var meditator:PublicUser
    var statistics:PublicStatistics?
    
    //eigene Meditation
    override init(meditationConfig:MeditationConfigProto){
        meditator                       = PublicUser(meditierender: Meditierender.get())
        statistics                      = PublicStatistics()
        hashValue                       = 0
        canAskForFriendShip             = false
        super.init(meditationConfig: meditationConfig)
    }
    
    //Meditation aus Firebase
    let canAskForFriendShip:Bool
    init(snapshot:DataSnapshot){
        let value = snapshot.value as? NSDictionary
        
        
        hashValue   = (value?["meditationsID"] as? String ?? "ABCDEID").hashValue
        meditator   = PublicUser(publicMeditationSnapShot: snapshot)
        
        let freund                  = Freund.get(withUserID: meditator.userID)
        let freundStatus            = FreundStatus.getStatus(freund?.freundStatus)
        
        let itsMySelf               = meditator.itsMySelf
        canAskForFriendShip         = meditator.nickNameSichtbar  && freundStatus == nil && !itsMySelf
        
        //Meditationsdaten
        let _gesamt = value?["gesamtDauer"] as? TimeInterval ?? 0
        let _start  = Date(timeIntervalSinceReferenceDate: (TimeInterval(value?["start"] as? String ?? "" ) ?? 0))
        super.init(gesamtDauer: _gesamt, start: _start)
        mettaDauer                  = value?["mettaDauer"] as? TimeInterval ?? 0
        anapanaDauer                = value?["anapanaDauer"] as? TimeInterval ?? 0

        //Statistik
        statistics                  = PublicStatistics(snapshot: snapshot,freundStatus:freundStatus)
    }
    
    //für ProfilVorschau
    init(){
        meditator                       = PublicUser(meditierender: Meditierender.get())
        statistics                      = PublicStatistics()
        hashValue                       = 0
        canAskForFriendShip             = false
        super.init(gesamtDauer: 60*60, start: Date(), anapana: 5*60, metta: 0, mettaEndlos: true)
    }
    
    var isPlausible:Bool{
        //ist es plausibel, dass die Meditation immer noch aktiv ist?
        return latestMeditationsende.timeIntervalSince1970 > Date().timeIntervalSince1970
    }
    
    func askForFriendship(){
        guard let userID = meditator.userID ,let spitzName =  meditator.name else {return}
        FirUserConnections.createFreundesanfrage(withUserDict: ["ID":userID,"spitzname":spitzName])
    }
    
    
    
}

struct PublicStatistics{
    let durchSchnittProTag:String?
    let gesamtDauer:String?
    let kursTage:String?
    init?(snapshot:DataSnapshot,freundStatus:FreundStatus?){
        guard freundStatus == .granted , let value = snapshot.value as? NSDictionary,let statistikSichtbarkeit = value["statistikSichtbarkeit"] as? Int16, statistikSichtbarkeit == 1 else {return nil}
        durchSchnittProTag          = value["durchSchnittProTag"] as? String
        gesamtDauer                 = value["gesamtDauerStatistik"] as? String
        kursTage                    = value["kursTage"] as? String
    }
    
    //eigene
    init(){
        let statistics              = Statistics.get()
        durchSchnittProTag          = statistics.durchschnittTag.hhmmString
        gesamtDauer                 = statistics.gesamtDauer.hhmmString
        kursTage                    = "\(statistics.kursTage)"
    }
}


protocol UserProto{
    var name:String?                    {get set}
    var meditationsPlatzTitle:String    {get set}
    var flagge:String                   {get set}
}


//User, der über Firebase veröffentlicht wird

class PublicUser:UserProto{
    var name: String?
    var meditationsPlatzTitle: String
    var flagge: String
    let nickNameSichtbar: Bool
    let userID:String?
    let itsMySelf:Bool
    let flaggeIstSichtbar:Bool
    let message:String?
    init(publicMeditationSnapShot:DataSnapshot){
        let value = publicMeditationSnapShot.value as? NSDictionary
        let nickNameSichtbarkeit    = value?["nickNameSichtbarkeit"] as? Int16 ?? 0
        let _nickName               = value?["meditierenderSpitzname"] as? String
        let _flaggeSichtbar         = value?["flaggeIstSichtbar"] as? Bool ?? false
        let _itsMySelf              = _nickName == Meditierender.get()?.nickName
        let _name                   = _nickName ?? "?"
        name                        = (nickNameSichtbarkeit == 2 ||  _itsMySelf ) ? _name : "?"
        
        //falls ich             -> meditationsPlatzTitle != nil
        // falls neue Version   -> meditationsPlatzTitle != nil
        // falls alte Version + nickNameSichtbarkeit == 2 -> nickName
        // sonst : "?"
        meditationsPlatzTitle       = value?["meditationsPlatzTitle"] as? String ?? (nickNameSichtbarkeit == 2 ? _name : "?")
        flagge                      = value?["flagge"]  as? String ?? "?"
        nickNameSichtbar            = nickNameSichtbarkeit == 2
        userID                      = publicMeditationSnapShot.key
        itsMySelf                   = _itsMySelf
        flaggeIstSichtbar           = _flaggeSichtbar
        message                     = value?["message"]  as? String
    }
    init(meditierender:Meditierender?){
        self.name               = meditierender?.nickName
        nickNameSichtbar        = meditierender?.nickNameSichtbarkeit == 2
        meditationsPlatzTitle   = meditierender?.meditationsPlatzTitle ?? "?"
        userID                  = meditierender?.userID
        flaggeIstSichtbar       = meditierender?.flaggeIstSichtbar ?? false
        flagge                  = meditierender?.flagge ?? "?"
        message                 = meditierender?.message
        itsMySelf               = true
    }
}




//class CDUser:UserProto{
//    var name: String?
//    var meditationsPlatzTitle: String?
//    var flagge: String?
//    
////    var statistics:PublicStatistics{ return PublicStatistics() }
//    
//    init(){
//        name                    = "cake"
//        meditationsPlatzTitle   = "?" //"Test" //"🧘‍♂️"
//    }
//}



struct SoundFileData:Equatable{
    var title: String
    var duration:TimeInterval
    var mettaDuration:TimeInterval
    var fireBaseTitle:String
    
    
    var loacalSoundfileURL:URL?{
        let docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last
        return  docURL?.appendingPathComponent("\(title).mp3")
    }
    var isDownloaded:Bool{ return SoundFileDataCD.get(soundFileData: self) != nil }
    
    
    init(title: String,duration:TimeInterval,mettaDuration:TimeInterval,fireBaseTitle:String){
        self.title          = title
        self.duration       = duration
        self.mettaDuration  = mettaDuration
        self.fireBaseTitle  = fireBaseTitle
    }
    init?(snapshot:DataSnapshot?){
        
        guard
            let value   = snapshot?.value as? NSDictionary,
            let _title  = (value["title"] as? String),
            let _firebaseTitle = (value["fireBaseTitle"] as? String),
            let _duration   = value["duration"] as? TimeInterval,
            let _mettaDuration = value["mettaDuration"] as? TimeInterval
            else { return nil }
        title           = _title
        fireBaseTitle   = _firebaseTitle
        duration        = _duration
        mettaDuration   = _mettaDuration
        
    }
    
    //Beispiel
    init(){
        self.title          = "Dubai Long English"
        self.duration       = 3925
        self.mettaDuration  = 710
        self.fireBaseTitle  = "Dubai_Long-Instr_E_GS"
    }
    
    
    var firebaseData:[String:Any] {
        return ["title"         : title,
                "duration"      : duration,
                "mettaDuration" : mettaDuration,
                "fireBaseTitle" : fireBaseTitle
        ]
    }
}

class FirNotitification{
    static let ref  = database.reference(withPath: "notifications")
    static func insertNew(){
        ref.child("1").setValue("Test! \n Test blubb blubb blubb")
    }
    
    static func setObserver(){
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            
            AppConfig.setNotification(snapshot: snapshot) })
    }
}


class FireBaseSoundFiles{
    static let ref  = database.reference(withPath: "soundFiles")
    static func insertNew(soundFileData:SoundFileData){
        ref.child(soundFileData.fireBaseTitle).setValue(soundFileData.firebaseData)
    }
    
    static func getList(soundFileDatas:MutableProperty<[SoundFileData]>) {
        //enthält letzte Daten (von Disk!)
        ref.keepSynced(true)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {return}
            soundFileDatas.value = snapshot.children.map{SoundFileData(snapshot: $0 as? DataSnapshot)}.compactMap{$0}
        }
    }
}

class FireBaseSoundFilesStorage{
    static let ref  = storage.reference(withPath: "meditationSoundFiles")
    
    static func download(soundFileData:SoundFileData,progress:MutableProperty<(tag:Int,progress:Double)>?,finished:MutableProperty<Void>?){
        print("FireBaseSoundFilesStorage dowload: \(soundFileData)")
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
            guard let errorCode = (snapshot.error as? NSError)?.code else { return }
            guard let error = StorageErrorCode(rawValue: errorCode) else { return }
            switch (error) {
            case .objectNotFound: print("File doesn't exist")
            case .unauthorized: print("User doesn't have permission to access file")
            case .cancelled:print("User cancelled the download")
            case .unknown:print("Unknown error occurred, inspect the server response")
            default:print("Another error occurred. This is a good place to retry the download")
            }
        }
    }
}
