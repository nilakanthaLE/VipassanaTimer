//
//  PublicMeditation.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 17.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import Firebase

//✅
//publicMeditation
// eigene gestartete Meditationen werden in Firebase/activeMeditation geschrieben
// aktive Meditationen anderer User werden als Sitzplätze angezeigt
class PublicMeditation:MeditationBasis,Equatable,Hashable{
    
    //Protocols (Equatable,Hashable)
    var hashValue: Int
    static func == (lhs: PublicMeditation, rhs: PublicMeditation) -> Bool { return lhs.meditator.name == rhs.meditator.name }
    
    let meditator:PublicUser
    let statistics:PublicStatistics?
    let hasSoundFile:Bool
    let canAskForFriendShip:Bool
    //ist es plausibel, dass die Meditation immer noch aktiv ist?
    var isPlausible:Bool{ return latestMeditationsende.timeIntervalSince1970 > Date().timeIntervalSince1970 }
    
    //MARK: inits
    // -> eigene (public) Meditation
    override init(meditationConfig:MeditationConfigProto){
        meditator                       = PublicUser(meditierender: Meditierender.get())
        statistics                      = PublicStatistics()
        hashValue                       = 0
        canAskForFriendShip             = false
        hasSoundFile                    = (meditationConfig as? TimerData)?.soundFileData != nil
        super.init(meditationConfig: meditationConfig)
    }
    //-> Meditation aus Firebase
    init(snapshot:DataSnapshot){
        let value = snapshot.value as? NSDictionary
        hashValue   = ((value?["start"] as? String ?? "ABCDEID") + (value?["gesamtDauer"] as? String ?? "XYZID")).hashValue
        
        meditator                   = PublicUser(publicMeditationSnapShot: snapshot)
        let freund                  = Freund.get(withUserID: meditator.userID)
        let freundStatus            = FreundStatus.getStatus(freund?.freundStatus)
        let itsMySelf               = meditator.itsMySelf
        canAskForFriendShip         = meditator.nickNameSichtbar  && freundStatus == nil && !itsMySelf
        statistics                  = PublicStatistics(snapshot: snapshot,freundStatus:freundStatus)
        hasSoundFile                = value?["hasSoundFile"] as? Bool ?? false
        
        //Meditationsdaten
        let _gesamt = value?["gesamtDauer"] as? TimeInterval ?? 0
        let _start  = Date(timeIntervalSinceReferenceDate: (TimeInterval(value?["start"] as? String ?? "" ) ?? 0))
        super.init(gesamtDauer: _gesamt, start: _start)
        mettaDauer                  = value?["mettaDauer"] as? TimeInterval ?? 0
        anapanaDauer                = value?["anapanaDauer"] as? TimeInterval ?? 0
    }
    //-> Meditation für ProfilVorschau
    init(){
        meditator                       = PublicUser(meditierender: Meditierender.get())
        statistics                      = PublicStatistics()
        hashValue                       = 0
        canAskForFriendShip             = false
        hasSoundFile                    = false
        super.init(gesamtDauer: 60*60, start: Date(), anapana: 5*60, metta: 0, mettaEndlos: true)
    }
    
    // einem User eine Freundschaftsanfrage senden
    func askForFriendship(){
        guard let userID = meditator.userID ,let spitzName =  meditator.name else {return}
        FirUserConnections.createFreundesanfrage(withUserDict: ["ID":userID,"spitzname":spitzName])
    }
    
    //Snapshot für Firebase
    // eigene aktive Meditation
    // enthält statistische Daten
    // enthält Informationen über den User
    var firebasePublicMeditation:[String:Any] {
        let meditierender           = Meditierender.get()
        let statistics              = Statistics.get()
        
        return [
            //MeditationsDaten
            "start"                         : String(startDate.timeIntervalSinceReferenceDate),
            "gesamtDauer"                   : gesamtDauer,
            "anapanaDauer"                  : anapanaDauer,
            "mettaDauer"                    : mettaDauer,
            "mettaOpenEnd"                  : mettaEndlos,
            "hasSoundFile"                  : hasSoundFile ,
            //Statistik
            "durchSchnittProTag"            : statistics.durchschnittTag.hhmm,
            "gesamtDauerStatistik"          : statistics.gesamtDauer.hhmm,
            "kursTage"                      : "\(statistics.kursTage)",
            //Meditierender
            "meditierenderSpitzname"        : meditierender?.nickName ?? "",
            "nickNameSichtbarkeit"          : meditierender?.nickNameSichtbarkeit ?? 0,
            "statistikSichtbarkeit"         : meditierender?.statistikSichtbarkeit ?? 0,
            "meditationsPlatzTitle"         : meditierender?.meditationsPlatzTitle ?? "?",
            "flagge"                        : meditierender?.flagge ?? "",
            "flaggeIstSichtbar"             : meditierender?.flaggeIstSichtbar ?? false,
            "message"                       : meditierender?.message ?? ""
        ]
    }
}
