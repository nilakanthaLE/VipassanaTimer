//
//  StatistikUeberblick1View.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 14.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
class StatistikUeberblickBalkenViewModel{
    //public
    let taktLabelText = MutableProperty<String?>(nil)
    let infoButtonAction = MutableProperty<Void>(Void())
    
    //init
    private let data:MutableProperty<StatistikUeberblickGraphData>
    init(data:MutableProperty<StatistikUeberblickGraphData>, infoButtonAction: MutableProperty<Void>){
        self.data = MutableProperty<StatistikUeberblickGraphData>(data.value)
        self.data           <~ data.signal
        taktLabelText       <~ data.producer.map{$0.takt.rawValue}
        infoButtonAction    <~ self.infoButtonAction.signal
    }
    
    //ViewModels
    func getViewModelForStatistikUeberblickGraph() -> StatistikUeberblickGraphViewModel{ return StatistikUeberblickGraphViewModel(data: data) }
    
    deinit { print("deinit StatistikUeberblickBalkenViewModel") }
}

//✅
// BalkenView für Startseite
class StatistikUeberblickBalkenView:NibLoadingView{
    var viewModel:StatistikUeberblickBalkenViewModel!{
        didSet{
            //in
            taktLabel.reactive.text <~ viewModel.taktLabelText
            
            //out
            viewModel.infoButtonAction <~ infoButton.reactive.controlEvents(.touchUpInside).map{_ in Void()}
            
            //viewModel
            statistikUeberblickGraph.viewModel  = viewModel.getViewModelForStatistikUeberblickGraph()
            
            //design
            self.setStandardDesign()
        }
    }
    
    //IBOutlets
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var taktLabel: UILabel!
    @IBOutlet weak var statistikUeberblickGraph: StatistikUeberblickGraph!
}
