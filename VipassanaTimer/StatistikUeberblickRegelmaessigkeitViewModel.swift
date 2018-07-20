//
//  StatistikUeberblickRegelmaessigkeitViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 13.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
// Statistik über Regelmäßigkeit der Meditation
// auf Startseite
class StatistikUeberblickRegelmaessigkeitViewModel{
    let gesamtZeitText              = MutableProperty<String?>(nil)
    let gesamtZeitOhneKurseText     = MutableProperty<String?>(nil)
    let einmalAmTagBisHeuteText     = MutableProperty<String?>(nil)
    let einmalAmTagMaxText          = MutableProperty<String?>(nil)
    let zweimalAmTagBisHeuteText    = MutableProperty<String?>(nil)
    let zweiMalAmTagMaxText         = MutableProperty<String?>(nil)
    let kursTageText                = MutableProperty<String?>(nil)
    
    //init
    init(update:MutableProperty<Void>){ update.producer.start(){[weak self] _ in self?.updateData()} }
    
    //helper
    private func updateData(){
        let daten = Statistics.get()
        gesamtZeitText.value            = "\(daten.gesamtDauer.dhh)"
        gesamtZeitOhneKurseText.value   = "\(daten.gesamtDauerOhneKurse.dhh)"
        einmalAmTagBisHeuteText.value   = "\(daten.regelmaessigEinmalAmTag)"
        einmalAmTagMaxText.value        = "\(daten.regelmaessigEinmalAmTagMax)"
        zweimalAmTagBisHeuteText.value  = "\(daten.regelmaessigZweiMalAmTag)"
        zweiMalAmTagMaxText.value       = "\(daten.regelmaessigZweimalAmTagMax)"
        kursTageText.value              = "\(daten.kursTage)"
    }
}
