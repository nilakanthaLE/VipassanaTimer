//
//  TimerInPublicMeditationInfoModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 11.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import ReactiveSwift

//✅
class TimerInPublicMeditationInfoModel:TimerAnzeigeModel{
    private let ticker      = SignalProducer.timer(interval: DispatchTimeInterval.seconds(1), on: QueueScheduler.main)
    private let now         = MutableProperty<Date?>(nil)
    private var startZeit:Date
    init (publicMeditation:PublicMeditation){
        startZeit = publicMeditation.startDate
        super.init(timerData: TimerData(publicMeditation: publicMeditation))
        ticker.start()
        
        //  Updates, wenn Timer läuft
        now <~ ticker
        anzeigeDauer            <~ now.signal.map{[weak self] _ in self?._restDauer.hhmmss ?? "??"}
        verdeckAnteil           <~ now.signal.map{[weak self] _ in self?._ablaufAnteil ?? 0}
        
        hasSoundFile.value      = publicMeditation.hasSoundFile
    }
    
    //helper
    private var abgelaufen:TimeInterval{
        guard let now = now.value else { return 0}
        return now.timeIntervalSince(startZeit)
    }
    private var _ablaufAnteil: CGFloat  {
        guard abgelaufen <= gesamtDauer.value else { return 1}
        return CGFloat(abgelaufen / gesamtDauer.value)
    }
    private var _restDauer:TimeInterval {
        //bei metta endlos --> Anzeige wechselt nach regulärem Ende zu GesamtDauer
        if gesamtDauer.value - abgelaufen <= 0{ return  abgelaufen }
        return gesamtDauer.value - abgelaufen
    }
    deinit { print("deinit TimerInPublicMeditationInfoModel") }
}
