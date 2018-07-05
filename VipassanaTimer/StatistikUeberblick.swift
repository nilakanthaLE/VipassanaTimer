//
//  StatistikUeberblick.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 03.02.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa


class StatistikUeberblick2ViewModel{
    let statistics = MutableProperty<Statistics>(Statistics())
    
    let gesamtZeitText              = MutableProperty<String?>(nil)
    let gesamtZeitOhneKurseText     = MutableProperty<String?>(nil)
    let einmalAmTagBisHeuteText     = MutableProperty<String?>(nil)
    let einmalAmTagMaxText          = MutableProperty<String?>(nil)
    let zweimalAmTagBisHeuteText    = MutableProperty<String?>(nil)
    let zweiMalAmTagMaxText         = MutableProperty<String?>(nil)
    let kursTageText                = MutableProperty<String?>(nil)
    
    init(update:MutableProperty<Void>){
        update.producer.start(){[weak self] _ in self?.updateData()}
    }
    
    private func updateData(){
        let daten = Statistics.get()
        gesamtZeitText.value            = "\(daten.gesamtDauer.dhh)"
        gesamtZeitOhneKurseText.value   = "\(daten.gesamtDauerOhneKurse.dhh)"
        einmalAmTagBisHeuteText.value   = "\(daten.regelmaessigEinmalAmTag)"
        einmalAmTagMaxText.value        = "\(daten.regelmaessigEinmalAmTagMax)"
        zweimalAmTagBisHeuteText.value  = "\(daten.regelmaessigZweiMalAmTag)"
        zweiMalAmTagMaxText.value       = "\(daten.regelmaessigZweimalAmTagMax)"
        kursTageText.value              = "\(daten.kursTage)"
    }
}

class StatistikUeberblick2:NibLoadingView{
    var viewModel:StatistikUeberblick2ViewModel!{
        didSet{
            gesamtZeit.reactive.text                <~ viewModel.gesamtZeitText.producer
            gesamtZeitOhneKurse.reactive.text       <~ viewModel.gesamtZeitOhneKurseText.producer
            einmalAmTagBisHeute.reactive.text       <~ viewModel.einmalAmTagBisHeuteText.producer
            einmalAmTagMax.reactive.text            <~ viewModel.einmalAmTagMaxText.producer
            zweimalAmTagBisHeute.reactive.text      <~ viewModel.zweimalAmTagBisHeuteText.producer
            zweiMalAmTagMax.reactive.text           <~ viewModel.zweiMalAmTagMaxText.producer
            kursTage.reactive.text                  <~ viewModel.kursTageText.producer
            
        }
    }
    @IBOutlet private weak var statistikView: UIView!           { didSet{ statistikView.setControlDesignPatterns() } }
    @IBOutlet private weak var gesamtZeitOhneKurse: UILabel!    //{ didSet{ gesamtZeitOhneKurse.text = "\(daten.gesamtDauerOhneKurse.dhh)"}}
    @IBOutlet private weak var einmalAmTagBisHeute: UILabel!    //{ didSet{ einmalAmTagBisHeute.text = "\(daten.regelmaessigEinmalAmTag)"}}
    @IBOutlet private weak var einmalAmTagMax: UILabel!         //{ didSet{ einmalAmTagMax.text = "\(daten.regelmaessigEinmalAmTagMax)"}}
    @IBOutlet private weak var zweimalAmTagBisHeute: UILabel!   //{ didSet{ zweimalAmTagBisHeute.text = "\(daten.regelmaessigZweiMalAmTag )"}}
    @IBOutlet private weak var zweiMalAmTagMax: UILabel!        //{ didSet{ zweiMalAmTagMax.text = "\(daten.regelmaessigZweimalAmTagMax)"}}
    @IBOutlet private weak var kursTage: UILabel!               //{ didSet{ kursTage.text = "\(daten.kursTage)"}}
    @IBOutlet private weak var gesamtZeit: UILabel!             //{ didSet{ gesamtZeit.text = "\(daten.gesamtDauer.dhh)"}}
}




//class StatistikModel{
//    //Überschrift
//    let gesamt                      = MutableProperty<TimeInterval>(0)
//
//    //1. Block - Gesamt
//    let gesamtAktuellTag            = MutableProperty<TimeInterval>(0)
//    let gesamtAktuellWoche          = MutableProperty<TimeInterval>(0)
//    let gesamtAktuellMonat          = MutableProperty<TimeInterval>(0)
//    let gesamtVorherigTag           = MutableProperty<TimeInterval>(0)
//    let gesamtVorherigWoche         = MutableProperty<TimeInterval>(0)
//    let gesamtVorherigMonat         = MutableProperty<TimeInterval>(0)
//    let gesamtAenderungTag          = MutableProperty<TimeInterval>(0)
//    let gesamtAenderungWoche        = MutableProperty<TimeInterval>(0)
//    let gesamtAenderungMonat        = MutableProperty<TimeInterval>(0)
//
//
//    //2. Block - Durchschnitt
//    let durchschnittTag             = MutableProperty<TimeInterval>(0)
//    let durchSchnittWoche           = MutableProperty<TimeInterval>(0)
//    let durchSchnittMonat           = MutableProperty<TimeInterval>(0)
//    let durchschnittVorherigTag     = MutableProperty<TimeInterval>(0)
//    let durchschnittVorherigWoche   = MutableProperty<TimeInterval>(0)
//    let durchschnittVorherigMonat   = MutableProperty<TimeInterval>(0)
//    let durchschnittAenderungTag    = MutableProperty<TimeInterval>(0)
//    let durchschnittAenderungWoche  = MutableProperty<TimeInterval>(0)
//    let durchschnittAenderungMonat  = MutableProperty<TimeInterval>(0)
//
//
//    init() {
//        let statistics              = MutableProperty<Statistics>(Statistics.get())
//        gesamt                          <~ statistics.producer.map{$0.gesamtDauer}
//
//        //1. Block - Gesamt
//        gesamtAktuellTag                <~ statistics.producer.map{$0.gesamtAktuellTag}
//        gesamtAktuellWoche              <~ statistics.producer.map{$0.gesamtAktuellWoche}
//        gesamtAktuellMonat              <~ statistics.producer.map{$0.gesamtAktuellMonat}
//        gesamtVorherigTag               <~ statistics.producer.map{$0.gesamtVorherigTag}
//        gesamtVorherigWoche             <~ statistics.producer.map{$0.gesamtVorherigWoche}
//        gesamtVorherigMonat             <~ statistics.producer.map{$0.gesamtVorherigMonat}
//
//        //2. Block - Durchschnitt
//        durchschnittTag                 <~ statistics.producer.map{$0.durchschnittTag}
//        durchSchnittWoche               <~ statistics.producer.map{$0.durchschnittWoche}
//        durchSchnittMonat               <~ statistics.producer.map{$0.durchschnittMonat}
//        durchschnittVorherigTag         <~ statistics.producer.map{$0.durchschnittVorherigTag}
//        durchschnittVorherigWoche       <~ statistics.producer.map{$0.durchschnittVorherigWoche}
//        durchschnittVorherigMonat       <~ statistics.producer.map{$0.durchschnittVorherigMonat}
//
//    }
//}
//
//class StatistikUeberblickViewModel{
//
//
//    //Überschrift
//    let gesamt                      = MutableProperty<String?>(nil)
//
//    //1. Block - Gesamt
//    let gesamtAktuellTag            = MutableProperty<String?>(nil)
//    let gesamtAktuellWoche          = MutableProperty<String?>(nil)
//    let gesamtAktuellMonat          = MutableProperty<String?>(nil)
//    let gesamtVorherigTag           = MutableProperty<String?>(nil)
//    let gesamtVorherigWoche         = MutableProperty<String?>(nil)
//    let gesamtVorherigMonat         = MutableProperty<String?>(nil)
//    let gesamtAenderungTag          = MutableProperty<String?>(nil)
//    let gesamtAenderungWoche        = MutableProperty<String?>(nil)
//    let gesamtAenderungMonat        = MutableProperty<String?>(nil)
//    let gesamtAenderungTagFarbe     = MutableProperty<UIColor>(.black)
//    let gesamtAenderungWocheFarbe   = MutableProperty<UIColor>(.black)
//    let gesamtAenderungMonatFarbe   = MutableProperty<UIColor>(.black)
//
//
//    //2. Block - Durchschnitt
//    let durchschnittTag             = MutableProperty<String?>(nil)
//    let durchSchnittWoche           = MutableProperty<String?>(nil)
//    let durchSchnittMonat           = MutableProperty<String?>(nil)
//    let durchschnittVorherigTag     = MutableProperty<String?>(nil)
//    let durchschnittVorherigWoche   = MutableProperty<String?>(nil)
//    let durchschnittVorherigMonat   = MutableProperty<String?>(nil)
//    let durchschnittAenderungTag    = MutableProperty<String?>(nil)
//    let durchschnittAenderungWoche  = MutableProperty<String?>(nil)
//    let durchschnittAenderungMonat  = MutableProperty<String?>(nil)
//    let durchschnittAenderungTagFarbe   = MutableProperty<UIColor>(.black)
//    let durchschnittAenderungWocheFarbe = MutableProperty<UIColor>(.black)
//    let durchschnittAenderungMonatFarbe = MutableProperty<UIColor>(.black)
//
//
//    init(model:StatistikModel){
//        //Überschrift
//        gesamt                      <~ model.gesamt.producer.map{$0.hhmmString}
//        //1. Block - Gesamt
//        gesamtAktuellTag            <~ model.gesamtAktuellTag.producer.map{$0.hhmmString}
//        gesamtAktuellWoche          <~ model.gesamtAktuellWoche.producer.map{$0.hhmmString}
//        gesamtAktuellMonat          <~ model.gesamtAktuellMonat.producer.map{$0.hhmmString}
//        gesamtVorherigTag           <~ model.gesamtVorherigTag.producer.map{$0.hhmmString}
//        gesamtVorherigWoche         <~ model.gesamtVorherigWoche.producer.map{$0.hhmmString}
//        gesamtVorherigMonat         <~ model.gesamtVorherigMonat.producer.map{$0.hhmmString}
//        gesamtAenderungTag          <~ model.gesamtAenderungTag.producer.map{$0.hhmmString}
//        gesamtAenderungWoche        <~ model.gesamtAenderungWoche.producer.map{$0.hhmmString}
//        gesamtAenderungMonat        <~ model.gesamtAenderungMonat.producer.map{$0.hhmmString}
//        gesamtAenderungTagFarbe     <~ model.gesamtAenderungTag.producer.map{$0.aenderungsfarbe}
//        gesamtAenderungWocheFarbe   <~ model.gesamtAenderungWoche.producer.map{$0.aenderungsfarbe}
//        gesamtAenderungMonatFarbe   <~ model.gesamtAenderungMonat.producer.map{$0.aenderungsfarbe}
//
//        //2. Block - Durchschnitt
//        durchschnittTag                 <~ model.durchschnittTag.producer.map{$0.hhmmString}
//        durchSchnittWoche               <~ model.durchSchnittWoche.producer.map{$0.hhmmString}
//        durchSchnittMonat               <~ model.durchSchnittMonat.producer.map{$0.hhmmString}
//        durchschnittVorherigTag         <~ model.durchschnittVorherigTag.producer.map{$0.hhmmString}
//        durchschnittVorherigWoche       <~ model.durchschnittVorherigWoche.producer.map{$0.hhmmString}
//        durchschnittVorherigMonat       <~ model.durchschnittVorherigMonat.producer.map{$0.hhmmString}
//        durchschnittAenderungTag        <~ model.durchschnittAenderungTag.producer.map{$0.hhmmString}
//        durchschnittAenderungWoche      <~ model.durchschnittAenderungWoche.producer.map{$0.hhmmString}
//        durchschnittAenderungMonat      <~ model.durchschnittAenderungMonat.producer.map{$0.hhmmString}
//        durchschnittAenderungTagFarbe   <~ model.durchschnittAenderungTag.producer.map{$0.aenderungsfarbe}
//        durchschnittAenderungWocheFarbe <~ model.durchschnittAenderungWoche.producer.map{$0.aenderungsfarbe}
//        durchschnittAenderungMonatFarbe <~ model.durchschnittAenderungMonat.producer.map{$0.aenderungsfarbe}
//    }
//}

//class StatistikUeberblick: NibLoadingView {
//    var viewModel:StatistikUeberblickViewModel!{
//        didSet{
//            //Überschrift
//            gesamt.reactive.text                    <~ viewModel.gesamt.producer
//
//            //1. Block - Gesamt
//            gesamtAktuellTag.reactive.text          <~ viewModel.gesamtAktuellTag.producer
//            gesamtAktuellWoche.reactive.text        <~ viewModel.gesamtAktuellWoche.producer
//            gesamtAktuellMonat.reactive.text        <~ viewModel.gesamtAktuellMonat.producer
//            gesamtVorherigTag.reactive.text         <~ viewModel.gesamtVorherigTag.producer
//            gesamtVorherigWoche.reactive.text       <~ viewModel.gesamtVorherigWoche.producer
//            gesamtVorherigMonat.reactive.text       <~ viewModel.gesamtVorherigMonat.producer
//            gesamtAenderungTag.reactive.text        <~ viewModel.gesamtAenderungTag.producer
//            gesamtAenderungWoche.reactive.text      <~ viewModel.gesamtAenderungWoche.producer
//            gesamtAenderungMonat.reactive.text      <~ viewModel.gesamtAenderungMonat.producer
//            gesamtAenderungTag.reactive.textColor   <~ viewModel.gesamtAenderungTagFarbe.producer
//            gesamtAenderungWoche.reactive.textColor <~ viewModel.gesamtAenderungWocheFarbe.producer
//            gesamtAenderungMonat.reactive.textColor <~ viewModel.gesamtAenderungMonatFarbe.producer
//
//            //2. Block - Durchschnitt
//            durchschnittTag.reactive.text                   <~ viewModel.durchschnittTag.producer
//            durchSchnittWoche.reactive.text                 <~ viewModel.durchSchnittWoche.producer
//            durchSchnittMonat.reactive.text                 <~ viewModel.durchSchnittMonat.producer
//            durchschnittVorherigTag.reactive.text           <~ viewModel.durchschnittVorherigTag.producer
//            durchschnittVorherigWoche.reactive.text         <~ viewModel.durchschnittVorherigWoche.producer
//            durchschnittVorherigMonat.reactive.text         <~ viewModel.durchschnittVorherigMonat.producer
//            durchschnittAenderungTag.reactive.text          <~ viewModel.durchschnittAenderungTag.producer
//            durchschnittAenderungWoche.reactive.text        <~ viewModel.durchschnittAenderungWoche.producer
//            durchschnittAenderungMonat.reactive.text        <~ viewModel.durchschnittAenderungMonat.producer
//            durchschnittAenderungTag.reactive.textColor     <~ viewModel.durchschnittAenderungTagFarbe.producer
//            durchschnittAenderungWoche.reactive.textColor   <~ viewModel.durchschnittAenderungWocheFarbe.producer
//            durchschnittAenderungMonat.reactive.textColor   <~ viewModel.durchschnittAenderungMonatFarbe.producer
//
//        }
//    }
//
//    //Überschrift
//    @IBOutlet weak var gesamt: UILabel!
//
//    //1. Block - Gesamt
//    @IBOutlet weak var gesamtAktuellTag: UILabel!
//    @IBOutlet weak var gesamtAktuellWoche: UILabel!
//    @IBOutlet weak var gesamtAktuellMonat: UILabel!
//    @IBOutlet weak var gesamtVorherigTag: UILabel!
//    @IBOutlet weak var gesamtVorherigWoche: UILabel!
//    @IBOutlet weak var gesamtVorherigMonat: UILabel!
//    @IBOutlet weak var gesamtAenderungTag: UILabel!
//    @IBOutlet weak var gesamtAenderungWoche: UILabel!
//    @IBOutlet weak var gesamtAenderungMonat: UILabel!
//
//    //2. Block - Durchschnitt
//    @IBOutlet weak var durchschnittTag: UILabel!
//    @IBOutlet weak var durchSchnittWoche: UILabel!
//    @IBOutlet weak var durchSchnittMonat: UILabel!
//    @IBOutlet weak var durchschnittVorherigTag: UILabel!
//    @IBOutlet weak var durchschnittVorherigWoche: UILabel!
//    @IBOutlet weak var durchschnittVorherigMonat: UILabel!
//    @IBOutlet weak var durchschnittAenderungTag: UILabel!
//    @IBOutlet weak var durchschnittAenderungWoche: UILabel!
//    @IBOutlet weak var durchschnittAenderungMonat: UILabel!
//
////    @IBAction func iButtonPressed(_ sender: UIButton)           { delegate?.infoButtonPressed() }
//    @IBOutlet weak var statistikView: UIView!                   { didSet{ statistikView.setControlDesignPatterns() } }
////    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) { delegate?.viewTapped() }
//}





