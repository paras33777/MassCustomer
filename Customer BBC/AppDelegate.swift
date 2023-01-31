//
//  AppDelegate.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 11/04/22.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase
import Stripe
import GoogleMaps
import GooglePlaces
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
   
var window: UIWindow?
var userDefaults = UserDefaults.standard

  
    //MARK: - *****************DID FINISH LAUNHING
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      //  statusBar()
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        
        IQKeyboardManager.shared.enable = true
//        StripeAPI.defaultPublishableKey = "pk_test_51LjyQ9AwEM7NyHue2XYFfUGvUdAxy4ibmtLbNhWcoJhCNylTSER7H40V12pgDKmshIdMGJDL42qu18fD9i6Dr9GJ00ndoBpG0u"
//        StripeAPI.defaultPublishableKey = "pk_test_51LsnPLSEv49xaenyf356h8NW6ZoUwR9GYL9vG8qfgBqBHlTAqARviKexTs0WhrTjOGfXD7ajtzV27lYIWi0XAIKn002PQs1Kqz"

        setRootController()
        if #available(iOS 15.0, *) {
        UITableView.appearance().sectionHeaderTopPadding = 2
        }
        Messaging.messaging().delegate = self
        // 1
        UNUserNotificationCenter.current().delegate = self
        // 2
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions) { _, _ in }
        // 3
        application.registerForRemoteNotifications()
        GMSPlacesClient.provideAPIKey("AIzaSyDzhF77KyULASgnwDVQj1KXs1ZjS_8pGu0")
        GMSServices.provideAPIKey("AIzaSyDzhF77KyULASgnwDVQj1KXs1ZjS_8pGu0")
        return true
    }
  

    //MARK: - *****************SET ROOT CONTROLLER
    func setRootController(){
        if let adminUser =  userDefaults.retrieve(object: Userinfo.self, fromKey: "CustomerData"){
            Singleton.sharedInstance.userInfo = adminUser
            let sboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = sboard.instantiateViewController(withIdentifier: "HomeNavi") as! UINavigationController
            window?.rootViewController = vc
        }else{
            
        }
       }
    //MARK: *****************USER ACTIVITY UNIVERSAL URL HANDLING
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // handler for Universal Links
        print("Continue User Activity called: ")
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            //handle url and open whatever page you want to open.
        }
        
        return true
    }
 
   
//MARK: *****************WILL FINISH LAUNCING
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return  true
    }
    

//MARK: ***************** Messaging Delegates

func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print("fcmToken-\(fcmToken)")
}
 
//MARK: *****************DID RECIEVE REMOTE NOtification
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    completionHandler(UIBackgroundFetchResult.newData)
}
    //MARK: *****************APPLICATION WILL RESIGN
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    //MARK: *****************DID ENTER BACKGROUND
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    //MARK: *****************WILL ENTER BACKGROUND
    func applicationWillEnterForeground(_ application: UIApplication) {
    
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    //MARK: *****************DID BECOM ACTIVE
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    //MARK: *****************WILL TERMINATE
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }




func extractUserInfo(userInfo: [AnyHashable : Any]) -> (title: String, body: String, course_id: String, tag: String) {
    var info = (title: "", body: "",course_id: "", tag: "")
    guard let aps = userInfo["aps"] as? [String: Any] else { return info }
    guard let alert = aps["alert"] as? [String: Any] else { return info }
    guard let data = aps["data"] as? [String: Any] else { return info }
    let url = data["url"] as? String ?? ""
    //  print(url)
    let title = alert["title"] as? String ?? ""
    print(title)
    let body = alert["body"] as? String ?? ""
    //  print(body)
    let course_id = alert["course_id"] as? String ?? ""
    //   print(course_id)
    //  let tag = alert["tag"] as? String ?? ""
    info = (title: title, body: body,course_id:course_id,tag:url)
    return info
}


}

//MARK: ***************** WILL PRESENT NOTIFICATION
extension AppDelegate: UNUserNotificationCenterDelegate {
func userNotificationCenter(_ center: UNUserNotificationCenter,willPresent notification: UNNotification,withCompletionHandler completionHandler:
@escaping (UNNotificationPresentationOptions) -> Void) {
  let userInfo = notification.request.content.userInfo
  print(notification.request.content)
 
  if let tag = userInfo["tag"] as? String {
      //Reload GroupList with Badge
  }
 // let info = extractUserInfo(userInfo: notification.request.content.userInfo)
completionHandler([.alert, .badge, .sound]) // Display notification as
}

func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
  Messaging.messaging().apnsToken = deviceToken
}

//MARK: *****************DID RECEIVE RESPONSE
func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
  let userInfo =  response.notification.request.content.userInfo
  print(response.notification.request.content)
  completionHandler()
//  if let tag = userInfo["tag"] as? String {
//      guard  Singleton.sharedInstance.retailerData != nil else{
//          setRootController()
//          return}
//      switch tag {
//      case "PaymentCompletedOrderGenerate_tag","PaymentCancelled_tag","OrderGenerated_tag","PaymentFailed_tag","OrderStatus_tag":
//          Singleton.sharedInstance.rediectFrom = .orderGenerated
//          Singleton.sharedInstance.notifData.contentID =  userInfo["order_id"] as? String ?? ""
//          Singleton.sharedInstance.notifData.vertical =  userInfo["vertical"] as? String ?? ""
//          setRootController()
//        default:
//          break
//        }
      completionHandler()
//   }
  }
 }

extension AppDelegate: MessagingDelegate {
func messaging(_ messaging: Messaging,didReceiveRegistrationToken fcmToken: String?) {
let tokenDict = ["token": fcmToken ?? ""]
NotificationCenter.default.post(name: Notification.Name("FCMToken"),object: nil,userInfo: tokenDict)
}
}
