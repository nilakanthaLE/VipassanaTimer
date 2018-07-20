//
//  FirebaseNotitifications.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 28.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Firebase

//✅
//Methoden für Einträge von Nachrichten an  User
class FirNotitification{
    static let ref  = database.reference(withPath: "notifications")
    static func setObserver()       { ref.observe(.childAdded, with: { (snapshot) in AppConfig.setNotification(snapshot: snapshot) }) }
    static func new(message:String) { ref.child("1").setValue(message) }
}







