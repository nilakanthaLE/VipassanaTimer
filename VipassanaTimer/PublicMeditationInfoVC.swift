//
//  PublicMeditationInfoVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 03.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
class PublicMeditationInfoVCViewModel{
    let title:String?
    init(model:PublicMeditationInfoViewModel){ title = model.title  }
}

//✅
class PublicMeditationInfoVC:DesignViewControllerPortrait{
    var viewModel:PublicMeditationInfoViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title   = viewModel.title
        publicMeditationInfoView.viewModel = viewModel
    }
    @IBOutlet weak var publicMeditationInfoView: PublicMeditationInfoView!
    @IBAction func zurueckButtonPressed(_ sender: UIBarButtonItem) { dismiss(animated: true, completion: nil) }
    deinit { print("deinit PublicMeditationInfoVC") }
}
