//
//  FirebaseStart.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Firebase
import CloudKit

//1) IST FIREBASEID GESETZT?
// nein:    hole/erzeuge FirebaseID aus CloudKit --> 2
// ja:      --> 2

// firbaseID ist vorhanden
//2) IST AUTH.EMAIL == FIREBASEID.email.de
// nein:    signIn mit firebaseID --> 3
// ja:      --> 3)

// User ist angemeldet
//3) STARTE OBSERVER

fileprivate var addStateDidChangeListener:AuthStateDidChangeListenerHandle?
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
        if let listener             = addStateDidChangeListener             { Auth.auth().removeStateDidChangeListener(listener) }
        addStateDidChangeListener   = Auth.auth().addStateDidChangeListener { (auth, user) in
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


//in CloudKit wird lediglich eine ID für Firebase abgelegt
// dadurch muss ein bei CloudKit angemeledeter Nutzer keinen User für Firebase anlegen
class CloudKitHelper{
    static func getFirebaseIDAsync(complete: @escaping (_ firebasID: String?, _ error: NSError?) -> ()) {
        print ("getFirebaseIDAsync")
        guard let appUser = AppUser.get()else {return}
        let database        = CKContainer.default().privateCloudDatabase
        let predicate       = NSPredicate(value:true)
        let query           = CKQuery(recordType: "FirbaseID", predicate: predicate)
        
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


