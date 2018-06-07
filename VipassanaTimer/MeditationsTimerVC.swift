//
//  MeditationsTimer.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 03.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift


@IBDesignable class MeditationsTimerVC: UIViewController {
    var viewModel:MeditationsTimerVCModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor            = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        navigationController?.navigationBar.setDesignPattern()
        
        
        
        fireBaseModel.observerFuerListeAktiv        = true
        
        UIApplication.shared.isIdleTimerDisabled    = true
        
        
        mainModel.tappedMeditationsPlatz.signal.observeValues{[weak self] publicMeditation in self?.performSegue(withIdentifier: "showUserInfo", sender: publicMeditation)}
    }
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func timerAnzeigeTapped(){ performSegue(withIdentifier: "nextVC", sender: nil) }
    @IBOutlet weak var timerView: TimerAsTimerView!{
        didSet{
            timerView.viewModel             = viewModel.getTimerAsTimerViewModel()
            timerView.timerAnzeigeTapped    = {[weak self] in self?.timerAnzeigeTapped()}
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? GeradeMeditiertView)?.viewModel  = viewModel.getGeradeMeditiertViewModel()
        (segue.destination as? TimerTableVC)?.viewModel         = viewModel.getTimerTableVCViewModel()
        
        guard let sender = sender as? PublicMeditation else {return}
        (segue.destination.contentViewController as? PublicMeditationInfoVC)?.viewModel = PublicMeditationInfoViewModel(model: PublicMeditationInfoModel(publicMeditation: sender))
    }

    deinit {
        mainModel.myActiveMeditation.value          = nil
        UIApplication.shared.isIdleTimerDisabled    = false
        fireBaseModel.observerFuerListeAktiv        = false
        print("deinit MeditationsTimerVC") }
}


