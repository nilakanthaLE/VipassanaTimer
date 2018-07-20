//
//  ProfilPublicVorschauVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 06.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
class ProfilPublicVorschauVC:DesignViewControllerPortrait{
    var viewModel:PublicMeditationInfoViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title                               = viewModel.title
        publicMeditationInfoView.viewModel  = viewModel
    }
    @IBOutlet weak var publicMeditationInfoView: PublicMeditationInfoView!
    @IBAction func zurueckButtonPressed(_ sender: UIBarButtonItem)          { dismiss(animated: true, completion: nil)  }
    deinit { print("deinit ProfilPublicVorschauVC") }
}
