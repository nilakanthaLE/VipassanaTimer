//
//  FreundeFindenVCModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
// ViewModel für die Suche nach Freunden per nickname
class FreundeFindenVCModel{
    let freundAnfragenButtonIsHidden    = MutableProperty<Bool>(true)
    let freundAnfragenButtonTitel       = MutableProperty<String>("")
    let searchString                    = MutableProperty<String?>(nil)
    
    
    //init
    let gefundenerUserInFirebase        = MutableProperty<NSDictionary?>(nil)
    init(){
        freundAnfragenButtonIsHidden    <~ gefundenerUserInFirebase.signal.map{$0 == nil}
        freundAnfragenButtonTitel       <~ gefundenerUserInFirebase.signal.map{FreundeFindenVCModel.getButtonTitle(for: $0)}
    
        searchString.signal.observeValues{[weak self] suchString in FirUser.getUser(byNickname: suchString,ergebnisSnapshot: self?.gefundenerUserInFirebase ) }
    }
    
    //Action
    func freundschaftAnfragen(){ FirUserConnections.createFreundesanfrage(withUserDict:gefundenerUserInFirebase.value) }
    
    //helper
    static private func getButtonTitle(for dict:NSDictionary?) -> String{
        guard let nickName = dict?["spitzname"] as? String else {return ""}
        return NSLocalizedString("freundesAnfrageSenden1", comment: "freundesAnfrageSenden1") + nickName + NSLocalizedString("freundesAnfrageSenden2", comment: "freundesAnfrageSenden2")
    }
    
    deinit { print ("deinit FreundeFindenVCModel") }
}
