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
//import Fabric
import Firebase
//import Crashlytics
import UserNotifications
import DropDown
import Localizr_swift
import GoogleMobileAds
@UIApplicationMain
class AFAppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Enabling IBKeyboardManager to handle keyboard for textfields and textviews
        //Fabric.with([Crashlytics.self])
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "xxxxxxxxxxxxxxxxxx" ]
        if UserDefaults.standard.string(forKey: "SelectedLanguage") == nil {
            Localizr.update(locale: "en")
        }
        //Localizr.update(locale: "en")
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        DropDown.startListeningToKeyboard()
        registerForPushNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let config = Realm.Configuration(
            schemaVersion: 10,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 9) {
                    migration.enumerateObjects(ofType: Settings.className()) { oldObject, newObject in
                        newObject!["isDeviceSensorSystemSelected"] = true
                        newObject!["isSbdSPPaySystemSelected"] = true
                        newObject!["isReminderSelected"] = false
                        newObject!["fitBitMeasurement"] = false
                        newObject!["appVersion"] = UIApplication.appVersion!
                        newObject!["notificationSelected"] = true
                        newObject!["hiveChain"] = ""
                        newObject!["steemChain"] = ""
                        newObject!["blurtChain"] = ""
                        
                    }
                }
            })
        Realm.Configuration.defaultConfiguration = config
        //lazy var realm:Realm = {
        //    return try! Realm()
        // }()
        
        do {
            var realm =  try Realm.init(configuration: config)
            print(realm)
        } catch {
            print("error")
        }
        
        
        notificationCenter.delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        
        if User.current()?.steemit_username == nil {
            let loginSB = UIStoryboard(name: "Login", bundle: nil)
            let loginVC = loginSB.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = loginVC
            window?.makeKeyAndVisible()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let activityVC = storyboard.instantiateViewController(withIdentifier: "ActivityTrackingVC") as! ActivityTrackingVC
            let navigationController = UINavigationController(rootViewController: activityVC)
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
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
        config.schemaVersion =  10 //CurrentRealmSchemaVersion
        config.migrationBlock = { (migration, oldSchemaVersion) in
            
            migration.enumerateObjects(ofType: Settings.className()) { oldObject, newObject in
                newObject!["isDeviceSensorSystemSelected"] = true
                newObject!["isSbdSPPaySystemSelected"] = true
                newObject!["isReminderSelected"] = false
                newObject!["fitBitMeasurement"] = false
                newObject!["appVersion"] = UIApplication.appVersion!
                newObject!["notificationSelected"] = true
                newObject!["hiveChain"] = ""
                newObject!["steemChain"] = ""
                newObject!["blurtChain"] = ""
                
            }
            
        }
        do {
            Realm.Configuration.defaultConfiguration = config
            // lazy var realm:Realm = {
            //     return try! Realm()
            // }()
            let realm =  try Realm.init(configuration: config)
            return realm
        } catch let error {
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
        
        //        let currentDate = Date()
        //        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        //        let epochDate = currentDate.timeIntervalSince1970
        //        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        //        let timeZoneOffsetDate = Date(timeIntervalSince1970: timezoneEpochOffset)
        //        return timeZoneOffsetDate
        
        
        
    }
    
    func yesterdayStartDate() -> Date {
        let currentDate = Date()
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = currentDate.timeIntervalSince1970
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        let timeZoneOffsetDate = Date(timeIntervalSince1970: timezoneEpochOffset)
        return timeZoneOffsetDate
    }
    
    
    
    
    func startDateFor(date : Date) -> Date {
        //For Start Date
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone.local
        let dateAtMidnight = calendar.startOfDay(for: date)
        return dateAtMidnight
        
        //        let currentDate = date //Date()
        //        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        //        let epochDate = currentDate.timeIntervalSince1970
        //        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        //        let timeZoneOffsetDate = Date(timeIntervalSince1970: timezoneEpochOffset)
        //        return timeZoneOffsetDate
        
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

extension AFAppDelegate:MessagingDelegate{
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                granted, error in
                print("Permission granted: \(granted)") // 3
                guard granted else { return }
                self.getNotificationSettings()
            }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let userName = User.current()?.steemit_username {
            let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
            let token = tokenParts.joined()
            // UserDefaults.standard.set("\(token)", forKey: HCConstants.DeviceTokan)
            Messaging.messaging().apnsToken = deviceToken
            let str =  Messaging.messaging().fcmToken
            print("Device Token: \(token)")
            UserDefaults.standard.setValue(str, forKey: "DeviceToken")
            //Messaging.messaging().subscribe(toTopic: "actidefnots")
            Messaging.messaging().subscribe(toTopic: "actidefnots") { error in
                print(error)
            }
            API().registerNotification(info: ["user": userName, "token" : str, "app": "iOS"]) { info, statusCode in
                print(statusCode)
            } failure: { error in
                print(error)
            }
        }
        
        // UserdefaultStore.USERDEFAULTS_SET_STRING_KEY(object: str!, key: "DeviceToken")
    }
    
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Failed to register: \(error)")
        }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
}




extension AFAppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if UserDefaults.standard.bool(forKey: "notifications") == false{
            completionHandler([])
        }
        else{
            completionHandler([.alert, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }
        
        completionHandler()
    }
    
    func scheduleNotification(steps: Int) {
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
        let categoryIdentifire = "Delete Notification Type"
        
        content.title = "Actifit"
        if steps == 5{
            content.body = "Congrats On Reaching \(steps)K Milestone. Keep Going!"
        }else{
            content.body = "Congrats On Reaching \(steps)K Milestone. Well Done!"
        }
        
        content.sound = UNNotificationSound.default()
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
    }
}
