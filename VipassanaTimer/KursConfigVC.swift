//
//  KursConfigVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 11.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//
import UIKit

//✅
class KursConfigVC: DesignViewControllerPortrait {
    //IBOutlet
    @IBOutlet weak var kursConfigView: KursConfigView!
    
    //IBAction
    @IBAction func infoButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title:    NSLocalizedString("kursListenInfoTitle",comment: "kursListenInfoTitle"),
                                      message:  NSLocalizedString("kursListenInfoMessage",comment: "kursListenInfoMessage"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "E-Mail", style: .default) { _ in
            let email = "m.pochmann@icloud.com"
            if let url = URL(string: "mailto:\(email)") { UIApplication.shared.open(url) }
        })
        present(alert, animated: true, completion: nil)
    }
    
    // VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        kursConfigView.viewModel    = KursConfigViewModel()
        kursConfigView.viewModel.erstellenButtonAction.signal.observeValues{[weak self] _ in self?.navigationController?.popViewController(animated: true)}
    }
}
