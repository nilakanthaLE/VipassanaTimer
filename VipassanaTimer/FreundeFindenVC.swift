//
//  FreundeFindenTableVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 20.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//
import UIKit
import ReactiveSwift

//✅
class FreundeFindenVC: DesignViewControllerPortrait,UISearchBarDelegate {
    var viewModel:FreundeFindenVCModel!
    
    //IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var freundesanfrageButton: UIButton!
    
    //IBActions
    @IBAction func freundesanfrageButtonPressed(_ sender: UIButton) {
        viewModel.freundschaftAnfragen()
        _ = navigationController?.popViewController(animated: true)
    }

    // VC LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.setTransparent()
        freundesanfrageButton.setStandardDesign()
        
        freundesanfrageButton.reactive.isHidden <~ viewModel.freundAnfragenButtonIsHidden.producer
        freundesanfrageButton.reactive.title    <~ viewModel.freundAnfragenButtonTitel.producer
        
        viewModel.searchString                  <~ searchBar.reactive.continuousTextValues
    }
    
    deinit { print ("deinit FreundeFindenVC") }
}



