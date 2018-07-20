//
//  DayViewForMonthView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
// KalenderTag in Monatskalender
// hat goldenen oder sibernen Buddha
class DayViewForMonthView:NibLoadingView{
    //init
    private var day:Date
    init(day :Date,month  :Date){
        self.day = day
        super.init(frame: CGRect.zero)
        //dayLabel
        dayLabel.text               = day.string("dd")
        dayLabel.textColor          = isDayWithinMonth(day, month) ? UIColor.darkText : UIColor(white: 0, alpha: 0.1)
        dayLabel.sizeToFit()
        //buddha
        setBuddha(day: day,month: month)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //IBOutlets
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var buddhaGoldImageView: UIImageView!
    @IBOutlet weak var buddhaBlackImageView: UIImageView!
    
    //IBActions
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        let notification = Notification(name: Notification.Name.MyNames.tagInMonatsSichtPressed, object: nil, userInfo: ["day":day])
        NotificationCenter.default.post(notification)
    }
    
    //helper
    private func setBuddha(day:Date,month:Date){
        guard isDayWithinMonth( day, month)  else {return}
        {} ~>  {[weak self] in
            switch StatistikDay.buddhaStatus(day:day){
            case .gold:     self?.buddhaGoldImageView.isHidden      = false
            case .silver:   self?.buddhaBlackImageView.isHidden     = false
            case .none:     break
            }
        }
    }
    private func setStyle(){
        layer.borderColor           = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        layer.borderWidth           = 0.25
        view.backgroundColor        = UIColor.clear
        backgroundColor             = UIColor.clear
    }
    private func isDayWithinMonth(_ day:Date,_ month:Date) -> Bool{ return month.string("MM") == day.string("MM")  }
}

enum BuddhaStatus{
    case gold,silver,none
    var statusLabelText:String{
        switch self{
        case .gold:     return "✅✅"
        case .silver:   return "☑️✅"
        case .none:     return "☑️☑️"
        }
    }
}

