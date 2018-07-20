//
//  SetStatistikAnfangsDatumViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 13.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift

//✅
// ViewModel für die Konfiguration des Startdatums für Statistiken auf der Startseite
class SetStatistikAnfangsDatumViewModel{
    let datumText                   = MutableProperty<String?>(nil)
    let datumPickerDate             = MutableProperty<Date>(Date())
    let zurueckSetzenButtonIsHidden = MutableProperty<Bool>(true)
    let zuruckSetzenButtonPressed   = MutableProperty<Void>(Void())
    
    //init
    init(){
        zurueckSetzenButtonIsHidden.value   = AppConfig.get()?.startDatumStatistik == nil ? true : false
        datumPickerDate.value               = startDate
   
        datumText                   <~ datumPickerDate.producer.map         { $0.string("dd.MM.yyyy") }
        zurueckSetzenButtonIsHidden <~ datumPickerDate.signal.map           { _ in false }
        zurueckSetzenButtonIsHidden <~ zuruckSetzenButtonPressed.signal.map { _ in true }
        
        zuruckSetzenButtonPressed.signal.observeValues      { [weak self] _ in self?.zurueckSetzenAction() }
        datumPickerDate.signal.observeValues                { SetStatistikAnfangsDatumViewModel.pickerDidSet(date: $0) }
    }
    
    //helper
    private var startDate:Date { return  AppConfig.get()?.startDatumStatistik ?? Meditation.getAll().first?.start ?? Date() }
    static private func pickerDidSet(date:Date){
        AppConfig.get()?.startDatumStatistik = date
        FirUser.updateUserEintrag()
    }
    private func zurueckSetzenAction(){
        AppConfig.get()?.startDatumStatistik    = nil
        datumPickerDate.value                   = startDate
    }
    
    deinit {
        saveContext()
        print("deinit SetStatistikAnfangsDatumViewModel")
    }
}
