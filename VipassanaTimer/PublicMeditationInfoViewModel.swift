//
//  PublicMeditationInfoViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import Foundation

//✅
// ViewModel für die öffentliche MeditationsAnsicht
class PublicMeditationInfoViewModel{
    let title:String?
    let publicStatistics:PublicStatistics?
    let freundschaftsAnfrageButtonIsHidden:Bool
    
    let flagge:String?
    let message:String?
    let countryName:String?
    
    //init
    let publicMeditation:PublicMeditation
    init(publicMeditation:PublicMeditation){
        self.publicMeditation = publicMeditation
        title               = publicMeditation.meditator.name
        publicStatistics    = publicMeditation.statistics
        freundschaftsAnfrageButtonIsHidden = !publicMeditation.canAskForFriendShip
        flagge              = publicMeditation.meditator.flaggeIstSichtbar ? publicMeditation.meditator.flagge : nil
        message             = publicMeditation.meditator.message
        countryName         = countryNameForFlag(flag: publicMeditation.meditator.flagge)
    }
    
    //viewActions
    func freundSchaftsAnfrageButtonPressed(){ publicMeditation.askForFriendship() }
    
    //ViewModels
    func getViewModelForTimerView() -> TimerInPublicMeditationInfoViewModel { return TimerInPublicMeditationInfoViewModel(model: TimerInPublicMeditationInfoModel(publicMeditation: publicMeditation)) }
    func getViewModelForMeditationsPlatz() -> MeditationsPlatzViewModel     { return MeditationsPlatzViewModel(publicMeditation: publicMeditation) }
}
