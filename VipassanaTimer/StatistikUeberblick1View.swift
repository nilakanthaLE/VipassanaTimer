//
//  StatistikUeberblick1View.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 14.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

class StatistikUeberblick1ViewModel{
    let taktLabelText = MutableProperty<String?>(nil)
    private let data:MutableProperty<StatistikUeberblickGraphData>
    let infoButtonAction = MutableProperty<Void>(Void())
    init(data:MutableProperty<StatistikUeberblickGraphData>, infoButtonAction: MutableProperty<Void>){
        self.data = MutableProperty<StatistikUeberblickGraphData>(data.value)
        self.data           <~ data.signal
        taktLabelText       <~ data.producer.map{$0.takt.rawValue}
        infoButtonAction    <~ self.infoButtonAction.signal
    }
    func getViewModelForStatistikUeberblickGraph() -> StatistikUeberblickGraphViewModel{ return StatistikUeberblickGraphViewModel(data: data) }
    
    deinit {
        print("deinit StatistikUeberblick1ViewModel")
    }
}

class StatistikUeberblick1View:NibLoadingView{
    var viewModel:StatistikUeberblick1ViewModel!{
        didSet{
            taktLabel.reactive.text <~ viewModel.taktLabelText
            statistikUeberblickGraph.viewModel  = viewModel.getViewModelForStatistikUeberblickGraph()
            layer.borderColor   = standardRahmenFarbe.cgColor
            layer.borderWidth   = standardBorderWidth
            layer.cornerRadius  = standardCornerRadius
            clipsToBounds = true
        }
    }
    @IBOutlet weak var taktLabel: UILabel!
    @IBOutlet weak var statistikUeberblickGraph: StatistikUeberblickGraph!
    
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        viewModel.infoButtonAction.value = Void()
    }
}
