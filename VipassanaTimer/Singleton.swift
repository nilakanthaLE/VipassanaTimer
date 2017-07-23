//
//  Singleton.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import  Firebase

class Singleton {
    static let sharedInstance = Singleton()
    //This prevents others from using the default '()' initializer for this class.
    private init() {
        if FileManager.default.ubiquityIdentityToken != nil {
            print("init Singleton start")
        }
    }
    
    var addStateDidChangeListener:AuthStateDidChangeListenerHandle?
    
    //MARK: UserConnections
    var gefundenerUser : NSDictionary?          {didSet{userWurdeGefunden?()}}
    var userWurdeGefunden:(()->Void)?
    var freundesAnfragenEreignis:(()->Void)?
    var freundEreignis:(()->Void)?
    
    //MARK: ActiveMeditations
    var listOfActiveMeditationHasChanged:(()->Void)?
    var listOfActiveMeditation = [ActiveMeditationInFB](){
        didSet{
            listOfActiveMeditationHasChanged?()
            for am in filteredAndSortedListOfActiveMeditation{
                print(am.firebaseData)
            }
        }
    }
    var filteredAndSortedListOfActiveMeditation : [ActiveMeditationInFB]{
        let ergebnis = listOfActiveMeditation.filter{$0.userID != AppUserFBID}
        return ergebnis.sorted{$0.start?.timeIntervalSinceReferenceDate ?? 0 < $1.start?.timeIntervalSinceReferenceDate ?? 0 }
    }
    
    deinit {  print("deinit Singleton")  }
}

