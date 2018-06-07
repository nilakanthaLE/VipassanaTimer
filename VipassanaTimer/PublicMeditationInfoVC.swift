//
//  PublicMeditationInfoVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 03.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

class PublicMeditationInfoVC:UIViewController{
    var viewModel:PublicMeditationInfoViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor            = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        navigationController?.navigationBar.setDesignPattern()
        title                           = viewModel.title
    }
    @IBOutlet weak var publicMeditationInfoView: PublicMeditationInfoView!{
        didSet{ publicMeditationInfoView.viewModel = viewModel }
    }
    @IBAction func zurueckButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
