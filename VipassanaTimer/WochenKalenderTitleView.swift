//
//  WochenKalenderTitleView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import UIKit

//✅
// ViewController TitleView
// für WochenKalender
class WochenKalenderTitleView:NibLoadingView{
    override var nibName: String{  return "KalenderTitleView" }
    @IBOutlet weak var titleLabel: UILabel!
    init(dates:[Date]){
        super.init(frame: CGRect.zero)
        titleLabel.text             = getLabelText(dates: dates)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //helper
    private func getLabelText(dates:[Date]) -> String?{
        guard dates.count != 1 else { return nil }
        
        let mostVisibleWeek     = Date.weekOfMostDays(in: dates)
        let montag              = mostVisibleWeek.mondayOfWeek
        let sonntag             = mostVisibleWeek.sundayOfWeek
        
        let localWeek           = NSLocalizedString("Week", comment: "Week")
        let wocheText           = localWeek + " (\(montag.string("dd")).-\(sonntag.string("dd")).)"
        let trenner             = "    "
        let wocheDauerLabelText = Statistik(start: montag, ende: sonntag)?.wocheDauerLabelText ?? ""
        
        return wocheText + trenner + wocheDauerLabelText
    }
}
