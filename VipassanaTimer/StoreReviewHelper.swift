
//  StoreReviewHelper.swift
//  Template1
//
//  Created by Apple on 14/11/17.
//  Copyright © 2017 Mobiotics. All rights reserved.
//
import Foundation
import StoreKit

struct StoreReviewHelper {
    static func checkAndAskForReview() {
        // call this whenever appropriate
        let currentVersion  = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let ratedVersion    = AppConfig.get()?.ratedVersion
        
        
        //zurücksetzen auf 0 bei neuer Version
        if currentVersion != ratedVersion {
            AppConfig.get()?.starts         = 0
            AppConfig.get()?.ratedVersion   = currentVersion
        }
        
        guard let appStarts       = AppConfig.get()?.starts else {return}

        switch appStarts {
        case 10,50:
            AppConfig.get()?.starts += 1 //nur einmal fragen
            StoreReviewHelper().requestReview()
        default:        print("App run count is : \(appStarts)")
        }
    }
    
    fileprivate func requestReview() {
        if #available(iOS 10.3, *) { SKStoreReviewController.requestReview() }
        else {
            // Fallback on earlier versions
            // Try any other 3rd party or manual method here.
        }
    }
}
