//
//  KalenderMonatHeaderView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import UIKit

//✅
//Header eines einzelnen Monats
// in Monats Kalender
class KalenderMonatHeaderView:NibLoadingView{
    //IBOutlets
    @IBOutlet weak var monatLabel: UILabel!
    @IBOutlet weak var summeLabel: UILabel!
    @IBOutlet weak var durchschnittLabel: UILabel!
    
    //init
    init(monat:Date){
        super.init(frame: CGRect.zero)
        monatLabel.text             = monat.string("MMMM")
        let statistik               = Statistik(start: monat.startOfMonth, ende: monat.endOfMonth)
        durchschnittLabel.text      = statistik?.tagDauerLabelText
        summeLabel.text             = statistik?.gesamtDauer.hhmm
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        layer.borderWidth = 0.5
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
