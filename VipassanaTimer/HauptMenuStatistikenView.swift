//
//  HauptMenuStatistikenView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 15.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

class HauptMenuStatistikenViewModel{
    
    let taeglichStats       : MutableProperty<StatistikUeberblickGraphData>
    let woechentlichStats   : MutableProperty<StatistikUeberblickGraphData>
    let monatlichStats      : MutableProperty<StatistikUeberblickGraphData>
    let updateRegelmaessigkeit = MutableProperty<Void>(Void())
    
    let infoButtonAction = MutableProperty<Void>(Void())
    init(statistics:MutableProperty<Statistics>,infoButtonAction:MutableProperty<Void>){
        taeglichStats       =  MutableProperty<StatistikUeberblickGraphData>(statistics.value.getGraphData(takt: .taeglich))
        woechentlichStats   =  MutableProperty<StatistikUeberblickGraphData>(statistics.value.getGraphData(takt: .woechentlich))
        monatlichStats      =  MutableProperty<StatistikUeberblickGraphData>(statistics.value.getGraphData(takt: .monatlich))
        
        taeglichStats           <~ statistics.signal.map{$0.getGraphData(takt: .taeglich)}
        woechentlichStats       <~ statistics.signal.map{$0.getGraphData(takt: .woechentlich)}
        monatlichStats          <~ statistics.signal.map{$0.getGraphData(takt: .monatlich)}
        updateRegelmaessigkeit  <~ statistics.signal.map{_ in Void()}
        
        infoButtonAction    <~ self.infoButtonAction.signal
    }
    
    func getViewModelForStatistikUeberlick1View(takt:StatistikTakt) -> StatistikUeberblick1ViewModel{
        let property:MutableProperty<StatistikUeberblickGraphData> = {
            switch takt{
                case .taeglich:     return taeglichStats
                case .woechentlich: return woechentlichStats
                case .monatlich:    return monatlichStats
            }
        }()
        return StatistikUeberblick1ViewModel(data: property, infoButtonAction: infoButtonAction)
    }
    
    func getViewModelForStatistikUeberblick2View() -> StatistikUeberblick2ViewModel{
        return StatistikUeberblick2ViewModel(update: updateRegelmaessigkeit)
    }
}

@IBDesignable class HauptMenuStatistikenView:NibLoadingView{
    var viewModel:HauptMenuStatistikenViewModel!{
        didSet{
            taeglichView.viewModel          = viewModel.getViewModelForStatistikUeberlick1View(takt: .taeglich)
            woechentlichView.viewModel      = viewModel.getViewModelForStatistikUeberlick1View(takt: .woechentlich)
            monatlichView.viewModel         = viewModel.getViewModelForStatistikUeberlick1View(takt: .monatlich)
            regelmaessigkeitView.viewModel  = viewModel.getViewModelForStatistikUeberblick2View()
            
            reihenFolge = [regelmaessigkeitView,taeglichView,woechentlichView,monatlichView]
            resetStackForReihenfolge()
            

            clipsToBounds = true
        }
    }
    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) { animateStack(direction: sender.direction) }
    
    
    var reihenFolge:[UIView] = [UIView]()
    let regelmaessigkeitView:StatistikUeberblick2   = StatistikUeberblick2.init(frame:CGRect.zero)
    let taeglichView:StatistikUeberblick1View       = StatistikUeberblick1View(frame:CGRect.zero)
    let woechentlichView:StatistikUeberblick1View   = StatistikUeberblick1View(frame:CGRect.zero)
    let monatlichView:StatistikUeberblick1View      = StatistikUeberblick1View(frame:CGRect.zero)
    
    @IBOutlet weak var stackView: UIStackView!
    

    private func animateStack(direction:UISwipeGestureRecognizerDirection){
        let newX:CGFloat = {
            let multiplier:CGFloat = direction == .left ? -1 : direction == .right ? 1 : 0
            return stackView.frame.origin.x + multiplier * (stackView.frame.width / 3)
        }()
        UIView.animate(withDuration: 0.75, animations: {
            self.stackView.arrangedSubviews[0].alpha = 1
            self.stackView.arrangedSubviews[1].alpha = 0
            self.stackView.arrangedSubviews[2].alpha = 1
            self.stackView.frame.origin.x    = newX })
        { _ in
            self.updateReihenfolge(direction: direction)
            self.resetStackForReihenfolge()
        }
    }
    private func updateReihenfolge(direction:UISwipeGestureRecognizerDirection){
        if direction == .left{ reihenFolge.append(reihenFolge.removeFirst()) }
        if direction == .right{ reihenFolge.insert(reihenFolge.removeLast(), at: 0) }
    }
    private func resetStackForReihenfolge(){
        for subview in stackView.arrangedSubviews{subview.removeFromSuperview()}
        reihenFolge.last?.alpha = 0
        reihenFolge[1].alpha    = 0
        stackView.insertArrangedSubview(reihenFolge.last!, at: 0)
        stackView.insertArrangedSubview(reihenFolge.first!, at: 1)
        stackView.insertArrangedSubview(reihenFolge[1], at: 2)
        stackView.frame.origin.x = -stackView.frame.width  / 3
    }
}
