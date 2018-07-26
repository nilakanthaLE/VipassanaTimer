//
//  StatisticGraphView.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 26.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import UIKit
import ReactiveSwift

//✅
class StatisticGraphView:UIView{
    var viewModel:StatisticGraphViewModel!      { didSet{ viewModel.redraw.producer.start(){[weak self] _ in self?.setNeedsDisplay()} } }
    
    //draw
    override func draw(_ rect: CGRect) {
        print(viewModel.values.value)
        
        
        //clean
        for subView in subviews {subView.removeFromSuperview()}
        
        // values
        let width       = rect.size.width - 2 * rand
        let height      = rect.size.height - 2 * rand
        let schritte    = schritteYAchse(maxY: viewModel.maxY)

        guard schritte.schritt > 0 else {return} //erster App Start
        
        //draw action
        drawXAchse(width: width,height: height)
        drawYAchse(height: height)
        drawXAchsenBeschriftung(graphValues: viewModel.values.value, width: width, height:height)
        drawYAchsenBeschriftung(height: height, schritte: schritte)
        drawGraph(graphValues: viewModel.values.value, width: width, height: height, schritte: schritte)
    }
    
    //helper
    let rand:CGFloat  = 25.0
    private func drawXAchse(width:CGFloat,height:CGFloat){
        //x-Achse
        let xAchse = UIBezierPath()
        xAchse.move(to: CGPoint(x: rand, y: height + rand))
        xAchse.addLine(to: CGPoint(x: width + rand, y: height + rand))
        xAchse.lineWidth = 2.0
        UIColor.black.setStroke()
        xAchse.stroke()
        //Pfeil
        let pfeilX = UIBezierPath()
        pfeilX.move(to: CGPoint(x: rand + width - 5 ,   y: height + rand - 5))
        pfeilX.addLine(to: CGPoint(x: rand + width,     y: height + rand))
        pfeilX.addLine(to: CGPoint(x: rand + width - 5, y: height + rand + 5))
        pfeilX.stroke()
    }
    private func drawYAchse(height:CGFloat){
        //y-Achse
        let yAchse = UIBezierPath()
        yAchse.move(to: CGPoint(x: rand, y: rand))
        yAchse.addLine(to: CGPoint(x: rand, y: height + rand))
        yAchse.lineWidth = 2.0
        yAchse.stroke()
        //Pfeil
        let pfeilY = UIBezierPath()
        pfeilY.move(to: CGPoint(x: rand - 5 , y: rand + 5))
        pfeilY.addLine(to: CGPoint(x: rand, y: rand))
        pfeilY.addLine(to: CGPoint(x: rand + 5, y: rand + 5))
        pfeilY.stroke()
    }
    private func drawXAchsenBeschriftung(graphValues:[GraphValue],width:CGFloat,height:CGFloat){
        var lastLabel:UILabel?
        for i in 1 ... graphValues.count{
            let breite          = CGFloat(4.0)
            let schrittWeite    = width / CGFloat(graphValues.count)
            let x               = schrittWeite * CGFloat(i) + rand
            
            let strich          = UIBezierPath()
            strich.move     (to: CGPoint(x: x, y: height + rand - breite/2))
            strich.addLine  (to: CGPoint(x: x, y: height + rand + breite/2 ))
            strich.stroke()
            
            let label   = UILabel()
            label.font  = UIFont.systemFont(ofSize: 8)
            label.text  = graphValues[i-1].xLabelText
            label.sizeToFit()
            label.center.x          = x - schrittWeite / 2.0
            label.frame.origin.y    = height + rand + 2.0
            if !label.frame.intersects(lastLabel?.frame ?? CGRect.zero){
                addSubview(label)
                lastLabel = label
            }
        }
    }
    private func drawYAchsenBeschriftung(height:CGFloat,schritte:(schritt:Double,anzahlSchritte:Int)){
        let start = Date()
        defer{ print("drawYAchsenBeschriftung dauer: \(Date().timeIntervalSince(start)) s") }
        
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
                label.text  = "\((schritt * Double(i)).hhmm)"
                label.sizeToFit()
                label.frame.size.width = rand-4
                label.adjustsFontSizeToFitWidth = true
                label.center.y = y
                label.frame.origin.x = 2.0
                addSubview(label)
            }
        }
    }
    private func drawGraph(graphValues:[GraphValue],
                           width:CGFloat,height:CGFloat,
                           schritte:(schritt:Double,anzahlSchritte:Int)){
        let schrittWeite    = width / CGFloat(graphValues.count)
        let multiplikator   = Double(height) / (schritte.schritt * Double(schritte.anzahlSchritte))
        let linie           = UIBezierPath()
        linie.lineWidth     = 1.0
        let y               = height + rand - CGFloat((graphValues.first?.value ?? 0) * multiplikator)
        linie.move(to: CGPoint(x: rand, y: y))
        for graphValue in graphValues.map({$0.value}).enumerated(){
            let x = CGFloat(graphValue.offset) * schrittWeite + rand
            let y = height + rand - CGFloat(graphValue.element * multiplikator)
            linie.addLine(to: CGPoint(x: x, y: y))
            linie.addLine(to: CGPoint(x: x + schrittWeite, y: y))
        }
        UIColor.orange.setStroke()
        linie.stroke()
    }
    private func schritteYAchse(maxY:Double)->(schritt:Double,anzahlSchritte:Int){
        let start = Date()
        defer{ print("schritteYAchse dauer: \(Date().timeIntervalSince(start)) s") }
        
        guard maxY > 0 else {return (schritt:0,anzahlSchritte:0)}
        
        let primaereTeiler:[Double]  = [3600,1800,900,600]
        var maxY = maxY
        var teiler:Double?
        for _teiler in primaereTeiler{
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
    
    //layoutSubviews
    var lastFrame:CGRect?
    override func layoutSubviews() {
        if lastFrame != frame{ setNeedsDisplay() }
        lastFrame = frame
    }
}

struct GraphValue{
    let xLabelText:String?
    let value:Double
    static func xAchseString(date:Date?,takt:StatistikTakt) -> String?{
        guard let date = date else {return nil}
        switch takt{
        case .taeglich:     return date.string("dd.MM.")
        case .woechentlich: return date.mondayOfWeek.string("dd.MM") + " - " + date.sundayOfWeek.string("dd.MM")
        case .monatlich:    return date.startOfMonth.string("dd.MM") + " - " + date.endOfMonth.string("dd.MM")
        }
    }
    
}
