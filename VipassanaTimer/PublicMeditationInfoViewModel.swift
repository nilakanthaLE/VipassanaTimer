//
//  PublicMeditationInfoViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation

class PublicMeditationInfoModel{
    let publicMeditation:PublicMeditation
    init(publicMeditation:PublicMeditation){
        self.publicMeditation = publicMeditation
    }
    func getTimerModel() -> TimerInPublicMeditationInfoModel{
        return TimerInPublicMeditationInfoModel(publicMeditation: publicMeditation)
    }
}

class PublicMeditationInfoViewModel{
    let title:String?
    let publicStatistics:PublicStatistics?
    let freundschaftsAnfrageButtonIsHidden:Bool
    let model:PublicMeditationInfoModel
    let flagge:String?
    let message:String?
    let countryName:String?
    init(model:PublicMeditationInfoModel){
        self.model          = model
        title               = model.publicMeditation.meditator.name
        publicStatistics    = model.publicMeditation.statistics
        freundschaftsAnfrageButtonIsHidden = !model.publicMeditation.canAskForFriendShip
        flagge              = model.publicMeditation.meditator.flaggeIstSichtbar ? model.publicMeditation.meditator.flagge : nil
        message             = model.publicMeditation.meditator.message
        countryName         = countryNameForFlag(flag: model.publicMeditation.meditator.flagge)
    }
    
    func getViewModelForTimerView() -> TimerInPublicMeditationInfoViewModel{
        return TimerInPublicMeditationInfoViewModel(model: model.getTimerModel())
    }
    func getViewModelForMeditationsPlatz() -> MeditationsPlatzViewModel{
        return MeditationsPlatzViewModel(publicMeditation: model.publicMeditation)
    }
    func freundSchaftsAnfrageButtonPressed(){ model.publicMeditation.askForFriendship() }
}
