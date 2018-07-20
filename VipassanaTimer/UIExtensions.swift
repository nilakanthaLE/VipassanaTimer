//
//  UIExtensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 19.07.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit

//✅
//Design
extension UIView{
    func setStandardDesign(){
        layer.borderColor     = standardRahmenFarbe.cgColor
        layer.borderWidth     = standardBorderWidth
        layer.cornerRadius    = standardCornerRadius
        clipsToBounds         = true
    }
}
extension UINavigationBar{
    func setDesignPattern(){
        barTintColor        = standardBackgroundFarbe
        tintColor           = standardSchriftFarbe
        titleTextAttributes = [NSAttributedStringKey.foregroundColor: standardSchriftFarbe]
    }
}
extension UISearchBar{
    func setTransparent(){
        backgroundColor   = UIColor.clear
        backgroundImage   = UIImage()
        alpha             = 1
        isTranslucent     = true
    }
}

// die Schriftgröße anpassen - für kurze Strings
extension UIFont{
    func getFontSize(for string:String?, in rect:CGRect) -> CGFloat{
        var ergebnis:CGFloat = 0
        let label       = UILabel()
        label.text      = string ?? "?"
        label.font      = UIFont(name: self.fontName, size: 10)
        label.sizeToFit()
        repeat {
            ergebnis    = label.font.pointSize + 0.5
            label.font  = UIFont(name: self.fontName, size: ergebnis )
            label.sizeToFit()
        } while (label.frame.height < rect.height)
        return ergebnis
    }
}

//ContentViewController ermitteln
// für segues
extension UIViewController{
    var contentViewController:UIViewController {
        if let navCon = self as? UINavigationController { return navCon.visibleViewController ?? navCon }
        else    { return self  }
    }
}

//
extension UINavigationController {
    open override var shouldAutorotate: Bool{ return true }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if visibleViewController is UIAlertController{ return UIInterfaceOrientationMask.allButUpsideDown }
        return visibleViewController!.supportedInterfaceOrientations
    }
}
