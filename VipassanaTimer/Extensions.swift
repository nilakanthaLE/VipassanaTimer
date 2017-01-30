//
//  Extensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Foundation
import UIKit





extension UIViewController{
    var contentViewController:UIViewController {
        if let navCon = self as? UINavigationController{
            return navCon.visibleViewController ?? navCon
        }else{
            return self
        }
    }
}
extension Date{
    var isSunday:Bool{
        return istGleicherTag(wie: sundayOfWeek)
    }
    var mondayOfWeek:Date{
        let gregorian               = Calendar.current
        let weekdayComponents       = gregorian.component(.weekday, from: self)
        var compontentsToSubstract  = DateComponents()
        compontentsToSubstract.day  = -(weekdayComponents - gregorian.firstWeekday)
        compontentsToSubstract.day  = compontentsToSubstract.day == 1 ? -6 : compontentsToSubstract.day
        var beginningOfWeek         = gregorian.date(byAdding: compontentsToSubstract, to: self)
        let components              = gregorian.dateComponents([.year,.month,.day], from: beginningOfWeek!)
        beginningOfWeek             = gregorian.date(from: components)
        return beginningOfWeek!
    }
    var sundayOfWeek:Date{
        
        return mondayOfWeek.addDays(6)
    }
    func addDays(_ days:Int) -> Date{
        let cal             = Calendar.current
        return (cal as NSCalendar).date(byAdding: .day, value: days, to: self, options: .matchFirst)!
    }
    func string(_ format:String)->String{
        let formatter           = DateFormatter()
        formatter.dateFormat    = format
        formatter.locale        = Locale(identifier: "de")
        return formatter.string(from: self)
    }
    var firstSecondOfDay:Date?{
        let cal             = Calendar.current
        return (cal as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: self, options: .matchFirst)
    }
    func istGleicherTag(wie day:Date)->Bool{
        return self.isGreaterThanDate(dateToCompare: day.addDays(-1).lastSecondOfDay!) && day.addDays(1).firstSecondOfDay!.isGreaterThanDate(dateToCompare: self)
    }
    func isGreaterThanDate(dateToCompare:Date) -> Bool {
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            return true
        }
        return false
    }
    var lastSecondOfDay:Date?{
        let cal             = Calendar.current
        return (cal as NSCalendar).date(bySettingHour: 23, minute: 59, second: 59, of: self, options: .matchFirst)
    }
    
}
extension Int{
    var stringWithStartingZero:String{
        return self < 10 ? "0\(self)" : "\(self)"
    }
}

extension UIView{
    func addBorder(edges: UIRectEdge, colour: UIColor = UIColor.white, thickness: CGFloat = 1) -> [UIView] {
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRect.zero)
            border.backgroundColor = colour
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]", options: [], metrics: ["thickness": thickness], views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|", options: [], metrics: nil, views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]", options: [], metrics: ["thickness": thickness], views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|", options: [], metrics: nil, views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",
                                               options: [],
                                               metrics: ["thickness": thickness],
                                               views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|",
                                               options: [],
                                               metrics: nil,
                                               views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
}





extension Date {
    var secondOfDay:Int{
        return Int(timeIntervalSince(firstSecondOfDay!))
    }

    static func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day! + 1
    }

    static func weekOfMostDays(in array:[Date])->Date{
        guard let first = array.first, let last = array.last, let sonntagDerWocheDesErstenTages = first.sundayOfWeek.lastSecondOfDay else{return Date()}
        var anzahlTageVorSonntag = 0
        for date in array{
            if sonntagDerWocheDesErstenTages.isGreaterThanDate(dateToCompare: date){
                anzahlTageVorSonntag += 1
            }
        }
        return anzahlTageVorSonntag >= 2 ? first : last
    }
    
    static func monthOfMostDays(in array:[Date])->Date{
        var ersterMonat     = 0
        var zweiterMonat    = 0
        let nrErsterMonat   = array.first!.string("MMM")
        for date in array{
            let dateMonth = date.string("MMM")
            if dateMonth == nrErsterMonat{
                ersterMonat += 1
            }else{
                zweiterMonat += 1
            }
        }
        return ersterMonat >= zweiterMonat ? array.first! : array.last!
    }
}

extension NSDate {
    func isGreaterThanDate(dateToCompare:Date) -> Bool {
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            return true
        }
        return false
    }
    var secondOfDay:Int{
        
        return Int(timeIntervalSince(firstSecondOfDay!))
    }
    var firstSecondOfDay:Date?{
        let cal             = Calendar.current
        return (cal as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: self as Date, options: .matchFirst)
    }
}

extension Double{
    var stunden:Int{
        return Int(Int(self) / 60 / 60)
    }
    var minuten:Int{
        return Int((Int(self) - (stunden * 3600)) / 60)
    }
    var sekunden:Int{
        return Int(Int(self) - (stunden * 3600) - (minuten * 60))
    }
    var hhmmString:String{
        return "\(self.stunden):\(self.minuten.stringMit0)"
    }
    var hhmmssString:String{
        return "\(self.stunden):\(self.minuten.stringMit0):\(self.sekunden.stringMit0)"
    }
    var zweiKommaStellenString:String{
        let hundertfach = Int(self*100)
        return "\(Double(hundertfach) / 100.0)"
    }
}
extension Int{
    var stringMit0:String{
        return self < 10 ? "0\(self)" : "\(self)"
    }
}
