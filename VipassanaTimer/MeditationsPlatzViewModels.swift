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
        meditationsPlatzViewModel = MeditationsPlatzViewModel(publicMeditation: publicMeditation)
    }
}




class MeditationsPlatzViewModel{
    let meditationsPlatzTitle   = MutableProperty<String?>(nil)
    let mettaEffektHasStarted   = MutableProperty<Void>(Void())
    init(publicMeditation:PublicMeditation){
        meditationsPlatzTitle.value   = publicMeditation.meditator.meditationsPlatzTitle
        setTimer(for: publicMeditation.startZeitMetta)
    }
    init(meditationsPlatzTitle:MutableProperty<String?>){
        self.meditationsPlatzTitle <~ meditationsPlatzTitle.producer
    }
    var timer:Timer?
    func setTimer(for date:Date){
        timer?.invalidate()
        timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(startMetteEffekt), userInfo: nil, repeats: false)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    @objc func startMetteEffekt(){ mettaEffektHasStarted.value = Void() }
    
    deinit {
        print("deinit MeditationsPlatzViewModel")
        timer?.invalidate()
    }
}



