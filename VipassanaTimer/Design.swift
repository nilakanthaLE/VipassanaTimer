//
//  Design.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 28.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit



//✅
//MARK. DesignViewController
class DesignViewController:UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor            = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        navigationController?.navigationBar.setDesignPattern()
    }
}
class DesignViewControllerPortrait: DesignViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait  }
}
class DesignTableViewControllerPortrait: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor            = UIColor(patternImage: #imageLiteral(resourceName: "backGroundImage.png"))
        navigationController?.navigationBar.setDesignPattern()
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return UIInterfaceOrientationMask.portrait  }
}

//✅
//MARK: Farben und andere DesignWerte
let standardRahmenFarbe:UIColor     = #colorLiteral(red: 0.4301173091, green: 0.3185519278, blue: 0.162393868, alpha: 1)
let standardSchriftFarbe:UIColor    = #colorLiteral(red: 0.4301173091, green: 0.3185519278, blue: 0.162393868, alpha: 1)
let standardBackgroundFarbe:UIColor = #colorLiteral(red: 1, green: 1, blue: 0.7958007392, alpha: 0.6631528253)
let standardBorderWidth:CGFloat     = 1
let standardCornerRadius:CGFloat    = 5

//Freunde bestätigen
let gruen   = UIColor(red: 102.0/255.0, green: 153.0/255.0, blue: 51.0/255.0, alpha: 1)

//Hintergrundfarbe für den Header der TableViews bei Freunden
let headerBackground     = UIColor(red: 1, green: 1, blue:  204.0/255.0, alpha: 1)
