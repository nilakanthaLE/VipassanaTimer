//
//  Extensions.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 05.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import Firebase


extension Notification.Name { enum MyNames{ static let tagInMonatsSichtPressed = Notification.Name("tagInMonatsSichtPressed") /* wird an Kalender gesendet!*/ } }
extension DataSnapshot{
    var valueAsDict:NSDictionary?       { return (value as? NSDictionary) }
    var firstValue:NSDictionary?        { return (value as? NSDictionary)?.allValues.first as? NSDictionary }
    var firstKey:String?                { return (value as? NSDictionary)?.allKeys.first as? String }
}




infix operator ~>
private let queue = DispatchQueue(label: "serial-worker")
func ~> <R> ( backgroundClosure: @escaping () -> R, mainClosure: @escaping (_ result: R) -> ()) {
    queue.async () {
        let result = backgroundClosure()
        DispatchQueue.main.async(execute: { mainClosure(result) })
    }
}
