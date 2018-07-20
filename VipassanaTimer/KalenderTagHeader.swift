//
//  KalenderTagHeader.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 12.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import UIKit

//✅
//Header eines einzelnen Tages
// in Tages/Wochen Kalender
class KalenderTagHeader:NibLoadingView{
    init(datum:Date){
        super.init(frame: CGRect.zero)
        setStyle()
        addSundayBorder(day:datum)
        datumLabel.attributedText   = KalenderTagHeader.getAttrString(day: datum)
        createViewAsync(day:datum)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    //IBOutlets
    @IBOutlet weak var datumLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statistikLabel: UILabel!
    
    //helper
    private func createViewAsync(day:Date){
        {} ~>  { [weak self] in
            self?.statusLabel.text                      = StatistikDay.statusLabelText(day: day)
            self?.statistikLabel.text                   = StatistikDay.timePerDay(day: day).hhmm
        }
    }
    static private func getAttrString(day:Date?) -> NSAttributedString?{
        guard let day = day else {return nil}
        let myAttrString1   = NSMutableAttributedString(string: day.string("EEE"),  attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
        let myAttrString2   = NSMutableAttributedString(string: day.string(" dd.MM."), attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
        let combination     = NSMutableAttributedString()
        combination.append(myAttrString1)
        combination.append(myAttrString2)
        return combination
    }
    private func addSundayBorder(day:Date){
        if day.isSunday {
            let border              = UIView(frame: CGRect.zero)
            border.backgroundColor  = .red
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|", options: [], metrics: ["thickness": 0.5], views: ["right": border]))
            addConstraints( NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|", options: [], metrics: nil, views: ["right": border]))
        }
    }
    private func setStyle(){
        layer.borderColor           = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        layer.borderWidth           = 0.5
        backgroundColor             = UIColor.clear
    }
}
