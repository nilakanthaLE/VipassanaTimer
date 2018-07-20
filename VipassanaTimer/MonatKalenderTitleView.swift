//
//  MonatKalenderTitleView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
// ViewController TitleView
// für MonatKalender
class MonatKalenderTitleView:NibLoadingView{
    override var nibName: String{ return "KalenderTitleView" }
    
    // IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    
    // init
    init(monat:Date){
        super.init(frame: CGRect.zero)
        titleLabel.text         = getLabelText(monat: monat)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // helper
    private func getLabelText(monat:Date) -> String{
        let statistik       = Statistik(start: monat.startOfMonth, ende: monat.endOfMonth)
        var ergebnis        = String()
        ergebnis += statistik?.gesamtDauer.hhmm ?? ""
        ergebnis += " h | "
        ergebnis += "\(statistik?.anzahlMeditationen ?? 0) "
        ergebnis += NSLocalizedString("MonatKalenderTitleViewTimes", comment: "MonatKalenderTitleViewTimes") + " | "
        ergebnis += statistik?.timePerDay.hhmm ?? ""
        ergebnis += NSLocalizedString("MonatKalenderTitleViewPerDay", comment: "MonatKalenderTitleViewPerDay")
        return ergebnis
    }
}
