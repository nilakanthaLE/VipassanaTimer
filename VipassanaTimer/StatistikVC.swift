//
//  StatistikVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 31.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
class StatistikVC:UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor        = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        statisticsView.viewModel    = StatisticsViewModel()
        navigationController?.navigationBar.setDesignPattern()
    }
    @IBOutlet weak var statisticsView: StatisticsView!
}

//✅
class SetAnfangsDatumStatistikVC: DesignViewControllerPortrait {
    @IBOutlet weak var setStatistikAnfangsDatumView: SetStatistikAnfangsDatumView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatistikAnfangsDatumView.viewModel = SetStatistikAnfangsDatumViewModel()
        
    }
}
