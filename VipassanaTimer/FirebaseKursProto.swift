//
//  FirebaseKursProto.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 18.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Firebase
import ReactiveSwift

//✅
//holt die KursProtos aus Firebase
// ermöglicht über Firebase der App neue Kurse hinzuzufügen
class FirebaseKursProto{
    static let ref  = database.reference(withPath: "kursProtos")
    static func insertNew(publicKursProto:PublicKursProto){ ref.child(publicKursProto.kursTitle).setValue(publicKursProto.firebaseData) }
    
    //erster wert von publicKursProtos ist nil
    // für picker!
    static func getList(publicKursProtos:MutableProperty<[PublicKursProto?]>){
        ref.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {return}
            var list =  snapshot.children.map{ PublicKursProto(snapshot: $0 as? DataSnapshot) }
            list.insert(nil, at: 0)
            publicKursProtos.value = list
        }
    }
}

//✅
// Klasse für Prototypen von Kursen (z.B. 10-Tage Kurs)
class PublicKursProto{
    var kursNameD:String
    var kursNameEng:String
    var kursTitle:String
    var days:[MeditationsTag]
    
    //calc Property
    var firebaseData:[String:Any]{
        let array = days.sorted{$0.tag < $1.tag}.map{$0.firebaseData}
        let daysDict = array.reduce([String:Any]()){(ergebnis,value) -> [String:Any] in
            var ergebnis = ergebnis
            let _key = value.keys.first!
            ergebnis[_key] = value[_key]
            return ergebnis
        }
        return ["meditationen":daysDict,"kursNameD":kursNameD,"kursNameEng":kursNameEng]
    }
    
    //init
    init?(snapshot:DataSnapshot?){
        guard let value = snapshot?.value as? NSDictionary else {return nil}
        days            = snapshot?.childSnapshot(forPath: "meditationen").children.map{MeditationsTag(snapshot: $0 as? DataSnapshot)}.compactMap{$0} ?? [MeditationsTag]()
        kursNameD       = value["kursNameD"] as? String ?? "???"
        kursNameEng     = value["kursNameEng"] as? String ?? "???"
        kursTitle       = snapshot!.key
    }
    init(){
        kursNameD       = "10 Tage Kurs"
        kursNameEng     = "10 Day Course"
        kursTitle       = "10day"
        days            = [MeditationsTag]()
    }
}
