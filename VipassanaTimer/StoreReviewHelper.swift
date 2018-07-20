
//  StoreReviewHelper.swift
//  Template1
//
//  Created by Apple on 14/11/17.
//  Copyright © 2017 Mobiotics. All rights reserved.
//

import StoreKit

//✅
// Bewertung der App erbitten
struct StoreReviewHelper {
    static func checkAndAskForReview() {
        //zurücksetzen auf 0 bei neuer Version
        let currentVersion  = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let ratedVersion    = AppConfig.get()?.ratedVersion
        if currentVersion != ratedVersion {
            AppConfig.get()?.starts         = 0
            AppConfig.get()?.ratedVersion   = currentVersion
        }
        
        //beim 10 und 50. start der App um Bewertung bitten
        switch AppConfig.get()?.starts ?? 0 {
        case 10,50:
            AppConfig.get()?.starts += 1 //nur einmal fragen
            StoreReviewHelper().requestReview()
        default:        print("App run count is : \(AppConfig.get()?.starts ?? 0)")
        }
    }
    private func requestReview() { if #available(iOS 10.3, *) { SKStoreReviewController.requestReview() } }
}
