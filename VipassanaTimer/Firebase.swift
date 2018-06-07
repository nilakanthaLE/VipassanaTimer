//
//  Firebase.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 11.07.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import CloudKit
import ReactiveSwift

//global

func saveContext()                              { DispatchQueue.main.async { (UIApplication.shared.delegate as? AppDelegate)?.saveContext() } }
var AppUserFBID : String?                       { return AppUser.get()?.firebaseID  }

extension DataSnapshot{
    var valueAsDict:NSDictionary?       { return (value as? NSDictionary) }
    var firstValue:NSDictionary?        { return (value as? NSDictionary)?.allValues.first as? NSDictionary }
    var firstKey:String?                { return (value as? NSDictionary)?.allKeys.first as? String }
}

class FirSync{
    static func sync(){
        print("FirSync sync")
        //update/create fehlender Meditationen und Kurse in Firebase
        for meditation in Meditation.getNotInFirebase()     { FirMeditations.update(meditation: meditation) }
        for kurs in Kurs.getNotInFirebase()                 { FirKurse.update(kurs: kurs) }
        
        FirKurse.sync()
        FirMeditations.sync()
        
        FirUserConnections.setObserver()
    }
}
var deleteDict:NSDictionary{
    return ["deleted":true,"lastSync":Date().timeIntervalSinceReferenceDate]
}
//delete = not really delete --> ["deleted" = true]
class FirKurse{
    private init(){}
    private static var ref:DatabaseReference?{
        guard let appUserID     = AppUser.get()?.firebaseID   else {return nil}
        return database.reference(withPath: "kurse").child(appUserID)
    }
    
    //Einträge in Firebase erzeugen, updaten, "löschen"
    static func update(kurs:Kurs?){
        print("FirKurse update")
        guard let kurs  = kurs, let kursID = kurs.kursID else {return}
        kurs.inFirebase = false
        let ref         = FirKurse.ref?.child(kursID)
        ref?.setValue(kurs.firebaseData) { (error, ref) in if error == nil {kurs.inFirebase = true} }
        updateMeditations(kurs: kurs)
    }
    static private func updateMeditations(kurs:Kurs){
        for meditation in kurs.meditations as? Set<Meditation> ?? Set<Meditation>(){
            FirMeditations.update(meditation: meditation)
        }
    }
    static func deleteKurs(kurs:Kurs){
        guard let kursID    = kurs.kursID  else {return}
        let ref             = FirKurse.ref?.child(kursID)
        ref?.setValue( deleteDict )
        deleteMeditations(kurs: kurs)
    }
    static private func deleteMeditations(kurs:Kurs){
        for meditation in kurs.meditations as? Set<Meditation> ?? Set<Meditation>(){
            FirMeditations.deleteMeditation(meditation: meditation)
        }
    }
    //sync für alles seit letztem SyncDate
    //dann Observer für alles, was nach AppStart geschieht
    static private var appSync:TimeInterval{
        return AppConfig.get()?.firMedLastSync?.timeIntervalSinceReferenceDate ?? Date(timeIntervalSince1970: 0).timeIntervalSinceReferenceDate
    }
    static func sync(){
        print("FirKurse sync \(String(describing: ref))")
        ref?.removeAllObservers()
        ref?.queryOrdered(byChild: "lastSync").queryStarting(atValue: appSync).observe(.childAdded) { (snapshot) in
            createOrUpdate(snapshot: snapshot)
        }
        ref?.queryOrdered(byChild: "lastSync").queryStarting(atValue: appSync).observe(.childChanged) { (snapshot) in
            createOrUpdate(snapshot: snapshot)
        }
    }
    static private func createOrUpdate(snapshot:DataSnapshot?){
        print("FirKurse createOrUpdate")
        Kurs.createOrUpdate(withChild: snapshot)
        let lastSync    = snapshot?.valueAsDict?["lastSync"] as? TimeInterval ?? 0
        if lastSync > appSync{
            AppConfig.get()?.firKursLastSync = Date(timeIntervalSinceReferenceDate: lastSync)
            print("syncData Kurs: \(String(describing: AppConfig.get()?.firKursLastSync?.string("HH:mm:ss.SSSS")))")
        }
    }
}

class FirMeditations{
    private init(){}
    static private var ref:DatabaseReference?{
        guard let appUserID     = AppUser.get()?.firebaseID   else {return nil}
        return database.reference(withPath: "meditations").child(appUserID)
    }
    
    //Einträge in Firebase erzeugen, updaten, "löschen"
    static func update(meditation:Meditation?){
        print("FirKurse update")
        guard let meditation    = meditation, let medID = meditation.meditationsID else {return}
        let ref                 = FirMeditations.ref?.child(medID)
        meditation.inFirebase   = false
        ref?.setValue(meditation.firebaseData) { (error, ref) in if error == nil {meditation.inFirebase = true} }
    }
    static func deleteMeditation(meditation:Meditation?){
        guard let medID = meditation?.meditationsID  else {return}
        let ref                 = FirMeditations.ref?.child(medID)
        ref?.setValue( deleteDict )
    }
    
    //sync für alles seit letztem SyncDate
    //dann Observer für alles, was nach AppStart geschieht
    static private var appSync:TimeInterval{
        return AppConfig.get()?.firMedLastSync?.timeIntervalSinceReferenceDate ?? Date(timeIntervalSince1970: 0).timeIntervalSinceReferenceDate
    }
    static func sync(){
        print("FirMeditations sync")
        ref?.removeAllObservers()
        ref?.queryOrdered(byChild: "lastSync").queryStarting(atValue: appSync).observe(.childAdded) { (snapshot) in
            createOrUpdate(snap: snapshot)
        }
        ref?.queryOrdered(byChild: "lastSync").queryStarting(atValue: appSync).observe(.childChanged) { (snapshot) in
            createOrUpdate(snap: snapshot)
        }
    }

    static private func createOrUpdate(snap:DataSnapshot?){
        print("FirMeditations createOrUpdate \(String(describing: snap))")
        Meditation.createOrUpdateMeditation(withChild: snap)
        let lastSync    = snap?.valueAsDict?["lastSync"] as? TimeInterval ?? 0
        if lastSync > appSync{
            AppConfig.get()?.firMedLastSync = Date(timeIntervalSinceReferenceDate: lastSync)
            print("syncData Meditation: \(String(describing: AppConfig.get()?.firMedLastSync?.string("HH:mm:ss.SSSS")))")
        }
    }
}


class FirUserConnections{
    private init(){}
    
    static func setObserver(){
        print("FirUserConnections setObserver")
        guard let appUserID    = AppUser.get()?.firebaseID   else {return}
        let ref                 = database.reference(withPath: "userConnections").child(appUserID)
        ref.removeAllObservers()
        
        //Add
        ref.observe(.childAdded, with: { (snapshot) in
            //meine Anfragen
            print("userConnection.childAdded:\(snapshot)")
            _ = Freund.createOrUpdateFreund(with: snapshot)
            Singleton.sharedInstance.freundesAnfragenEreignis?()
            Singleton.sharedInstance.freundEreignis?()
        })
        //Changed
        ref.observe(.childChanged, with: { (snapshot) in
            //meine Anfragen
            print("userConnection.childChanged:\(snapshot)")
            _ = Freund.createOrUpdateFreund(with: snapshot)
            Singleton.sharedInstance.freundesAnfragenEreignis?()
            Singleton.sharedInstance.freundEreignis?()
        })
        //Removed
        ref.observe(.childRemoved, with: { (snapshot) in
            //meine Anfragen
            print("userConnection.childRemoved:\(snapshot)")
            _ = Freund.deleteFreund(with: snapshot)
            Singleton.sharedInstance.freundesAnfragenEreignis?()
            Singleton.sharedInstance.freundEreignis?()
        })
    }
    
    static func setFreundschaftsstatus(withUserID userID:String?,userStatus:Int16?,meinStatus:Int16?){
        print("FirUserConnections setFreundschaftsstatus")
        guard let appUserID     = AppUser.get()?.firebaseID , let userID = userID  else {return}
        
        //mein Eintrag
        let ref1                = database.reference(withPath: "userConnections").child(appUserID).child(userID)
        ref1.observeSingleEvent(of: .value, with: { (snapshot) in if snapshot.exists()    {
            var update:[String:Any]{
                var _value = [String:Any]()
                if let userStatus = userStatus {_value["statusUser"] = userStatus}
                if let meinStatus = meinStatus {_value["statusSelf"] = meinStatus}
                
                return _value
            }
            ref1.updateChildValues(update)
            }
        })
        //eintrag des Freundes
        let ref2                = database.reference(withPath: "userConnections").child(userID).child(appUserID)
        ref2.observeSingleEvent(of: .value, with: { (snapshot) in if snapshot.exists()    {
            var update:[String:Any]{
                var _value = [String:Any]()
                if let userStatus = userStatus {_value["statusSelf"] = userStatus}
                if let meinStatus = meinStatus {_value["statusUser"] = meinStatus}
                return _value
            }
            ref2.updateChildValues(update) }
        })
    }
    
    
    
    //Fehler!!!!
    //
    static func createFreundesanfrage(withUserDict userDict:NSDictionary?){
        print("FirUserConnections createFreundesanfrage")
        //Freundschaftsanfrage
        guard let userID = userDict?["ID"] as? String,
            let appUserID    = AppUser.get()?.firebaseID ,
            let freundNick = userDict?["spitzname"] else {return}
        
        var userConnectionMe:[String:Any]{
            return [ userID: [   "statusSelf":FreundesStatus.granted,
                                 "statusUser":FreundesStatus.requested,
                                 "freundNick": freundNick    ] ]
        }
        var userConnectionFreund:[String:Any]{
            return [  appUserID:[   "statusSelf":FreundesStatus.requested,
                                    "statusUser":FreundesStatus.granted,
                                    "freundNick":Meditierender.get()?.nickName ?? "_fehlt_" ] ]
        }
        
        let ref             = database.reference(withPath: "userConnections")
        ref.child(appUserID).updateChildValues(userConnectionMe)
        ref.child(userID).updateChildValues(userConnectionFreund)
    }
    
    static func deleteUserConnection(withUserID userID:String?){
        print("FirUserConnections deleteUserConnection")
        guard let appUserID     = AppUser.get()?.firebaseID , let userID = userID  else {return}
        //mein Eintrag
        let ref1                = database.reference(withPath: "userConnections").child(appUserID).child(userID)
        ref1.removeValue()
        //eintrag des Freundes
        let ref2                = database.reference(withPath: "userConnections").child(userID).child(appUserID)
        ref2.removeValue()
    }
    
    static func setMyNewNickName(){
        print("setMyNewNickName")
        guard let appUserID     = AppUser.get()?.firebaseID   else {return}
        for freund in Freund.getAll(){
            if let userID = freund.freundID {
                let ref             = database.reference(withPath: "userConnections").child(userID).child(appUserID)
                ref.updateChildValues(["freundNick":Meditierender.get()?.nickName ?? "_fehlt_"])
            }
        }
    }
}

class FirActiveMeditations{
    static func setObserver(){
        let ref         = database.reference(withPath: "activeMeditations")
        fireBaseModel.aktuelleMeditationen.value = [PublicMeditation]()
        
        ref.observe(.childAdded, with: { (snapshot) in
            fireBaseModel.addMeditation(snapshot: snapshot)
        })
        ref.observe(.childRemoved, with: { (snapshot) in
            fireBaseModel.removeMeditation(snapshot: snapshot)
        })
        ref.observe(.childChanged, with: { (snapshot) in
            fireBaseModel.updateMeditation(snapshot: snapshot)
        })
    }
    
    
    static func removeObserver(){
        let ref         = database.reference(withPath: "activeMeditations")
        ref.removeAllObservers()
    }
    
    
    static func cleaningActiveMeditations(){
        print("cleaningActiveMeditations ....")
        //löscht alle aktiven Meditationen, die bereits länger als 5h existieren
        
        let timestamp   = String(Date().timeIntervalSinceReferenceDate - 5*60*60)
        let ref         = database.reference(withPath: "activeMeditations")
        ref.queryOrdered(byChild: "start").queryEnding(atValue: timestamp ).observeSingleEvent(of: .value){ snapshot in
            guard let ids = (snapshot.valueAsDict?.allKeys as? Array<String> ) else {return}
            for id in ids{
                print("is string:\(id)")
                ref.child(id).removeValue()
            }
        }
    }
    
    
    
    static func createActiveMeditation(meditation:Meditation?) {
        guard let userID    = AppUser.get()?.firebaseID , let meditation = meditation  else {return}
        let firebaseData    = meditation.firebasePublicMeditation
        let ref             = database.reference(withPath: "activeMeditations")
        ref.child(userID).setValue(firebaseData)
    }
    static func deleteActiveMeditation(){
        print("deleteActiveMeditation ...1")
        guard let userID    = AppUser.get()?.firebaseID   else {return}
        let ref             = database.reference(withPath: "activeMeditations").child(userID)
        ref.removeValue()
    }
}


class ActiveMeditationInFB:Hashable{
    var meditationID:   String?
    var start:          Date?
    var gesamtDauer:    TimeInterval
    var mettaOpenEnd:   Bool
    
    
    var userID:String?
    var meditierenderSpitzname:String?
    var nickNameSichtbarkeit:Int16
    var statistikSichtbarkeit:Int16
    var durchSchnittProTag:String?
    var gesamtDauerStatistik:String?
    var kursTage:String?
    
    //new
    var anapanaDauer:TimeInterval
    var vipassanaDauer:TimeInterval
    var mettaDauer:TimeInterval
    
    
    
    var hashValue: Int{
        return "\(String(describing: meditationID)),\(String(describing: start)),\(gesamtDauer),\(mettaOpenEnd),\(String(describing: meditierenderSpitzname)),\(String(describing: durchSchnittProTag)),\(String(describing: gesamtDauerStatistik)),\(String(describing: kursTage)),\(String(describing: ende)),\(spitznameString)ActiveMeditationInFB".hash
    }
    static func == (lhs: ActiveMeditationInFB, rhs: ActiveMeditationInFB) -> Bool { return lhs.hashValue == rhs.hashValue }
    
    
    
    
    
    
    
    
    
    var canAskForFriendShip:Bool{
        print("freundesStatus \(String(describing: freundesStatus))")
        return nickNameSichtbarkeit == 2 && freundesStatus == nil && !isMyOwnMeditation && Meditierender.get()?.nickName != nil
    }
    var freundesStatus:FreundStatus?{
        guard let freund = Freund.get(withUserID: userID) else {return nil}
        return FreundStatus.getStatus(freund.freundStatus)
    }
    private var isMyOwnMeditation:Bool{
        return AppUser.get()?.firebaseID  == userID
    }
    
    func askForFriendship()->Bool{
        guard let userID = userID ,let spitzName =  meditierenderSpitzname else {return false}
        FirUserConnections.createFreundesanfrage(withUserDict: ["ID":userID,"spitzname":spitzName])
        return true
    }
    
//    var itsMySelf:Bool{ return appUser.name == meditierenderSpitzname }
    
    
    
    
    var ende:Date?               { return start == nil ? nil : start!.addingTimeInterval(gesamtDauer) }
    var spitznameString:String{
        guard let nickName = meditierenderSpitzname, !nickName.isEmpty else {return "?"}
        return nickName
    }
    
    init(meditation:Meditation){
        start                       = meditation.start! as Date
        meditationID                = meditation.meditationsID
        gesamtDauer                 = meditation.gesamtDauer
        mettaOpenEnd                = meditation.mettaOpenEnd
        
        let meditierender           = Meditierender.get()
        let statistics              = Statistics.get()
        
        meditierenderSpitzname      = meditierender?.nickName
        durchSchnittProTag          = statistics.durchschnittTag.hhmmString
        gesamtDauerStatistik        = statistics.gesamtDauer.hhmmString
        kursTage                    = "\(statistics.kursTage ?? 0)"
        nickNameSichtbarkeit        = meditierender?.nickNameSichtbarkeit ?? 0
        statistikSichtbarkeit       = meditierender?.statistikSichtbarkeit ?? 0
        userID                      = AppUser.get()?.firebaseID
        
        
        anapanaDauer                = TimeInterval(meditation.dauerAnapana)
        vipassanaDauer              = TimeInterval(meditation.dauerVipassana)
        mettaDauer                  = TimeInterval(meditation.dauerMetta)
        
    }
    
    
    
    init(snapshot:DataSnapshot){
        let value = snapshot.value as? NSDictionary
        
        userID                      = snapshot.key
        start                       = Date(timeIntervalSinceReferenceDate: (TimeInterval(value?["start"] as? String ?? "" ) ?? 0))
        meditationID                = value?["meditationsID"] as? String
        gesamtDauer                 = value?["gesamtDauer"] as? TimeInterval ?? 0
        mettaOpenEnd                = value?["mettaOpenEnd"] as? Bool ?? false
        
        nickNameSichtbarkeit        = value?["nickNameSichtbarkeit"] as? Int16 ?? 0
        statistikSichtbarkeit       = value?["statistikSichtbarkeit"] as? Int16 ?? 0
        if nickNameSichtbarkeit == 2    {  meditierenderSpitzname      = value?["meditierenderSpitzname"] as? String }
        if statistikSichtbarkeit == 1   {
            durchSchnittProTag          = value?["durchSchnittProTag"] as? String
            gesamtDauerStatistik        = value?["gesamtDauerStatistik"] as? String
            kursTage                    = value?["kursTage"] as? String
        }
        
        anapanaDauer                = 0//TimeInterval(meditation.dauerAnapana)
        vipassanaDauer              = gesamtDauer//TimeInterval(meditation.dauerVipassana)
        mettaDauer                  = 0//TimeInterval(meditation.dauerMetta)
    }
    
    
    
    
    
//    var firebaseData:[String:Any] {
//        return ["start": String(start?.timeIntervalSinceReferenceDate ?? 0),
//                "meditationsID" : meditationID ?? "",
//                "gesamtDauer" : gesamtDauer,
//                "anapanaDauer" : anapanaDauer,
//                "mettaDauer" : mettaDauer,
//                "mettaOpenEnd" : mettaOpenEnd,
//                "meditierenderSpitzname" : meditierenderSpitzname ?? "",
//                "durchSchnittProTag" : durchSchnittProTag ?? "0",
//                "gesamtDauerStatistik" : gesamtDauerStatistik ?? "0",
//                "kursTage" : kursTage ?? "0",
//                "nickNameSichtbarkeit":nickNameSichtbarkeit,
//                "statistikSichtbarkeit":statistikSichtbarkeit]
//    }
}

class FirUser{
    private init(){}
    static func updateUserEintrag() {
        print("updateUserEintrag")
        guard let appUser = AppUser.get(), let userID    = AppUser.get()?.firebaseID  else {return}
        let userRef         = database.reference(withPath: "users")
        userRef.child(userID).setValue(appUser.firebaseData)
        
        
        //erstellt neue Usereinträge (mit uid als key)
        guard let authUID = Auth.auth().currentUser?.uid else {return}
        let userNewVersionRef   =  database.reference(withPath: "usersNewVersion").child(authUID)
        userNewVersionRef.setValue(true)
    }
    
    static func getUser(byUserID userID:String){
        let userRef         = database.reference(withPath: "users").child(userID)
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
        })
        {error in print(error.localizedDescription) }
    }
    
    //old
    static func getUser(byNickname nickname:String){
        print("getUser")
        let userRef         = database.reference(withPath: "users")
        userRef.queryOrdered(byChild: "querySpitzname").queryEqual(toValue: nickname.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
            var filteredSnapshot:DataSnapshot?{
                //filter self
                let key = snapshot.firstKey
                if key == AppUser.get()?.firebaseID  {return nil}
                //filter Freunde
                for freund in Freund.getAll(){
                    if let value = snapshot.firstValue,
                        freund.freundID == value["ID"] as? String || freund.freundID == value["ID"] as? String{
                        return nil
                    }
                }
                return snapshot
            }
            Singleton.sharedInstance.gefundenerUser = filteredSnapshot?.firstValue
        })
        {error in print(error.localizedDescription) }
    }
    //new
    static func getUser(byNickname nickname:String,userSuchErgebnis:MutableProperty<UserSuchErgebnis>?){
        print("getUser")
        let userRef         = database.reference(withPath: "users")
        userRef.queryOrdered(byChild: "querySpitzname").queryEqual(toValue: nickname.lowercased()).observeSingleEvent(of: .value, with: { (snapshot) in
            var filteredSnapshot:DataSnapshot?{
                //filter self
                let key = snapshot.firstKey
                if key == AppUser.get()?.firebaseID  {return nil}
                //filter Freunde
                for freund in Freund.getAll(){
                    if let value = snapshot.firstValue,
                        freund.freundID == value["ID"] as? String || freund.freundID == value["ID"] as? String{
                        return nil
                    }
                }
                return snapshot
            }
            userSuchErgebnis?.value = filteredSnapshot?.firstValue == nil ? UserSuchErgebnis.nichtGefunden : UserSuchErgebnis.gefunden
        })
        {error in
            print(error.localizedDescription)
            userSuchErgebnis?.value = UserSuchErgebnis.Fehler
        }
    }
    
    
    
    static func observeMyUserData(){
        print("observeMyUserData")
        guard let userID        = AppUser.get()?.firebaseID  else {return}
        let myUserRef           = database.reference(withPath: "users").child(userID)
        myUserRef.removeAllObservers()
        
        myUserRef.observe(.childAdded)      { (snapshot) in updateMeditierender(snapshot: snapshot) }
        myUserRef.observe(.childChanged)    { (snapshot) in updateMeditierender(snapshot: snapshot) }
        
        //aktualisiert Werte des CoreData Users
        func updateMeditierender(snapshot:DataSnapshot){
            AppUser.get()?.userDatenInitialSync = true
            if snapshot.key == "spitzname", let value = snapshot.value as? String, Meditierender.get()?.nickName != value {
                Meditierender.get()?.nickName = value != "_fehlt_" ? value : nil
                FirUserConnections.setMyNewNickName()
            }
            if snapshot.key == "spitzname_sichtbarkeit" {Meditierender.get()?.nickNameSichtbarkeit = snapshot.value as? Int16 ?? 0}
            if snapshot.key == "statistik_sichtbarkeit" {Meditierender.get()?.statistikSichtbarkeit = snapshot.value as? Int16 ?? 0}
            if snapshot.key == "statisticStart" {
                guard let value   = snapshot.value as? TimeInterval else {return}
                let date    = value == 0 ? nil : Date (timeIntervalSinceReferenceDate: value)
                AppConfig.get()?.startDatumStatistik =  date
            }
        }
    }
}


//1) IST FIREBASEID GESETZT?
// nein:    hole/erzeuge FirebaseID aus CloudKit --> 2
// ja:      --> 2

// firbaseID ist vorhanden
//2) IST AUTH.EMAIL == FIREBASEID.email.de
// nein:    signIn mit firebaseID --> 3
// ja:      --> 3)

// User ist angemeldet
//3) STARTE OBSERVER
class FirebaseStart{
    //needed: CoreDataObjekt AppUser mit firebaseID
    private init(){}
    
    static var appUser:AppUser?         { return AppUser.get()}
    static var firebaseID: String?      { return appUser?.firebaseID }
    static var email:String?            { return firebaseID == nil ? nil : "\(firebaseID!)@email.de" }
    static var password:String?         { return firebaseID }
    
    static func start(){ authentifizierungStarten() }
    
    //1) IST FIREBASEID GESETZT?
    // nein:    hole/erzeuge FirebaseID aus CloudKit --> 2
    // ja:      --> 2
    static private func authentifizierungStarten(){
        print("authenticate")
        //1) ist firebaseID gesetzt?
        if firebaseID == nil{
            print("authenticate firebaseID: \(String(describing: firebaseID))")
            // nein:    hole/erzeuge FirebaseID aus CloudKit --> 2
            CloudKitHelper.getFirebaseIDAsync() { (firebaseID, error) in
                if firebaseID  != nil           { authToFirebase() }
                else                            { print("keine FirebaseID in CloudKit gefunden/erzeugt") }
            }
        }
            // ja:      --> 2
        else { authToFirebase() }
    }
    
    //2)  IST AUTH.EMAIL == FIREBASEID.email.de
    // firbaseID ist vorhanden (wegen 1)
    // nein:    signIn mit firebaseID --> 3
    // ja:      --> 3)
    static private func authToFirebase(){
        print("authToFirebase")
        // ist Auth.email == firbaseID ?
        guard Auth.auth().currentUser?.email != email
            // ja (Auth.email == firbaseID):      --> 3)
            // User ist bereits angemeldet mit der richtigen EMail
            else { startObserver(); return }
        
        // nein:    signIn mit firebaseID --> 3
        guard let email = email, let password = password else {return}
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error{
                //Falls noch kein User vorhanden --> neuen anlegen (wird gleich eingelogt)
                if error._code == AuthErrorCode.userNotFound.rawValue { createFirebaseUser() }
                return
            }else{
                print("Auth.auth().signIn(withEmail: \(email), password: \(password))")
                startObserver()
            }
        }
    }
    static private func createFirebaseUser(){
        guard let email = email, let password = password else {return}
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error    { print ("createFirebaseUser Fehler \(error.localizedDescription)")  }
            else                    {
                startObserver()
                print ("createFirebaseUser erfolgreich")
            }
        }
    }
    
    //3) STARTE OBSERVER: Anmeldungsereignisse bei Firebase
    //wenn erfolgreiche Anmeldung
    //--> UserEintrag in FB aktualisieren
    //--> Änderungen des CoreData Users observieren
    //--> Synchronisierung (Kurse,Meditationen,UserConnections) starten
    static private func startObserver(){
        print("startObserver")
        //Authentifizierungsereignisse
        if let listener = Singleton.sharedInstance.addStateDidChangeListener { Auth.auth().removeStateDidChangeListener(listener) }
        Singleton.sharedInstance.addStateDidChangeListener = Auth.auth().addStateDidChangeListener{ (auth, user) in
            print("user angemeldet:\(String(describing: user?.email)) auth:\(String(describing: auth.currentUser))")
            if auth.currentUser?.email != nil{
                if Meditierender.get()?.nickName != nil     { appUser?.userDatenInitialSync = true }    // Falls keine Neuinstallation und User mit Nickname : userDatenInitialSync = true
                if appUser?.userDatenInitialSync == true    { FirUser.updateUserEintrag() }
                FirUser.observeMyUserData()
                FirSync.sync()
            }
        }
    }
}

class CloudKitHelper{
    static func getFirebaseIDAsync(complete: @escaping (_ firebasID: String?, _ error: NSError?) -> ()) {
        print ("getFirebaseIDAsync")
        guard let appUser = AppUser.get()else {return}
        
        let database = CKContainer.default().privateCloudDatabase
        
        
        
        
        let predicate   = NSPredicate(value:true)
        let query       = CKQuery(recordType: "FirbaseID", predicate: predicate)
        
        func createRecord(){
            let record:CKRecord = {
                let firebaseID          = UUID().uuidString
                let recordID            = CKRecordID(recordName: firebaseID)
                let record              = CKRecord(recordType: "FirbaseID", recordID: recordID)
                record["firebaseID"]    = firebaseID as CKRecordValue?
                return record
            }()
            
            database.save(record) { (savedRecord, error) in
                if error != nil {
                    print(error as Any)
                    complete(nil,error! as NSError)
                }
                else{
                    guard let firebaseID = record["firebaseID"] as? String else{return}
                    print("success firebaseID: \(firebaseID)")
                    appUser.firebaseID = firebaseID
                    complete(appUser.firebaseID,nil)
                }
            }
        }
        
        database.perform(query, inZoneWith: nil) { (results, error) in
            print ("getFirebaseIDAsync perform query")
            if error != nil {
                complete(nil,error! as NSError)
                print("Fehler activeMeditations: \(error!.localizedDescription)") }
            else {
                // wenn results.count == 0
                // kein Eintrag in CloudKit vorhanden
                // saveRecord() --> Erfolg  : complete(firebaseID,nil)
                if results == nil || results?.count == 0{
                    createRecord()
                    return
                }
                print("ID aus CloudKit: \(String(describing: results?.first?["firebaseID"]))")
                guard let firebaseID    = results?.first?["firebaseID"] as? String  else {return}
                appUser.firebaseID      = firebaseID
                complete(firebaseID,nil)
            }
        }
    }
}

