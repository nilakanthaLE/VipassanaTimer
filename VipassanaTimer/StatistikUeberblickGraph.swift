//
//  StatistikUeberblickGraph.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 14.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
//Basisklasse für BalkenDiagramme
@IBDesignable class StatistikUeberblickGraph:NibLoadingView{
    var viewModel:StatistikUeberblickGraphViewModel!{
        didSet{
            //in
            aktuellLabel.reactive.text      <~ viewModel.aktuellLabelText.producer
            letzterLabel.reactive.text      <~ viewModel.letzterLabelText.producer
            vorletzterLabel.reactive.text   <~ viewModel.vorletzterLabelText.producer
            
            aktuellValueLabel.reactive.text         <~ viewModel.aktuellValueLabelText.producer
            letzterValueLabel.reactive.text         <~ viewModel.letzterValueLabelText.producer
            vorletzterValueLabel.reactive.text      <~ viewModel.vorletzterValueLabelText.producer
            durchschnittValueLabel.reactive.text    <~ viewModel.durchschnittValueLabelText.producer
            
            aktuellHeightConstraint.reactive.constant       <~ viewModel.aktuellHeight.producer
            letzterHeightConstraint.reactive.constant       <~ viewModel.letzterHeight.producer
            vorletzterHeightConstraint.reactive.constant    <~ viewModel.vorletzterHeight.producer
            durchSchnittHeightConstraint.reactive.constant  <~ viewModel.durchSchnittHeight.producer

            //viewModels
            backGroundView.viewModel        = viewModel.getViewModelForBackGroundView()
            
            //design
            for view in balkenViews{ view.clipsToBounds = true}
        }
    }
    
    //IBOutlets
    @IBOutlet weak var aktuellHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var letzterHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var vorletzterHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var durchSchnittHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backGroundView: GraphBackGround!
    @IBOutlet weak var aktuellLabel: UILabel!
    @IBOutlet weak var letzterLabel: UILabel!
    @IBOutlet weak var vorletzterLabel: UILabel!
    @IBOutlet weak var durchschnittValueLabel: UILabel!
    @IBOutlet weak var vorletzterValueLabel: UILabel!
    @IBOutlet weak var letzterValueLabel: UILabel!
    @IBOutlet weak var aktuellValueLabel: UILabel!
    @IBOutlet var balkenViews: [UIView]!
    
    //layout subviews
    override func layoutSubviews() { viewModel?.viewHeight.value = backGroundView.bounds.height }
}
