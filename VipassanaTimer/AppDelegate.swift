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
import CloudKit

import AudioToolbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    var player: AVAudioPlayer?
    func playSound()->Bool{
        //Preparation to play
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            if let klangSchaleURL = Bundle.main.url(forResource: "tibetan-bell", withExtension: "wav")
            {
                player = try AVAudioPlayer(contentsOf: klangSchaleURL)
            }
            guard let player = player else { return false}
            player.setVolume(0.3, fadeDuration: TimeInterval(0))
            player.prepareToPlay()
            player.play()
            return true
        }
        catch let error as NSError {
            print(error.description)
            return false
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Register for push notifications

        UNUserNotificationCenter.current().requestAuthorization(options:[]) { granted, error in
            if let error = error {
                print("oh: \(error.localizedDescription)")
            } else if granted {
                DispatchQueue.main.async { application.registerForRemoteNotifications() }
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let notification    = CKQueryNotification(fromRemoteNotificationDictionary: userInfo as! [String:NSObject])
//        if notification.category == "ActiveMeditation"{
//            guard let recordID  = notification.recordID else {return}
//            _ = Singleton.sharedInstance
//            Singleton.sharedInstance.cloudKitActiveMeditationsUpdater?.updateListOfActiveMeditations(recordID: recordID, reason: notification.queryNotificationReason)
//        }else
        
        if notification.category == "Freunde"{
            guard let recordID  = notification.recordID else {return}
            _ = Singleton.sharedInstance
            MyCloudKit.updateListOfFriends(recordID:recordID,reason:notification.queryNotificationReason)
        }
    }
    

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        Singleton.sharedInstance.myCloudKit?.updateNow()
        Singleton.sharedInstance.myCloudKit?.cleanMyActiveMeditations()
        self.saveContext()
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Singleton.sharedInstance.myCloudKit?.updateNow()
        Singleton.sharedInstance.myCloudKit?.cleanMyActiveMeditations()
        print("applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        print("applicationWillTerminate")
        self.saveContext()
    }
    
    static func url(for file: String, fileExtension: String? = nil) -> URL? {
        return Bundle.main.url(forResource: file, withExtension: fileExtension)
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

