//
//  GeradeMeditiertViewModel.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 28.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift

//✅
class GeradeMeditiertViewModel{
    var aktuelleMeditationen    = MutableProperty([PublicMeditation]())
    let tappedMeditationsPlatz  = MutableProperty<PublicMeditation?>(nil)
    init(tappedMeditationsPlatz:MutableProperty<PublicMeditation?>,aktuelleMeditationen:MutableProperty<[PublicMeditation]>){
        tappedMeditationsPlatz      <~ self.tappedMeditationsPlatz.signal
        self.aktuelleMeditationen   <~ aktuelleMeditationen.producer
    }
    
    //CollectionView DataSource
    private let minmalProzeile  = 3
    private let maximalProZeile = 5
    var numberOfItems:Int{return aktuelleMeditationen.value.count}
    var anzahlProZeile:CGFloat {
        let wurzel      = sqrt(Double(numberOfItems))
        let toAdd:Int   = ((wurzel - Double(Int(wurzel))) == 0) ? 0 :  1
        let anzahl      = Int(wurzel) + toAdd
        return CGFloat(anzahl < minmalProzeile ? minmalProzeile : anzahl > maximalProZeile ? maximalProZeile : anzahl)
    }
    
    
    //CollectionView Delegate Action
    func sitzPlatzTapped(at indexPath:IndexPath){ tappedMeditationsPlatz.value = aktuelleMeditationen.value[indexPath.row] }
    
    //ViewModels
    func getViewModelForCell(indexPath:IndexPath) -> MeditationsPlatzViewModel{ return MeditationsPlatzViewModel(publicMeditation: aktuelleMeditationen.value[indexPath.row]) }
    
    deinit { print("deinit GeradeMeditiertViewModel") }
}
