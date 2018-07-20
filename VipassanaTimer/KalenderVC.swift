//
//  KalenderVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 26.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit
import MyCalendar
import ReactiveSwift

let meditationsKalenderEintragPressed = MutableProperty<Meditation?>(nil)

// kein refactoring ohne neue KalenderKomponente
class KalenderVC: DesignViewController,KalenderViewDelegate {
    //MARK: ViewController Lifecycle
//    private var firstAppear = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if firstAppear{
//            NotificationCenter.default.addObserver(self,
//                                                   selector: #selector(meditationsKalenderEintragPressed(notification:)),
//                                                   name: Notification.Name.MyNames.meditationsKalenderEintragPressed,
//                                                   object: nil)
//            firstAppear = false
//        }
        presentAnleitungAlertVC()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        meditationsKalenderEintragPressed.signal.filterMap{$0}.observeValues{ [weak self] meditation in self?.performSegue(withIdentifier: "editMeditation", sender: meditation) }
    }
    
    // Notification-Action
//    @objc private func meditationsKalenderEintragPressed(notification:Notification){
//        guard let meditation = notification.userInfo!["meditation"]  else {return}
//        performSegue(withIdentifier: "editMeditation", sender: meditation)
//    }

    // IBActions
    @IBAction func addMeditationButtonPressed(_ sender: UIBarButtonItem)    { performSegue(withIdentifier: "editMeditation", sender: nil) }
    
    // IBOutlets
    @IBOutlet weak var kalender: KalenderView!{
         didSet{
            kalender.delegate                   = self
            kalender.titleLabelForDay           = { (day:Date) in               KalenderTagHeader(datum: day) }
            kalender.viewForDateInMonatsView    = { (date:Date,monat:Date) in   DayViewForMonthView(day: date, month: monat) }
        }
    }

    // KalenderViewDelegate
    func getKalenderEintraegeFor(dates: [Date]) -> [[KalenderEintrag]] { return Meditation.getKalenderEintraege(days: dates) }
    func newVisibleDates(dates: [Date],showsTagesKalender:Bool) {
        if showsTagesKalender   { navigationItem.titleView = WochenKalenderTitleView(dates: dates) }
        else{
            guard let monat = dates.first else {return}
            navigationItem.titleView = MonatKalenderTitleView(monat: monat)
        }
    }
    
    // Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination.contentViewController as? EditMeditationVC)?.viewModel   = EditMeditationVCViewModel(meditation: sender as? Meditation)
    }
    @IBAction func reloadKalender(segue:UIStoryboardSegue){
        guard let editMeditationVC = segue.source.contentViewController as? EditMeditationVC, let start = editMeditationVC.viewModel.meditation?.start else{return}
        kalender.reloadKalenderTag(date:start as Date)
    }
    
    //helper
    private func presentAnleitungAlertVC(){
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
    
    deinit {  print("KalenderVC deinit") }
}










