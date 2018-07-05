//
//  GraphBackGround.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 14.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

class GraphBackGroundViewModel{
    let stackData           = MutableProperty<(toRemove:Int,step:Double)>((0,0))
    init(maxValue:MutableProperty<Double>){
        stackData           <~  maxValue.producer.map{
            (10 - GraphBackGroundViewModel.anzahlInStack(maxValue: $0),
             GraphBackGroundViewModel.steps(maxValue: $0))
        }
    }
    
    //helper
    static func anzahlInStack(maxValue:Double) -> Int{
        switch maxValue{
        case  _ where maxValue < 1                      : return Int(maxValue * 10) + 1
        case _ where maxValue >= 1 && maxValue < 10     : return Int(maxValue) + 1
        case _ where maxValue >= 10 && maxValue < 100   : return Int(maxValue / 10) + 1
        case _ where maxValue >= 100                    : return 10
        default: return 0
        }
    }
    static func steps(maxValue:Double) -> Double{
        print("steps: \(maxValue)")
        switch maxValue{
            case  _ where maxValue < 1                      : return 0.1
            case _ where maxValue >= 1 && maxValue < 10     : return 1.0
            case _ where maxValue >= 10 && maxValue < 100   : return 10
            case _ where maxValue >= 100                    : return Double(Int(maxValue / 10) + 1)
        default: return 0
        }
    }
}
@IBDesignable class GraphBackGround:NibLoadingView{
    var viewModel:GraphBackGroundViewModel!{
        didSet{
            viewModel.stackData.producer.startWithValues {[weak self] stackData in
                print("stackData: \(stackData)")
                self?.updateStack( stackData) }
            
        }
    }
    @IBOutlet weak var stackView: UIStackView!
    private var removed:[UIView] = [UIView]()
    func updateStack(_ stackData :(toRemove:Int,step:Double)){
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
        for label in labels.enumerated(){
            print("label: \(stackData.step * Double(label.offset))")
            label.element.text  = String(stackData.step * Double(label.offset))
        }
    }
}


