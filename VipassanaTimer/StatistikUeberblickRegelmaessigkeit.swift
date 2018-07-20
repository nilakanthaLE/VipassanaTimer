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

//✅
// zeigt Regelmäßigkeit der Meditation
// auf Startseite
class StatistikUeberblickRegelmaessigkeitView:NibLoadingView{
    var viewModel:StatistikUeberblickRegelmaessigkeitViewModel!{
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
    
    //IBOutlets
    @IBOutlet private weak var statistikView: UIView!           { didSet{ statistikView.setStandardDesign() } }
    @IBOutlet private weak var gesamtZeitOhneKurse: UILabel!
    @IBOutlet private weak var einmalAmTagBisHeute: UILabel!
    @IBOutlet private weak var einmalAmTagMax: UILabel!
    @IBOutlet private weak var zweimalAmTagBisHeute: UILabel!
    @IBOutlet private weak var zweiMalAmTagMax: UILabel!
    @IBOutlet private weak var kursTage: UILabel!
    @IBOutlet private weak var gesamtZeit: UILabel!
}






