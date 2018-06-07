//
//  GeradeMaeditiertModel.swift
//  Vipassana
//
//  Created by Matthias Pochmann on 28.05.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation
import ReactiveSwift

class GeradeMeditiertModel{
    let aktuelleMeditationen    = MutableProperty<[PublicMeditation]>([PublicMeditation]())
    let nextEndeDate            = MutableProperty<(user: String?, ende: Date)?>(nil)
    init(){
        print("init GeradeMeditiertModel")
        aktuelleMeditationen    <~ fireBaseModel.aktuelleMeditationen
    }
    

    
    deinit { print("deinit GeradeMeditiertModel") }
}
