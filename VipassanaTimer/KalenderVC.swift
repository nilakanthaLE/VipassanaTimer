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
    }
}

class KalenderVC: UIViewController,KalenderViewDelegate {

    //MARK: Rotation
    private var lastIsLandscape:Bool?
    private var isLandscape:Bool{ return view.frame.size.width > view.frame.size.height }
    @objc private func rotated() {
        if lastIsLandscape != isLandscape{
            kalender.visibleSections = isLandscape ? 4 : 1
            print("rotated \(isLandscape ? "landscape" : "portrait")")
        }
        lastIsLandscape = isLandscape
    }
    
    //MARK: ViewController Lifecycle
    var firstAppear = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear{
            NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
            kalender.visibleSections = isLandscape ? 4 : 1
            NotificationCenter.default.addObserver(self, selector: #selector(meditationsKalenderEintragPressed(notification:)), name: Notification.Name.MyNames.meditationsKalenderEintragPressed, object: nil)
            firstAppear = false
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
            //kalender.visibleSections    = isLandscape ? 4 : 1
            kalender.titleLabelForDay = { (day:Date) in
                return KalenderTagHeader.init(datum: day)
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
    func newVisibleDates(dates: [Date]) {
        navigationItem.titleView = KalenderTitleView(dates: dates)
        print(dates)
        print(Date.monthOfMostDays(in: dates).string("MMM").trimmingCharacters(in: ["."]).uppercased())
        
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
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class KalenderTitleView:NibLoadingView{
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
        titleLabel.text = labelText
        titleLabel.sizeToFit()
        frame = CGRect(origin: CGPoint.zero, size: titleLabel.frame.size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

