//
//  PublicMeditationInfoVCViewModel.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 03.06.18.
//  Copyright © 2018 Matthias Pochmann. All rights reserved.
//

import Foundation




class PublicMeditationInfoVCViewModel{
    let title:String?
    
    let model:PublicMeditationInfoViewModel
    init(model:PublicMeditationInfoViewModel){
        self.model          = model
        title               = model.title
    }
}
