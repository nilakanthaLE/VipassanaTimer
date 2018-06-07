//
//  GeradeMeditiertViewModel.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 28.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

class GeradeMeditiertViewModel{
    var aktuelleMeditationen    = MutableProperty([PublicMeditation]())
    
    let model:GeradeMeditiertModel
    init(model:GeradeMeditiertModel){
        self.model = model
        aktuelleMeditationen <~ model.aktuelleMeditationen.producer 
    }
    
    //CollectionView DataSource
    let minmalProzeile  = 3
    let maximalProZeile = 5
    var anzahlProZeile:CGFloat {
        let wurzel      = sqrt(Double(numberOfItems))
        let toAdd:Int   = ((wurzel - Double(Int(wurzel))) == 0) ? 0 :  1
        let anzahl      = Int(wurzel) + toAdd
        return CGFloat(anzahl < minmalProzeile ? minmalProzeile : anzahl > maximalProZeile ? maximalProZeile : anzahl)}
    var numberOfItems:Int{return aktuelleMeditationen.value.count}
    
    func sitzPlatzTapped(at indexPath:IndexPath){
        mainModel.tappedMeditationsPlatz.value = aktuelleMeditationen.value[indexPath.row]
    }
    
    
    //ViewModels
    func getViewModelForCell(indexPath:IndexPath) -> MeditationsPlatzCellViewModel{
        return MeditationsPlatzCellViewModel(publicMeditation: aktuelleMeditationen.value[indexPath.row])
    }
    
    deinit { print("deinit GeradeMeditiertViewModel") }
}
