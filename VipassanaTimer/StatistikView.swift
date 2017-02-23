//
//  StatistikView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 31.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit

enum GraphenTyp{
    case Linie
    case LiniePlateau
    case BalkenIneinander
    case BalkenNebeneinander
}

@IBDesignable
class StatistikView: UIView {
    var werte : [[Double]]?{
        didSet{
            setMinMax()
            
            setNeedsDisplay()
        }
    }
    var farben: [UIColor]?
    var primaereTeiler:[Double]?
    var achsenBeschriftung:(xAchse:String,yAchse:String)?
    var yAchseLabelsText : (Double)->String = {
        (wert:Double) in return "\(wert)"
    }
    var xAchsenLabel: [String]?
    
    //MARK: min/max
    private var maxY:Double?
    private var minY:Double?
    private func setMinMax(){
        guard let werte = werte else {return}
        var maxOfSubarrays = [Double]()
        var minOfSubarrays = [Double]()
        for subArray in werte{
            maxOfSubarrays.append(subArray.max() ?? 0.0)
            minOfSubarrays.append(subArray.min() ?? 0.0)
        }
        maxY = maxOfSubarrays.max()
        minY = minOfSubarrays.min()
        if maxY == 0 && minY == 0{
            maxY = nil
            minY = nil
        }
    }
    deinit {
        print("deinit StatistikView")
    }
    var lastFrame:CGRect?
    override func layoutSubviews() {
        if lastFrame != frame{
            setNeedsDisplay()
        }
        lastFrame = frame
    }
    
    let rand:CGFloat  = 25.0
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        for subview in subviews{subview.removeFromSuperview()}
        
        guard let maxY = maxY, let minY = minY else{return}
        
        let height      = rect.size.height - 2 * rand
        let width       = rect.size.width - 2 * rand
        
        //x-Achse
        //y-Position der x-Achse
        var posY0 : CGFloat
        if maxY < 0.0{ posY0 = 0.0
        }else if minY > 0.0{ posY0 = height + rand
        }else{ posY0 = height / CGFloat((abs(maxY) + abs(minY))) * CGFloat(abs(maxY))  + rand }
        
        let xAchse = UIBezierPath()
        xAchse.move(to: CGPoint(x: rand, y: posY0))
        xAchse.addLine(to: CGPoint(x: width + rand, y: posY0))
        xAchse.lineWidth = 2.0
        UIColor.black.setStroke()
        xAchse.stroke()
        //kleine Striche && Labels
        var lastLabel:UILabel?
        for i in 1 ... (werte?.first?.count ?? 0){
            let breite          = CGFloat(4.0)
            let schrittWeite    = width / CGFloat(werte?.first?.count ?? 1)
            let strich          = UIBezierPath()
            let x               = schrittWeite * CGFloat(i) + rand
            strich.move(to: CGPoint(x: x, y: posY0 - breite/2))
            strich.addLine(to: CGPoint(x: x, y: posY0 + breite/2 ))
            strich.stroke()
            
            let label   = UILabel()
            label.font  = UIFont.systemFont(ofSize: 8)
            label.text  = xAchsenLabel?[i-1] ?? ""
            label.sizeToFit()
            label.center.x          = x - schrittWeite / 2.0
            label.frame.origin.y    = posY0 + 2.0
            if !label.frame.intersects(lastLabel?.frame ?? CGRect.zero){
                addSubview(label)
                lastLabel = label
            }
        }
        
        //Pfeil
        var pfeil = UIBezierPath()
        pfeil.move(to: CGPoint(x: rand + width - 5 , y: posY0 - 5))
        pfeil.addLine(to: CGPoint(x: rand + width, y: posY0))
        pfeil.addLine(to: CGPoint(x: rand + width - 5, y: posY0 + 5))
        pfeil.stroke()
        
        
        //y-Achse
        let yAchse = UIBezierPath()
        yAchse.move(to: CGPoint(x: rand, y: rand))
        yAchse.addLine(to: CGPoint(x: rand, y: height + rand))
        yAchse.lineWidth = 2.0
        yAchse.stroke()
        
        let schritte        = schritteYAchse(maxY: maxY)
        let schritt         = schritte.schritt
        let anzahlSchritte  = schritte.anzahlSchritte
        let schrittHoehe    = height / CGFloat(anzahlSchritte)
        //kleine Striche && Labels
        for i in 1 ... anzahlSchritte{
            if i < anzahlSchritte{
                let breite  = CGFloat(4.0)
                let strich  = UIBezierPath()
                let y       = height - schrittHoehe * CGFloat(i) + rand
                strich.move(to: CGPoint(x: -breite/2 + rand, y: y))
                strich.addLine(to: CGPoint(x: breite/2 + rand, y: y))
                strich.stroke()
                
                let label   = UILabel()
                label.text  = yAchseLabelsText(schritt * Double(i))
                label.sizeToFit()
                label.frame.size.width = rand-4
                label.adjustsFontSizeToFitWidth = true
                label.center.y = y
                label.frame.origin.x = 2.0
                addSubview(label)
            }
        }
        //Pfeil
        pfeil = UIBezierPath()
        pfeil.move(to: CGPoint(x: rand - 5 , y: rand + 5))
        pfeil.addLine(to: CGPoint(x: rand, y: rand))
        pfeil.addLine(to: CGPoint(x: rand + 5, y: rand + 5))
        pfeil.stroke()
        
        let label = UILabel()
        label.text = achsenBeschriftung?.yAchse ?? "?"
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 2.0, y: 0.0)
        label.font = UIFont.systemFont(ofSize: 12)
        addSubview(label)
        
        //Werte-Graph
        guard let werte     = werte else {return}
        let schrittWeite    = width / CGFloat(werte[0].count)
        let multiplikator   = Double(height) / (schritt * Double(anzahlSchritte))
        var i = 0
        for subArray in werte{
            let linie       = UIBezierPath()
            linie.lineWidth = 1.0
            linie.move(to: CGPoint(x: rand, y: posY0 - CGFloat(subArray[0] * multiplikator)))
            var j = 1
            for wert in subArray{
                linie.addLine(to: CGPoint(x: CGFloat(j) * schrittWeite + rand, y: posY0 - CGFloat(wert * multiplikator)))
                let y = CGFloat(subArray.count > j ? Double(posY0) - subArray[j] * multiplikator : Double(posY0) - wert * multiplikator)
                linie.addLine(to: CGPoint(x: CGFloat(j) * schrittWeite + rand, y: y))
                j += 1
            }
            
            if i < farben?.count ?? 0{
                farben?[i].setStroke()
            }else{
                UIColor.black.setStroke()
            }
            linie.stroke()
            i += 1
        }
    }
    private func schritteYAchse(maxY:Double)->(schritt:Double,anzahlSchritte:Int){
        var maxY = maxY
        var teiler:Double?
        for _teiler in primaereTeiler ?? [Double](){
            if maxY / _teiler >= 10{
                maxY = maxY / _teiler
                teiler = _teiler
                break
            }
        }
        
        
        let zehntel = maxY/10.0
        var schritt = zehntel
        var multiplier:Double = 1.0
        if zehntel < 1{
            while schritt < 1 || schritt > 10{
                schritt *= 10
                multiplier /= 10
            }
        }else{
            while schritt < 1 || schritt > 10{
                schritt /= 10
                multiplier *= 10
            }
        }
        schritt             = Double(Int(schritt)) * multiplier
        let anzahlSchritte  = Int(maxY / schritt) + 1
        return (schritt:schritt * (teiler ?? 1),anzahlSchritte:anzahlSchritte)
    }

}
