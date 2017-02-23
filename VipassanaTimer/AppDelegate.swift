//
//  AppDelegate.swift
//  VipassanaTimer
//
//  Created by Matthias Pochmann on 03.01.17.
//  Copyright © 2017 Matthias Pochmann. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import AVFoundation

import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //MARK: TIMER
    var foregroundTimers = [Timer]()
    func invalidateForegroundTimers(){
        for subTimer in foregroundTimers{
            subTimer.invalidate()
        }
        foregroundTimers = [Timer]()
    }
    func scheduleForegroundTimers(){
        let backgroundInfo  = BackgroundInfo.getInfo()
        if let anapanaEnde = backgroundInfo?.anapanaEnde{
            if anapanaEnde.isGreaterThanDate(dateToCompare: Date()){
                starteSubTimer(fireAt: anapanaEnde as Date, typ: "anapana")
            }
        }
        if let vipassanaEnde = backgroundInfo?.vipassanaEnde, let ende = backgroundInfo?.meditationsEnde{
            if vipassanaEnde == ende{
                if vipassanaEnde.isGreaterThanDate(dateToCompare: Date()){
                    starteSubTimer(fireAt: vipassanaEnde as Date, typ: "ende")
                }
            }else{
                if vipassanaEnde.isGreaterThanDate(dateToCompare: Date()){
                    starteSubTimer(fireAt: vipassanaEnde as Date, typ: "vipassana")
                }
                if ende.isGreaterThanDate(dateToCompare: Date()){
                    starteSubTimer(fireAt: ende as Date, typ: "ende")
                }
            }
        }
    }
    private func starteSubTimer(fireAt:Date,typ:String){
        let timer           = Timer(fireAt: fireAt, interval: 0, target: self, selector: #selector(zeitraumBeendet(_:)), userInfo: ["typ":typ], repeats: false)
        foregroundTimers.append(timer)
        RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
    }
    @objc private func zeitraumBeendet(_ sender:Timer){
        _ = playSound()
        print("zeitraumBeendet")
    }
    func scheduleBackgroundTimers(){
        let backgroundInfo  = BackgroundInfo.getInfo()
        
        if let anapanaEnde = backgroundInfo?.anapanaEnde{
            if anapanaEnde.isGreaterThanDate(dateToCompare: Date()){
                scheduleNotification(at: anapanaEnde as Date, typ: "anapana")
            }
        }
        if let vipassanaEnde = backgroundInfo?.vipassanaEnde, let ende = backgroundInfo?.meditationsEnde{
            if vipassanaEnde == ende{
                if vipassanaEnde.isGreaterThanDate(dateToCompare: Date()){
                    scheduleNotification(at: vipassanaEnde as Date, typ: "ende")
                }
            }else{
                if vipassanaEnde.isGreaterThanDate(dateToCompare: Date()){
                    scheduleNotification(at: vipassanaEnde as Date, typ: "vipassana")
                }
                if ende.isGreaterThanDate(dateToCompare: Date()){
                    scheduleNotification(at: ende as Date, typ: "ende")
                }
            }
        }
    }
    var player: AVAudioPlayer?
    
    func playSound()->Bool{
        let url = Bundle.main.url(forResource: "klangschale", withExtension: "wav")!
        //Preparation to play
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            
            guard let player = player else { return false}
            player.setVolume(0.4, fadeDuration: TimeInterval(5))
            player.prepareToPlay()
            player.play()
            return true
        }
        catch let error as NSError {
            print(error.description)
            return false
        }
    }

    func scheduleNotification(at date: Date,typ:String) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title   = "Tutorial Reminder"
        content.body    = "\(typ) fertig"
        content.sound   = UNNotificationSound.init(named: "klangschale.wav")//default()
   
        let request = UNNotificationRequest(identifier: "textNotification\(typ)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    func removeBackgroundNotification(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
//            if !accepted {
//                print("Notification access denied.")
//            }
//        }
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        self.saveContext()
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        invalidateForegroundTimers()
//        scheduleBackgroundTimers()

        print("applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        removeBackgroundNotification()
//        scheduleForegroundTimers()
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        print("applicationWillTerminate")
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "VipassanaTimer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

