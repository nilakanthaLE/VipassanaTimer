//
//  FireBaseModel.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 28.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift
import Firebase

let fireBaseModel = FireBaseModel()
class FireBaseModel{
    //Liste der aktuellen Meditationen
    let aktuelleMeditationen    = MutableProperty<[PublicMeditation]>([PublicMeditation]())

    //eine eigene Meditation wird gestartet oder beendet
    func updateMyMeditation(myMeditation:PublicMeditation?){
        print("updateMyMeditation")
        if myMeditation == nil{
            print("updateMyMeditation remove")
            guard let index = (aktuelleMeditationen.value.enumerated().filter{$0.element.meditator.itsMySelf}).first?.offset else {return}
            aktuelleMeditationen.value.remove(at: index)
        }
        else{
            aktuelleMeditationen.value.append(myMeditation!)
            print("updateMyMeditation add")
        }
    }
    
    var observerFuerListeAktiv:Bool = false{
        willSet{
            switch newValue {
            case true:
                FirActiveMeditations.setObserver()
                startPlausibilitaetPrueferTimer()
            case false:
                stopPlausibilitaetPrueferTimer()
                FirActiveMeditations.removeObserver()
            }
            FirActiveMeditations.deleteActiveMeditation()
        }
    }
    
    
    //Prüfung auf unplausible PublicMeditations alle 60 s
    private var plausibilitaetPrueferTimer:Timer?
    private func startPlausibilitaetPrueferTimer(){
        guard plausibilitaetPrueferTimer == nil else {return}
        plausibilitaetPrueferTimer = Timer.scheduledTimer(timeInterval: 60 , target: self, selector: #selector(cleanAktuelleMeditationen), userInfo: nil, repeats: true)
    }
    private func stopPlausibilitaetPrueferTimer(){
        plausibilitaetPrueferTimer?.invalidate()
        plausibilitaetPrueferTimer = nil
    }
    @objc private func cleanAktuelleMeditationen(){
        let indices = aktuelleMeditationen.value.enumerated().filter{!$0.element.isPlausible}.map{$0.offset}
        for index in indices{ aktuelleMeditationen.value.remove(at: index) }
    }
    
    //Firebase Aktivität
    func addMeditation(snapshot:DataSnapshot){
        let meditation  = PublicMeditation(snapshot: snapshot)
        if !meditation.meditator.itsMySelf && meditation.isPlausible  { insertSorted(meditation: meditation) }
    }
    func removeMeditation(snapshot:DataSnapshot){
        let meditation          = PublicMeditation(snapshot: snapshot)
        guard let index         = aktuelleMeditationen.value.index(of: meditation),!meditation.meditator.itsMySelf  else {return}
        aktuelleMeditationen.value.remove(at: index)
    }
    func updateMeditation(snapshot:DataSnapshot){ }
    
    //helper
    private func insertSorted(meditation:PublicMeditation){
        let index = aktuelleMeditationen.value.index { (iMeditation) -> Bool in  return iMeditation.startDate.timeIntervalSince1970 > meditation.startDate.timeIntervalSince1970 }
        aktuelleMeditationen.value.insert(meditation, at: index ?? aktuelleMeditationen.value.count)
    }
    
    //init
    init()  {
        print("init FireBaseModel")
    }
    deinit  { print("deinit FireBaseModel") }
}
