//
//  GraphBackGroundViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 13.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import ReactiveSwift

//✅
//Viewmodel für Balkendiagramhintergrund auf der Startseite
// passt sich an die Anzeigewerte an
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
        switch maxValue{
        case _ where maxValue < 1                       : return 0.1
        case _ where maxValue >= 1 && maxValue < 10     : return 1.0
        case _ where maxValue >= 10 && maxValue < 100   : return 10
        case _ where maxValue >= 100                    : return Double(Int(maxValue / 10) + 1)
        default: return 0
        }
    }
}
