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
                
                string: "1) Der Monatskalender zeigt die verdienten Abzeichen eines Tages. Wurde an einem Tag meditiert, erhält man einen silbernen Buddha. Wurde mindestens zwei Mal für mindestens eine Stunde meditiert, erhält man einen goldenen Buddha\n\n2) Mit dem Knopf in der linken oberen Ecke wechselt man zwischen der Tages- bzw. Wochenansicht und der Monatsansicht.\n\n3) Beim Drehen des Gerätes in der Tages- und Wochenansicht, wechselt der Kalender zwischen der Ansicht von einem bzw. vier Tagen hin und her.",
                attributes: [
                    NSParagraphStyleAttributeName: paragraphStyle,
                    NSFontAttributeName : UIFont.systemFont(ofSize: 14),
                    NSForegroundColorAttributeName : UIColor.black
                ]
            )
            
            let alertVC = UIAlertController(title: "Anleitung", message: "", preferredStyle: .alert)
            alertVC.setValue(messageText, forKey: "attributedMessage")
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            alertVC.addAction(UIAlertAction(title: "nicht noch einmal zeigen", style: .default, handler: { (action) in
                appConfig?.kalenderErstesErscheinen = true
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
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
    init(datum:Date){
        super.init(frame: CGRect.zero)
        datumLabel.text     = datum.string("EEE dd")
        let statistik       = Meditation.getStatistics(von: datum, bis: datum)
        statistikLabel.text = statistik.timePerDay.hhmmString
        if statistik.timesPerDay > 0{
            if statistik.timePerDay >= 120*60 && statistik.timesPerDay >= 2 {
                statusLabel.text = "✅✅"
            }else{
                statusLabel.text = "☑️✅"
            }
        }else{
            statusLabel.text = "☑️☑️"
        }
        layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        layer.borderWidth = 0.5
        if datum.isSunday {
            _ = addBorder(edges: .right, colour: .red, thickness: 0.5)
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
        var labelText = ""
        if dates.count != 1{
            let mostVisibleWeek = Date.weekOfMostDays(in: dates)
            let montag          = mostVisibleWeek.mondayOfWeek
            let sonntag         = mostVisibleWeek.sundayOfWeek
            
            let wocheText = "Woche (\(montag.string("dd")).-\(sonntag.string("dd")))"
            let trenner = "    "
            let statistik = Meditation.getStatistics(von: montag, bis: sonntag)
            
            
            
            labelText = wocheText + trenner + statistik.wocheDauerLabelText
        }
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.text = labelText
        titleLabel.sizeToFit()
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
        
        let statistik       = Meditation.getStatistics(von: monat.startOfMonth.firstSecondOfDay! , bis: monat.endOfMonth.lastSecondOfDay!)
        
        let meditationText = statistik.anzahlMeditationen == 1 ? "Meditation" : "Meditationen"
        
        titleLabel.text = statistik.gesamtDauer.hhmmString + " h" + " | " + "\(statistik.anzahlMeditationen) " + meditationText + " | " + statistik.timePerDay.hhmmString + " h pro Tag"
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.sizeToFit()
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
    private var status:Int = 0
    
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    init(day _day:Date,month:Date){
        day = _day
        super.init(frame: CGRect.zero)
        dayLabel.text               = day.string("dd")
        dayLabel.sizeToFit()
        layer.borderColor           = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        layer.borderWidth           = 0.25
        
        view.backgroundColor        = UIColor.clear
        let dayIsWithinMonth        = month.startOfMonth.firstSecondOfDay?.isGreaterThanDate(dateToCompare: day) == false && day.isGreaterThanDate(dateToCompare: month.endOfMonth.lastSecondOfDay!) == false
        if dayIsWithinMonth{
            let statistik       = Meditation.getStatistics(von: day, bis: day)
            if statistik.timesPerDay > 0{
                if statistik.timePerDay >= 120*60 && statistik.timesPerDay >= 2
                { status = 2}
                else{ status = 1 }
            }
            dayLabel.textColor      = UIColor.darkText
        }else{
            dayLabel.textColor      = UIColor(white: 0, alpha: 0.1)
        }
        
        imageView.isHidden  = false
        switch status{
        case 1 :
            imageView.image     = #imageLiteral(resourceName: "buddha_black.png")
        case 2 :
            imageView.image     = #imageLiteral(resourceName: "buddha_gold.png")
        default:
            imageView.isHidden  = true
            imageView.image     = nil
        }
        
        imageView.sizeToFit()
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
