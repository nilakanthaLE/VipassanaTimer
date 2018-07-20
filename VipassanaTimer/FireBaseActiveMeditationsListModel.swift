//
//  FireBaseActiveMeditationsListModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 17.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift
import Firebase

//✅
//FireBaseActiveMeditationsListModel
// observiert aktive Meditationen in Firebase
// erstellt Liste der aktuell Meditierenden
class FireBaseActiveMeditationsListModel{
    //Liste der aktuellen Meditationen
    let aktuelleMeditationen    = MutableProperty<[PublicMeditation]>([PublicMeditation]())
    
    //eine eigene Meditation starten oder beenden
    let myMeditation = MutableProperty<PublicMeditation?>(nil)
    private func updateMyMeditation(myMeditation:PublicMeditation?){
        if myMeditation == nil{
            guard let index = (aktuelleMeditationen.value.enumerated().filter{$0.element.meditator.itsMySelf}).first?.offset else {return}
            aktuelleMeditationen.value.remove(at: index)
        }
        else{  aktuelleMeditationen.value.append(myMeditation!)  }
    }
    
    //Firebase Aktivität
    // Liste aktualisieren gemäß Firebase/activeMeditations
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
    
    
    //Prüfung auf unplausible PublicMeditations alle 60 s
    // entfernt alle unplausiblen Meditationen aus der Liste der gerade Meditierenden
    private let ticker = SignalProducer.timer(interval: DispatchTimeInterval.seconds(60), on: QueueScheduler.main)
    @objc private func cleanAktuelleMeditationen(){
        print("clean")
        let indices = aktuelleMeditationen.value.enumerated().filter{!$0.element.isPlausible}.map{$0.offset}
        for index in indices{ aktuelleMeditationen.value.remove(at: index) }
    }
    
    //init
    init()  {
        setObserver()
        ticker.start(){ [weak self] _ in self?.cleanAktuelleMeditationen() }
        myMeditation.signal.observeValues{[weak self] _myMeditation in self?.updateMyMeditation(myMeditation: _myMeditation) }
        print("init FireBaseActiveMeditationsListModel") }
    deinit  {
        FirActiveMeditations.deleteActiveMeditation()
        removeObserver()
        print("deinit FireBaseActiveMeditationsListModel")
    }
    
    //Firebase Observer
    private func setObserver(){
        let ref         = database.reference(withPath: "activeMeditations")
        aktuelleMeditationen.value = [PublicMeditation]()
        
        ref.observe(.childAdded, with:      { [weak self] snapshot in self?.addMeditation(snapshot: snapshot) })
        ref.observe(.childRemoved, with:    { [weak self] (snapshot) in self?.removeMeditation(snapshot: snapshot) })
        ref.observe(.childChanged, with:    { [weak self] (snapshot) in self?.updateMeditation(snapshot: snapshot) })
    }
    private func removeObserver(){
        let ref         = database.reference(withPath: "activeMeditations")
        ref.removeAllObservers()
    }
    
    //helper
    private func insertSorted(meditation:PublicMeditation){
        let index = aktuelleMeditationen.value.index { (iMeditation) -> Bool in  return iMeditation.startDate.timeIntervalSince1970 > meditation.startDate.timeIntervalSince1970 }
        aktuelleMeditationen.value.insert(meditation, at: index ?? aktuelleMeditationen.value.count)
    }
}
