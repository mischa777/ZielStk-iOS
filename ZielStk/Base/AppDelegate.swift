//
//  AppDelegate.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/9/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import UserNotifications

import AppTrackingTransparency
import AppsFlyerLib

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let gcmMessageIDKey = "gcm.message_id"
    let appLaunch = Date()
    private var isAppsFlyerReadyForSession = false
    private var isAppsFlyerATTDecisionReady = false
    private var didRequestAppsFlyerATTAuthorization = false

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UITabBar.appearance().tintColor = .ProjectDarkOrange
        application.applicationIconBadgeNumber = 0

        FirebaseApp.configure()
        setup_FirestoreDatabase()
        IAP.shared.setupPurchases(products: IAPRouter.allProductIDs)

        // EvilCode
        RConfig.shared.sync(completion: nil)
        configureAppsFlyer(launchOptions: launchOptions)

        checkAuth()
        registerPushes(application: application)

        return true
    }

    func registerPushes(application: UIApplication) {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
    }

    private func checkAuth() {
        if Auth.auth().currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let mainTabController = storyboard.instantiateViewController(withIdentifier: "MainTabController") as! UITabBarController
            window?.rootViewController = mainTabController
        }
    }

    func setAuthAsMain() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let authNavController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController") as! UINavigationController
        window?.rootViewController = authNavController
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let seconds = Int(Date().timeIntervalSince(appLaunch))
        Rate.secondsPassed += seconds
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let deutchCompilerVC = UIApplication.shared.visibleViewController as? DeutchCompilerVC {
            deutchCompilerVC.readPostedText()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    @available(iOS 9.0, *)
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "nil")")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {

        AppsFlyerLib.shared().handlePushNotification(userInfo)

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        presentAlert(userInfo)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        presentAlert(userInfo)
        completionHandler()
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        var token = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }

        print("Token: ", token)
        print("APNs token retrieved: \(token)")
        print(deviceToken)
    }

    func presentAlert(_ userInfo: [AnyHashable : Any]) {
        guard let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlertNotificationVC") as? AlertNotificationVC else {

            return
        }
        let options: [String : Any]? = userInfo["fcm_options"] as? [String : String]
        let aps: [String : Any]? = userInfo["aps"] as? [String : Any]
        let alert: [String : Any]? = aps?["alert"] as? [String : Any]


        vc.notificationImageURL = options?["image"] as? String ?? ""
        vc.notificationTitleText = alert?["title"] as? String ?? ""
        vc.notificationDescriptionText = alert?["body"] as? String ?? ""
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve

        UIApplication.getTopViewController()?.present(vc, animated: true, completion: nil)
    }
}

extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.activeKeyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

// MARK: - EvilCode
extension AppDelegate {
    private func configureAppsFlyer(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let appsFlyer = AppsFlyerLib.shared()
        appsFlyer.initialize(devKey: "sRnCjqzH5soZcPiwfGhdRJ", appId: "1480404410")
        appsFlyer.isDebug = false
        appsFlyer.delegate = self
        appsFlyer.handleLaunchOptions(launchOptions)
        appsFlyer.registerSessionReadyListener { [weak self] in
            DispatchQueue.main.async {
                self?.isAppsFlyerReadyForSession = true
                self?.startAppsFlyerIfReady()
            }
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sendLaunch),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func sendLaunch() {
        guard !didRequestAppsFlyerATTAuthorization else {
            isAppsFlyerATTDecisionReady = true
            startAppsFlyerIfReady()
            return
        }

        didRequestAppsFlyerATTAuthorization = true

        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    switch status {
                    case .notDetermined:    debugPrint("ATT is notDetermined")
                    case .restricted:       debugPrint("ATT is restricted")
                    case .denied:           debugPrint("ATT is denied")
                    case .authorized:       debugPrint("ATT is authorized")
                    @unknown default:       return
                    }

                    self?.isAppsFlyerATTDecisionReady = true
                    self?.startAppsFlyerIfReady()
                }
            }
        } else {
            isAppsFlyerATTDecisionReady = true
            startAppsFlyerIfReady()
        }
    }

    private func startAppsFlyerIfReady() {
        guard isAppsFlyerReadyForSession, isAppsFlyerATTDecisionReady else { return }

        AppsFlyerLib.shared().start()
        isAppsFlyerReadyForSession = false
    }
}

// MARK: - AppsFlyerLibDelegate
extension AppDelegate: AppsFlyerLibDelegate {

    // Handle Organic/Non-organic installation
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {

        print("")
        print("")
        print("[AppsFlyerLibDelegate]")

        if let status = installData["af_status"] as? String {

            if (status == "Non-organic") {
                if let sourceID = installData["media_source"],
                   let campaign = installData["campaign"] {
                    print("This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)")
                }
            } else {
                print("This is an organic install.")
            }

            print("[isFirstLaunch] => \(installData["is_first_launch"] as? Bool ?? false)")
        }

        print("")
        print("")
        for (key, value) in installData {
            print(key, ":", value)
        }
        print("")
        print("")
    }
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
}
