//
//  PublicUser.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 17.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Firebase

//✅
//User für Firebase
// Information wird über publicMeditation mitgeschickt
class PublicUser{
    var name: String?
    var meditationsPlatzTitle: String
    var flagge: String
    let nickNameSichtbar: Bool
    let userID:String?
    let itsMySelf:Bool
    let flaggeIstSichtbar:Bool
    let message:String?
    
    // von Firebase kommend
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
    
    // selbst (aktueller User)
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
