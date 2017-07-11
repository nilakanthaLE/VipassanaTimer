//
//  FreundeFindenTableVC.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 20.03.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

class FreundeFindenVC: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var freundesanfrageButton: UIButton!
    @IBAction func freundesanfrageButtonPressed(_ sender: UIButton) {
        guard let gefundenerUser = gefundenerUser else{return}
        _ = Freund.askForFriendShip(with: gefundenerUser)
        Singleton.sharedInstance.myCloudKit?.updateNow()
        _ = navigationController?.popViewController(animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        MyCloudKit.fetchUser(searchText)
    }
    var gefundenerUser:CKMeditierender?{
        didSet{
            if let gefundenerUser = gefundenerUser{
                let title = NSLocalizedString("freundesAnfrageSenden1", comment: "freundesAnfrageSenden1") + gefundenerUser.nickName! + NSLocalizedString("freundesAnfrageSenden2", comment: "freundesAnfrageSenden2")
                freundesanfrageButton.setTitle(title, for: .normal)
                freundesanfrageButton.isHidden  = false
            } else {
                freundesanfrageButton.setTitle("", for: .normal)
                freundesanfrageButton.isHidden  = true
            }
            
        }
    }
    @objc private func userSearchErgebnis(_ notification:Notification){
        let ckMeditierender = notification.userInfo?["ckMeditierender"] as? CKMeditierender
        gefundenerUser = filter(ckMeditierender)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        freundesanfrageButton.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(userSearchErgebnis(_:)), name: NSNotification.Name.MyNames.gefundenerUser, object: nil)
    }
    deinit { NotificationCenter.default.removeObserver(self)  }
    
    private func filter(_ gefundenerUser:CKMeditierender?) -> CKMeditierender?{
        if gefundenerUser == nil ||
            Freund.get(gefundenerUser!) != nil ||
            Meditierender.get()?.userID == gefundenerUser?.userRef.recordID.recordName {
            return nil
        }
        return gefundenerUser
    }
}



