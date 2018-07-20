//
//  GraphBackGround.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 14.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
//Hintergrund für BalkenGraph
// passt sich an Daten an
@IBDesignable class GraphBackGround:NibLoadingView{
    var viewModel:GraphBackGroundViewModel! { didSet{ viewModel.stackData.producer.startWithValues {[weak self] stackData in self?.updateStack( stackData) } } }
    
    //IBOutlets
    @IBOutlet weak var stackView: UIStackView!
    
    //helper
    private var removed:[UIView] = [UIView]()
    private func updateStack(_ stackData :(toRemove:Int,step:Double)){
        //views update
        let dif = stackData.toRemove - removed.count
        if dif < 0 { for _ in 0 ..< abs(dif){ stackView.addArrangedSubview(removed.removeLast()) }  }
        if dif > 0{
            for toRemove in stackView.arrangedSubviews.prefix(dif){
                stackView.removeArrangedSubview(toRemove)
                removed.append(toRemove)
            }
        }
        //labels update
        let labels = stackView.arrangedSubviews.map({$0.subviews.filter{$0 is UILabel}.first as? UILabel}).compactMap({$0}).reversed()
        for label in labels.enumerated()            { label.element.text  = String(stackData.step * Double(label.offset)) }
    }
}


