//
//  ProfilConfigModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift

//✅
// Model für die Konfiguration des eigenen Profils
class ProfilConfigModel{
    let spitzName                           = MutableProperty<String?>(nil)
    let spitznameIstSichtbar                = MutableProperty<Bool> (false)
    let statistikIstSichtbar                = MutableProperty<Bool> (false)
    let meditationsPlatzTitle               = MutableProperty<String?>(nil)
    let flagge                              = MutableProperty<String>("🇮🇳")
    let flaggeIstSichtbar                   = MutableProperty<Bool> (false)
    let message                             = MutableProperty<String?>(nil)
    let userSuchErgebnis = MutableProperty<UserSuchErgebnis>(UserSuchErgebnis.Fehler)
    
    //init
    init(){
        //init set
        spitzName.value                 = Meditierender.get()?.nickName
        spitznameIstSichtbar.value      = Meditierender.get()?.nickNameSichtbarkeit     == 2
        statistikIstSichtbar.value      = Meditierender.get()?.statistikSichtbarkeit    == 1
        meditationsPlatzTitle.value     = Meditierender.get()?.meditationsPlatzTitle ?? "?"
        flaggeIstSichtbar.value         = Meditierender.get()?.flaggeIstSichtbar == true
        message.value                   = Meditierender.get()?.message
        flagge.value                    = ProfilConfigModel.getFlagge()
        
        //user set
        spitznameIstSichtbar.signal.observeValues   { Meditierender.get()?.nickNameSichtbarkeit = $0 ? 2 : 0 }
        statistikIstSichtbar.signal.observeValues   { Meditierender.get()?.statistikSichtbarkeit = $0 ? 1 : 0 }
        meditationsPlatzTitle.signal.observeValues  { Meditierender.get()?.meditationsPlatzTitle = $0 }
        flaggeIstSichtbar.signal.observeValues      { Meditierender.get()?.flaggeIstSichtbar = $0 }
        flagge.signal.observeValues                 { Meditierender.get()?.flagge = $0 }
        message.signal.observeValues                { Meditierender.get()?.message = $0 }
        
        spitzName.signal.filter{$0 != nil}.observeValues {[weak self] nick in FirUser.getUser(byNickname: nick!, userSuchErgebnis: self?.userSuchErgebnis) }
        userSuchErgebnis.signal.filter{$0 == UserSuchErgebnis.nichtGefunden}.observeValues{[weak self] _ in
            guard let strongSelf = self else {return}
            Meditierender.get()?.nickName = strongSelf.spitzName.value
            FirUser.updateUserEintrag()
            saveContext()
        }
        
    }
    
    //helper
    private static func getFlagge() -> String{
        if let _flagge = Meditierender.get()?.flagge        { return _flagge}
        if let countryCode = NSLocale.current.regionCode    { return String(emoji(countryCode: countryCode))}
        return "🇮🇳"
    }
    
    deinit {
        print("deinit ProfilConfigModel")
        saveContext()
    }
}

