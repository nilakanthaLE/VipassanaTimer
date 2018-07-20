//
//  HauptMenuStatistikenView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 15.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
//Statistiken der Startseite
// zum durchblättern
@IBDesignable class HauptMenuStatistikenView:NibLoadingView{
    private var reihenFolge:[UIView] = [UIView]()
    var viewModel:HauptMenuStatistikenViewModel!{
        didSet{
            //views (zum blättern) init
            let regelmaessigkeitView:StatistikUeberblickRegelmaessigkeitView    = StatistikUeberblickRegelmaessigkeitView(frame:CGRect.zero)
            let taeglichView:StatistikUeberblickBalkenView                      = StatistikUeberblickBalkenView(frame:CGRect.zero)
            let woechentlichView:StatistikUeberblickBalkenView                  = StatistikUeberblickBalkenView(frame:CGRect.zero)
            let monatlichView:StatistikUeberblickBalkenView                     = StatistikUeberblickBalkenView(frame:CGRect.zero)
            reihenFolge = [regelmaessigkeitView,  taeglichView, woechentlichView, monatlichView]
            resetStackForReihenfolge()
            
            //viewModels
            taeglichView.viewModel          = viewModel.getViewModelForStatistikUeberlick1View(takt: .taeglich)
            woechentlichView.viewModel      = viewModel.getViewModelForStatistikUeberlick1View(takt: .woechentlich)
            monatlichView.viewModel         = viewModel.getViewModelForStatistikUeberlick1View(takt: .monatlich)
            regelmaessigkeitView.viewModel  = viewModel.getViewModelForStatistikUeberblick2View()
            
            //design
            clipsToBounds = true
        }
    }
    //IBActions
    @IBAction func swipeAction(_ sender: UISwipeGestureRecognizer) { animateStack(direction: sender.direction) }
    
    //IBOutlets
    @IBOutlet weak var stackView: UIStackView!
    
    //helper
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
