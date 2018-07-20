//
//  AufklappHauptMenuButton.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 28.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
class AufklappHauptMenuButtonViewModel{
    let buttonHeight:CGFloat
    let isAufgeklappt   = MutableProperty<Bool>(false)
    let klappAction     = MutableProperty<Void>(Void())
    let pressedButton   = MutableProperty<SubmenuButtonTyp>(.freunde)
    let badgeCount      = MutableProperty<Int>(0)
    init(hoehe:CGFloat,pressed:MutableProperty<SubmenuButtonTyp>,badgeCount:MutableProperty<Int>){
        //in
        buttonHeight =  hoehe
        self.badgeCount <~ badgeCount.producer
        
        //out
        pressed <~ pressedButton.signal
        
        //Aktion
        klappAction.signal.observe{[weak self] _ in self?.klappen()}
    }
    //helper
    private func klappen(){ isAufgeklappt.value = !isAufgeklappt.value }
    
    //ViewModels
    func getViewModelForBadgeButton(typ:SubmenuButtonTyp) -> HauptmenuBadgeButtonViewModel{ return HauptmenuBadgeButtonViewModel(title: typ.title, badgeCount: badgeCount) }
}

//✅
@IBDesignable class AufklappHauptMenuButton:NibLoadingView{
    var viewModel:AufklappHauptMenuButtonViewModel!{
        didSet{
            //Höhe des AufklappButtons setzen
            buttonHeight.constant  = viewModel.buttonHeight
            
            //buttonTitles
            profilButton.setTitle   (SubmenuButtonTyp.profil.title, for: .normal)
            kurseButton.setTitle    (SubmenuButtonTyp.kurse.title, for: .normal)
            danaButton.setTitle     (SubmenuButtonTyp.dana.title, for: .normal)
            
            //viewModels
            freundeButton.viewModel = viewModel.getViewModelForBadgeButton(typ: .freunde)
            klappButton.viewModel   = viewModel.getViewModelForBadgeButton(typ: .klappButton)

            //in
            danaButton.reactive.isHidden    <~ viewModel.isAufgeklappt.map{!$0}
            profilButton.reactive.isHidden  <~ viewModel.isAufgeklappt.map{!$0}
            freundeButton.reactive.isHidden <~ viewModel.isAufgeklappt.map{!$0}
            kurseButton.reactive.isHidden   <~ viewModel.isAufgeklappt.map{!$0}
            
            //out
            viewModel.klappAction           <~ klappButton.buttonPressed.signal.map{_ in Void()}
            viewModel.pressedButton         <~ freundeButton.buttonPressed.signal.map                           { _ in SubmenuButtonTyp.freunde }
            viewModel.pressedButton         <~ kurseButton.reactive.controlEvents(.touchUpInside).signal.map    { _ in SubmenuButtonTyp.kurse }
            viewModel.pressedButton         <~ profilButton.reactive.controlEvents(.touchUpInside).signal.map   { _ in SubmenuButtonTyp.profil }
            viewModel.pressedButton         <~ danaButton.reactive.controlEvents(.touchUpInside).signal.map     { _ in SubmenuButtonTyp.dana }
        }
    }
    //IBOutlets
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var danaButton: HauptMenuButton!
    @IBOutlet weak var profilButton: HauptMenuButton!
    @IBOutlet weak var freundeButton: HauptmenuBadgeButton!
    @IBOutlet weak var kurseButton: HauptMenuButton!
    @IBOutlet weak var klappButton: HauptmenuBadgeButton!
}


enum SubmenuButtonTyp{
    case kurse,freunde,profil,klappButton,dana
    var title:String{
        switch self{
            case .kurse:        return "Kurse"
            case .freunde:      return "Freunde"
            case .profil:       return "Mein Profil"
            case .klappButton:  return "..."
            case .dana:         return "dana"
        }
    }
}
