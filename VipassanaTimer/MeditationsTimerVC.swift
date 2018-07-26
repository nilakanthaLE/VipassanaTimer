//
//  MeditationsTimer.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 03.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
class MeditationsTimerVC: DesignViewControllerPortrait {
    var viewModel:MeditationsTimerVCModel!
    
    //VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // App aktiv halten
        UIApplication.shared.isIdleTimerDisabled    = true
        //startet Observer Liste aktiver Meditationen
        //Aktion show PublicMeditationInfo
        viewModel.tappedMeditationsPlatz.signal.observeValues{[weak self] publicMeditation in self?.performSegue(withIdentifier: "showUserInfo", sender: publicMeditation)}
        //timerView
        timerView.viewModel             = viewModel.getTimerAsTimerViewModel()
        timerView.timerAnzeigeTapped    = {[weak self] in self?.performSegue(withIdentifier: "nextVC", sender: nil)}
    }
    
    //Outlets
    @IBOutlet weak var timerView: TimerAsTimerView!
    
    //segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? GeradeMeditiertView)?.viewModel  = viewModel.getGeradeMeditiertViewModel()
        (segue.destination as? TimerTableVC)?.viewModel         = viewModel.getTimerTableVCViewModel()
        guard let sender = sender as? PublicMeditation else {return}
        (segue.destination.contentViewController as? PublicMeditationInfoVC)?.viewModel = PublicMeditationInfoViewModel(publicMeditation: sender)
    }

    //deinit
    deinit {
        UIApplication.shared.isIdleTimerDisabled    = false
        soundFileAudioPlayer.soundFileData.value = nil
        print("deinit MeditationsTimerVC") }
}


