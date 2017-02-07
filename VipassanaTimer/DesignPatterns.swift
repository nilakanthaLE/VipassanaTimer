//
//  DesignPatterns.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 16.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit

struct DesignPatterns{
    private static let font     = UIFont.systemFont(ofSize: 12)
    
    static let gelb     = UIColor(red: 255.0/255.0, green: 204.0/255.0, blue: 51.0/255.0, alpha: 1)
    static let darkBlue = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1)
    static let mocha    = UIColor(red: 128.0/255.0, green: 64.0/255.0, blue: 0.0, alpha: 1)
    
    
    static let tageView     = Design(font: UIFont.systemFont(ofSize: 18), textAlignment: .center, textColor: gelb)
    static let stundenLabel = Design(font: UIFont.systemFont(ofSize: 12), textAlignment: .right, textColor: gelb)
    
    static let standardButton   = LayerDesign(borderColor: DesignPatterns.mocha, borderWidth: 0.5, cornerRadius: 2)
}
struct LayerDesign{
    let borderColor:UIColor
    let borderWidth:CGFloat
    let cornerRadius:CGFloat
}
struct Design{
    let font:UIFont                     //      = UIFont.systemFont(ofSize: 12)
    let textAlignment:NSTextAlignment   //      = NSTextAlignment.center
    let textColor:UIColor               //      = UIColor.white
}
extension UILabel{
    func set(design:Design){
        textAlignment   = design.textAlignment
        textColor       = design.textColor
        font            = design.font
    }
}
extension UIButton{
    func set(layerDesign:LayerDesign){
        layer.borderColor   = layerDesign.borderColor.cgColor
        layer.borderWidth   = layerDesign.borderWidth
        layer.cornerRadius  = layerDesign.cornerRadius
    }
}
