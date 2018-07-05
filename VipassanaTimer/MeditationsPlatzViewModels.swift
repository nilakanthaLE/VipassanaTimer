//
//  MeditationsPlatzCollectionViewCell.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 09.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift

class MeditationsPlatzCellViewModel{
    let meditationsPlatzViewModel:MeditationsPlatzViewModel
    init(publicMeditation:PublicMeditation){
        print("init MeditationsPlatzCellViewModel")
        meditationsPlatzViewModel = MeditationsPlatzViewModel(publicMeditation: publicMeditation)
    }
    deinit {
        meditationsPlatzViewModel.timer?.invalidate()
        print("deinit MeditationsPlatzCellViewModel")
    }
}




class MeditationsPlatzViewModel{
    let meditationsPlatzTitle   = MutableProperty<String?>(nil)
    let mettaEffektHasStarted   = MutableProperty<Bool>(false)
    init(publicMeditation:PublicMeditation){
        print("init MeditationsPlatzViewModel (publicMeditation)")
        meditationsPlatzTitle.value   = publicMeditation.meditator.meditationsPlatzTitle
        setTimer(for: publicMeditation.startZeitMetta)
        
        
        
    }
    init(meditationsPlatzTitle:MutableProperty<String?>){
        print("init MeditationsPlatzViewModel")
        self.meditationsPlatzTitle <~ meditationsPlatzTitle.producer
    }
    var timer:Timer?
    func setTimer(for date:Date){
        print("set Timer for mettaEffektHasStarted \(date.string("hh:ss"))")
        timer?.invalidate()
        timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(startMetteEffekt), userInfo: nil, repeats: false)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
        
    }
    @objc func startMetteEffekt(){
        print("startMettaEffekt")
        weak var weakSelf = self //????
        weakSelf?.mettaEffektHasStarted.value = true
    }
    
    deinit { print("deinit MeditationsPlatzViewModel") }
}



