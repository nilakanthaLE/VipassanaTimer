//
//  ProfilConfigViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 04.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift

//✅
//ViewModel für die Konfiguration des eigenen Profils
class ProfilConfigViewModel{
    //init
    let model:ProfilConfigModel
    init(model:ProfilConfigModel){
        self.model  = model
        spitzNameText                   <~ model.spitzName.producer
        flaggeButtonTitle               <~ model.flagge.producer
        spitznameIstSichtbar            <~ model.spitznameIstSichtbar.producer
        flaggeIstSichtbar               <~ model.flaggeIstSichtbar.producer
        statistikIstSichtbar            <~ model.statistikIstSichtbar.producer
        spitzNameVergebenLabelText      <~ model.userSuchErgebnis.signal.map{[weak self] ergebnis in self?.spitzNameVergebenLabelText(userSuchErgebnis: ergebnis)}
        message                         <~ model.message.producer
    }
    
    let spitzNameText                       = MutableProperty<String?>(nil)
    let spitznameVergebenLabelIsHidden      = MutableProperty<Bool> (true)
    let flaggeButtonTitle                   = MutableProperty<String>("🇮🇳")
    let spitznameIstSichtbar                = MutableProperty<Bool> (false)
    let flaggeIstSichtbar                   = MutableProperty<Bool> (false)
    let statistikIstSichtbar                = MutableProperty<Bool> (false)
    let spitzNameVergebenLabelText          = MutableProperty<String?>(nil)
    let message                             = MutableProperty<String?>(nil)

    //Actions
    let flaggeButtonPressed     = MutableProperty<Void>(Void())
    let meditationsPlatzTapped  = MutableProperty<Void>(Void())
    
    //ViewModel
    func getViewModelForSitzPlatzView() -> MeditationsPlatzViewModel{ return MeditationsPlatzViewModel(meditationsPlatzTitle: model.meditationsPlatzTitle) }
    
    //helper
    func spitzNameVergebenLabelText(userSuchErgebnis:UserSuchErgebnis) -> String{
        let spitzname = spitzNameText.value ?? "???"
        switch userSuchErgebnis{
        case .gefunden:         return  spitzname + NSLocalizedString("NicknameVergeben", comment: "NicknameVergeben")
        case .nichtGefunden:    return spitzname +  NSLocalizedString("NicknameErlaubt", comment: "NicknameErlaubt")
        case .Fehler:           return "Fehler"
        }
        
    }
}

enum UserSuchErgebnis{ case gefunden,nichtGefunden,Fehler }



