//
//  MainModels.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 28.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift


let mainModel   = MainModel()
class MainModel{
    let myActiveMeditation  = MutableProperty<PublicMeditation?>(nil)
    let pauseDates          = MutableProperty<(start:Date?,ende:Date?)>((nil,nil))
    
    let tappedMeditationsPlatz  = MutableProperty<PublicMeditation?>(nil)
    init(){
        myActiveMeditation.producer.startWithValues{
            fireBaseModel.updateMyMeditation(myMeditation: $0)
            coreDataModel.updateMyMeditation(myMeditation: $0)
        }
        
        pauseDates.producer.startWithValues {
            coreDataModel.addPause(start: $0.start, ende: $0.ende)
        }
    }
    
}
