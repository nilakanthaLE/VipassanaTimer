//
//  KalenderVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 26.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit
import MyCalendar

extension Notification.Name {
    enum MyNames{
        static let meditationsKalenderEintragPressed = Notification.Name("meditationsKalenderEintragPressed")
        static let tagInMonatsSichtPressed = Notification.Name("tagInMonatsSichtPressed")
    }
}


class KalenderVC: UIViewController,KalenderViewDelegate {
    //MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignPatterns.mainBackground
        navigationController?.navigationBar.setDesignPattern()
    }
    
    var firstAppear = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear{
            NotificationCenter.default.addObserver(self, selector: #selector(meditationsKalenderEintragPressed(notification:)), name: Notification.Name.MyNames.meditationsKalenderEintragPressed, object: nil)
            firstAppear = false
        }
        let appConfig = AppConfig.get()
        if appConfig?.kalenderErstesErscheinen != true{
            let paragraphStyle          = NSMutableParagraphStyle()
            paragraphStyle.alignment    = .justified
            
            
            
            
            let messageText = NSMutableAttributedString(
                
            
                string: NSLocalizedString("AnleitungKalender", comment: "AnleitungKalender"),
                attributes: [
                    NSAttributedStringKey.paragraphStyle : paragraphStyle,
                    NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
                    NSAttributedStringKey.foregroundColor : UIColor.black
                ]
            )
            
            let alertVC = UIAlertController(title: NSLocalizedString("AnleitungTitle", comment: "AnleitungTitle"), message: "", preferredStyle: .alert)
            alertVC.setValue(messageText, forKey: "attributedMessage")
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            alertVC.addAction(UIAlertAction(title: NSLocalizedString("AnleitungDontShowAgain", comment: "AnleitungDontShowAgain"), style: .default, handler: { (action) in
                appConfig?.kalenderErstesErscheinen = true
                saveContext()
            }))
            present(alertVC, animated: true, completion: nil)
        }
    }
    @objc private func meditationsKalenderEintragPressed(notification:Notification){
        guard let meditation = notification.userInfo!["meditation"]  else {return}
        performSegue(withIdentifier: "editMeditation", sender: meditation)
    }
    //MARK: Outlets
    @IBOutlet weak var kalender: KalenderView!{
         didSet{
            kalender.delegate           = self
            kalender.titleLabelForDay = { (day:Date) in
                return KalenderTagHeader.init(datum: day)
            }
            kalender.viewForDateInMonatsView = {
                (date:Date,monat:Date) in
                return DayViewForMonthView.init(day: date, month: monat)
            }
        }
    }

    //MARK: Actions
    @IBAction func addMeditationButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editMeditation", sender: nil)
    }
    
    //MARK: KalenderViewDelegate
    func getKalenderEintraegeFor(dates: [Date]) -> [[KalenderEintrag]] {
        return Meditation.getKalenderEintraege(days: dates)
    }
    func newVisibleDates(dates: [Date],showsTagesKalender:Bool) {
        if showsTagesKalender{
            navigationItem.titleView = WochenKalenderTitleView(dates: dates)
        }
        else{
            guard let monat = dates.first else {return}
            navigationItem.titleView = MonatKalenderTitleView(monat: monat)
        }
    }
    
    //MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination.contentViewController as? EditMeditationVC, let meditation = sender as? Meditation {
            destination.meditation  = meditation
        }
    }
    @IBAction func reloadKalender(segue:UIStoryboardSegue){
        print("reloadKalender")
        guard let editMeditationVC = segue.source as? EditMeditationVC, let start = editMeditationVC.meditation?.start else{return}
        kalender.reloadKalenderTag(date:start as Date)
    }
    deinit {
        print("KalenderVC deinit")
    }
}

class KalenderTagHeader:NibLoadingView{
    @IBOutlet weak var datumLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statistikLabel: UILabel!
    
    let datum:Date
    init(datum _datum:Date){
        datum = _datum
        super.init(frame: CGRect.zero)
        layer.borderColor   = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        layer.borderWidth   = 0.5
        backgroundColor     = UIColor.clear
        createViewAsync()
    }
    private func createViewAsync(){
    {} ~>  {[weak self] in
            
            let tagString       = self?.datum.string("EEE") ?? ""
        let myAttrString1   = NSMutableAttributedString(string: tagString , attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)])
            let datumString     = self?.datum.string(" dd.MM.") ?? ""
        let myAttrString2   = NSMutableAttributedString(string: datumString , attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
            let combination     = NSMutableAttributedString()
            combination.append(myAttrString1)
            combination.append(myAttrString2)
            
            self?.datumLabel.attributedText         = combination
            let statistik                               = Meditation.getStatistics(von: self?.datum, bis: self?.datum)
            self?.statistikLabel.text = statistik?.timePerDay.hhmmString
            if statistik?.timesPerDay ?? 0 > 0{
                if statistik?.timePerDay ?? 0 >= 120*60 && statistik?.timesPerDay ?? 0 >= 2 {
                    self?.statusLabel.text = "✅✅"
                }else{
                    self?.statusLabel.text = "☑️✅"
                }
            }else{
                self?.statusLabel.text = "☑️☑️"
            }
            
            if self!.datum.isSunday {
                _ = self?.addBorder(edges: .right, colour: .red, thickness: 0.5)
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WochenKalenderTitleView:NibLoadingView{
    override var nibName: String{
        return "KalenderTitleView"
    }
    @IBOutlet weak var titleLabel: UILabel!
    init(dates:[Date]){
        super.init(frame: CGRect.zero)
        backgroundColor     = UIColor.clear
        var labelText       = ""
        if dates.count != 1{
            let mostVisibleWeek = Date.weekOfMostDays(in: dates)
            let montag          = mostVisibleWeek.mondayOfWeek
            let sonntag         = mostVisibleWeek.sundayOfWeek
            
            let localWeek   = NSLocalizedString("Week", comment: "Week")
            let wocheText   = localWeek + " (\(montag.string("dd")).-\(sonntag.string("dd")).)"
            let trenner = "    "
            let statistik = Meditation.getStatistics(von: montag, bis: sonntag)
            
            
            
            labelText = wocheText + trenner + (statistik?.wocheDauerLabelText ?? "")
        }
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.text = labelText
        titleLabel.textColor    = DesignPatterns.mocha
        titleLabel.sizeToFit()
        titleLabel.backgroundColor     = UIColor.clear
        frame = CGRect(origin: CGPoint.zero, size: titleLabel.frame.size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MonatKalenderTitleView:NibLoadingView{
    override var nibName: String{
        return "KalenderTitleView"
    }
    @IBOutlet weak var titleLabel: UILabel!
    init(monat:Date){
        super.init(frame: CGRect.zero)
        backgroundColor     = UIColor.clear
        let statistik       = Meditation.getStatistics(von: monat.startOfMonth.firstSecondOfDay! , bis: monat.endOfMonth.lastSecondOfDay!)
        
        let titleLabelText:String = {
            var ergebnis = String()
            ergebnis += statistik?.gesamtDauer.hhmmString ?? ""
            ergebnis += " h | "
            ergebnis += "\(statistik?.anzahlMeditationen ?? 0) "
            ergebnis += NSLocalizedString("MonatKalenderTitleViewTimes", comment: "MonatKalenderTitleViewTimes") + " | "
            ergebnis += statistik?.timePerDay.hhmmString ?? ""
            ergebnis += NSLocalizedString("MonatKalenderTitleViewPerDay", comment: "MonatKalenderTitleViewPerDay")
            return ergebnis
        }()
        
        titleLabel.text     = titleLabelText
        
        
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor    = DesignPatterns.mocha
        titleLabel.sizeToFit()
        titleLabel.backgroundColor = UIColor.clear
        frame = CGRect(origin: CGPoint.zero, size: titleLabel.frame.size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class KalenderMonatHeaderView:NibLoadingView{
    @IBOutlet weak var monatLabel: UILabel!
    @IBOutlet weak var summeLabel: UILabel!
    @IBOutlet weak var durchschnittLabel: UILabel!
    
    init(monat:Date){
        super.init(frame: CGRect.zero)
        monatLabel.text     = monat.string("MMMM")
        let meditations     = Meditation.getDays(start: monat.startOfMonth, ende: monat.endOfMonth)
        let statistik               = Statistik(meditationen: meditations, start: monat.startOfMonth.firstSecondOfDay!, ende: monat.endOfMonth.lastSecondOfDay!)
        durchschnittLabel.text      = statistik.tagDauerLabelText
        summeLabel.text             = Meditation.gesamtDauer(meditationen: meditations).hhmmString
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        layer.borderWidth = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DayViewForMonthView:NibLoadingView{
    private var day:Date
    private var month:Date
//    private var status:Int = 0
    
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var buddhaGoldImageView: UIImageView!
    @IBOutlet weak var buddhaBlackImageView: UIImageView!
    
    init(day _day:Date,month  _month:Date){
        day     = _day
        month   = _month
        super.init(frame: CGRect.zero)
        dayLabel.text               = day.string("dd")
        dayLabel.sizeToFit()
        layer.borderColor           = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        layer.borderWidth           = 0.25
        view.backgroundColor        = UIColor.clear
        backgroundColor             = UIColor.clear
        
        let dayIsWithinMonth        = month.startOfMonth.firstSecondOfDay?.isGreaterThanDate(dateToCompare: day) == false && day.isGreaterThanDate(dateToCompare: month.endOfMonth.lastSecondOfDay!) == false
        dayLabel.textColor      = dayIsWithinMonth ? UIColor.darkText : UIColor(white: 0, alpha: 0.1)
        
        craeteView(dayIsWithinMonth:dayIsWithinMonth)
    }
    private func craeteView(dayIsWithinMonth:Bool){
    {} ~>  {[weak self] in
            var status:Int = 0
            if dayIsWithinMonth{
                let statistik       = Meditation.getStatistics(von: self?.day, bis: self?.day)
                if statistik?.timesPerDay ?? 0 > 0{
                    if (statistik?.timePerDay ?? 0) >= 120*60 && (statistik?.timesPerDay ?? 0) >= 2
                    { status = 2}
                    else{ status = 1 }
                }
            }
            switch status{
            case 1 :self?.buddhaBlackImageView.isHidden   = false
            case 2 :self?.buddhaGoldImageView.isHidden   = false
            default: break
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        let notification = Notification(name: Notification.Name.MyNames.tagInMonatsSichtPressed, object: nil, userInfo: ["day":day])
        NotificationCenter.default.post(notification)
    }
    
}
extension NSNotification.Name{
    static let test = "Test"
}
