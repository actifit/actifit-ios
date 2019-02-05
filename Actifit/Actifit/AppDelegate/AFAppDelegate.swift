//
//  AFAppDelegate.swift
//  Actifit
//
//  Created by Hitender kumar on 03/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift

@UIApplicationMain
class AFAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        //Enabling IBKeyboardManager to handle keyboard for textfields and textviews
        IQKeyboardManager.shared.enable = true
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: UIUserNotificationType(rawValue: UIUserNotificationType.sound.rawValue | UIUserNotificationType.badge.rawValue | UIUserNotificationType.alert.rawValue), categories: nil))
        UIApplication.shared.applicationIconBadgeNumber = 0

        let config = Realm.Configuration(
            schemaVersion: 6,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 5) {
                    migration.enumerateObjects(ofType: Settings.className()) { oldObject, newObject in
                        newObject!["isDeviceSensorSystemSelected"] = true
                        newObject!["isSbdSPPaySystemSelected"] = true
                        newObject!["isReminderSelected"] = false
                        newObject!["fitBitMeasurement"] = false
                    }
                }
        })
        Realm.Configuration.defaultConfiguration = config
        do {
            let realm =  try Realm()
        } catch {
            
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let notification = Notification(
            name: Notification.Name(rawValue: "ACTIFIT"),
            object:nil,
            userInfo:[UIApplicationLaunchOptionsKey.url:url])
        NotificationCenter.default.post(notification)
        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: Realm Method helpers
    
    func defaultRealm() -> Realm? {
        var config = Realm.Configuration.defaultConfiguration
        config.schemaVersion = CurrentRealmSchemaVersion
        config.migrationBlock = { (migration, oldSchemaVersion) in
            if (oldSchemaVersion < 4) {
                migration.enumerateObjects(ofType: Settings.className()) { oldObject, newObject in
                    newObject!["isDeviceSensorSystemSelected"] = true
                    newObject!["isSbdSPPaySystemSelected"] = true
                    newObject!["isReminderSelected"] = false
                }
            }
        }
        do {
            let realm =  try Realm.init(configuration: config)
            return realm
        } catch {
            print("error")
        }
        return nil
    }
    
    //HELPERS
    
    //returns current day date from midnight
    func todayStartDate() -> Date {
        //For Start Date
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone.local
        let dateAtMidnight = calendar.startOfDay(for: Date())
        return dateAtMidnight
    }
    
    func startDateFor(date : Date) -> Date {
        //For Start Date
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone.local
        let dateAtMidnight = calendar.startOfDay(for: date)
        return dateAtMidnight
    }
    
    func todayLocalDate() -> Date {
        let date = Date()
        let dateFormatter = DateFormatter()
        //To prevent displaying either date or time, set the desired style to NoStyle.
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = TimeZone.current
        let localDateStr = dateFormatter.string(from: date)
        return dateFormatter.date(from: localDateStr) ?? Date()
    }
    
    func stringFromDate(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy" //Your New Date format as per requirement change it own
        let newDate = dateFormatter.string(from: date) //pass Date here
        return newDate
    }

}

