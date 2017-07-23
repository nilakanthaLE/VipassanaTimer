//
//  FreundeFindenTableVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 20.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit
import Firebase

extension UISearchBar{
    func setTransparent(){
        backgroundColor   = UIColor.clear
        backgroundImage   = UIImage()
        alpha             = 1
        isTranslucent     = true
    }
}
class FreundeFindenVC: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!          { didSet{ searchBar.setTransparent() } }
    @IBOutlet weak var freundesanfrageButton: UIButton! { didSet { freundesanfrageButton.setControlDesignPatterns() } }
    
    @IBAction func freundesanfrageButtonPressed(_ sender: UIButton) {
        guard let gefundenerUser = gefundenerUser else{return}
        FirUserConnections.createFreundesanfrage(withUserDict:gefundenerUser)
        _ = navigationController?.popViewController(animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { FirUser.getUser(byNickname: searchText) }
    override func viewDidLoad() {
        super.viewDidLoad()
        freundesanfrageButton.isHidden              = true
        Singleton.sharedInstance.userWurdeGefunden  = userWurdeGefunden
        view.backgroundColor = DesignPatterns.mainBackground
    }
    
    
    private func userWurdeGefunden(){ gefundenerUser = Singleton.sharedInstance.gefundenerUser }
    var gefundenerUser:NSDictionary?{
        didSet{
            if let nickName = gefundenerUser?["spitzname"] as? String{
                let title = NSLocalizedString("freundesAnfrageSenden1", comment: "freundesAnfrageSenden1") + nickName + NSLocalizedString("freundesAnfrageSenden2", comment: "freundesAnfrageSenden2")
                freundesanfrageButton.setTitle(title, for: .normal)
                freundesanfrageButton.isHidden  = false
            } else {
                freundesanfrageButton.setTitle("", for: .normal)
                freundesanfrageButton.isHidden  = true
            }
        }
    }
    deinit { print ("deinit FreundeFindenVC") }
}



