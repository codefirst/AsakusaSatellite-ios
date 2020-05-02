//
//  AppDelegate.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/16.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite
import FirebaseCrashlytics
import Firebase
import Ikemen


let AppFullName = "AsakusaSatellite"
var appDelegate: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

private let kStringExactly = NSLocalizedString("Exactly!", comment: "")
private let kStringHuh = NSLocalizedString("Huh?", comment: "")
private let kStringReply = NSLocalizedString("Reply", comment: "")


let kURLSchemeAuthCallback = "org.codefirst.asakusasatellite"

protocol OpenURLAuthCallbackDelegate: class {
    func open(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate, UIViewControllerAnimatedTransitioning {
    var window: UIWindow?
    let root: UINavigationController
    let home: HomeViewController
    var welcome: WelcomeViewController?
    
    override init() {
        home = HomeViewController()
        root = UINavigationController(rootViewController: home)
        
        super.init()
        
        root.delegate = self // for custom animation
        if UserDefaults.apiKey == nil {
            welcome = WelcomeViewController()
            root.pushViewController(welcome!, animated: false)
        }
    }

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        Appearance.install()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = Appearance.asakusaRed
        window?.rootViewController = root
        window?.makeKeyAndVisible()
        
        registerPushNotification()

        FirebaseApp.configure()
        
        return true
    }

    // MARK: - URL Scheme

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        switch url.scheme {
        case kURLSchemeAuthCallback?:
            return (root.topViewController as? OpenURLAuthCallbackDelegate)?.open(url: url, options: options) ?? false
        default:
            return false
        }
    }

    // MARK: - Push Notification
    
    func registerPushNotification() {
        let createMessageCategory = UIMutableUserNotificationCategory() ※ { c in
            c.identifier = "CREATE_MESSAGE"
            
            let star = UIMutableUserNotificationAction() ※ { a in
                a.identifier = "star"
                a.title = "⭐️"
                a.activationMode = .background
                a.isAuthenticationRequired = false
            }
            
            let disagree = UIMutableUserNotificationAction() ※ { a in
                a.identifier = "disagree"
                a.title = kStringHuh
                a.activationMode = .background
                a.isAuthenticationRequired = false
            }
            
            let agree = UIMutableUserNotificationAction() ※ { a in
                a.identifier = "agree"
                a.title = kStringExactly
                a.activationMode = .background
                a.isAuthenticationRequired = false
            }
            
            let reply = UIMutableUserNotificationAction() ※ { a in
                a.identifier = "reply"
                a.title = kStringReply
                a.activationMode = .foreground
                a.isAuthenticationRequired = false
            }
            
            c.setActions([star, disagree, agree, reply], for: .default)
        }
        
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: [createMessageCategory])
        
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let apiKey = UserDefaults.apiKey {
            Client(apiKey: apiKey).addDevice(deviceToken, name: hwmachine() ?? UIDevice.current.model) { r in
                switch r {
                case .success(_):
                    break
                case .failure(let error):
                    UIAlertController.presentSimpleAlert(onViewController: self.root.topViewController!, title: NSLocalizedString("Cannot Register for Notifications", comment: ""), error: error)
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        UIAlertController.presentSimpleAlert(onViewController: root.topViewController!, title: NSLocalizedString("Cannot Register for Notifications", comment: ""), error: error)
    }

    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        let post = { (message: String) -> Void in
            if let roomID = userInfo["room_id"] as? String {
                Client(apiKey: UserDefaults.apiKey).postMessage(message, roomID: roomID, files: []) { _ in
                    completionHandler()
                }
            } else {
                completionHandler()
            }
        }
        
        switch identifier {
        case "star"?: post("⭐️")
        case "disagree"?: post(kStringHuh)
        case "agree"?: post(kStringExactly)
        default: completionHandler()
        }
    }
    
    // MARK: - Custom Navigation Animation
    
    internal func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .pop && fromVC is WelcomeViewController {
            return self
        }
        return nil
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC = transitionContext.viewController(forKey: .from) {
            if let toVC = transitionContext.viewController(forKey: .to) {
                transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
                UIView.animate(
                    withDuration: transitionDuration(using: transitionContext),
                    delay: 0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 0,
                    options: [],
                    animations: {
                        guard let v = fromVC.view else { return }
                        v.frame = CGRect(x: 0, y: transitionContext.containerView.frame.height, width: v.bounds.width, height: v.bounds.height)
                        v.alpha = 0.5
                    }, completion: { _ in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            }
        }
    }
}

