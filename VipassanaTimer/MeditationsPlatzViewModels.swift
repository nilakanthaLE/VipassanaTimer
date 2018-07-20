//
//  MeditationsPlatzCollectionViewCell.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 09.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift

//✅
class MeditationsPlatzViewModel{
    let meditationsPlatzTitle   = MutableProperty<String?>(nil)
    let mettaEffektHasStarted   = MutableProperty<Bool>(false)
    init(publicMeditation:PublicMeditation){
        meditationsPlatzTitle.value   = publicMeditation.meditator.meditationsPlatzTitle
        if publicMeditation.mettaEndlos || publicMeditation.mettaDauer > 0 { setTimer(for: publicMeditation.startZeitMetta) }
    }
    //init für MeditationsPlatz Konfiguration
    init(meditationsPlatzTitle:MutableProperty<String?>){
        self.meditationsPlatzTitle <~ meditationsPlatzTitle.producer
    }
    
    //Timer
    var timer:Timer?
    private func setTimer(for date:Date){
        timer?.invalidate()
        timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(startMettaEffekt), userInfo: nil, repeats: false)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)        
    }
    
    //TimerAction (Metta Effekt - pulsieren)
    @objc private func startMettaEffekt(){
        weak var weakSelf = self
        weakSelf?.mettaEffektHasStarted.value = true
    }
    
    deinit { print("deinit MeditationsPlatzViewModel") }
}



