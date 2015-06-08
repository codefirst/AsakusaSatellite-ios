//
//  AppDelegate.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/16.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite


let AppFullName = "AsakusaSatellite"
var appDelegate: AppDelegate { return UIApplication.sharedApplication().delegate as! AppDelegate }


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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Appearance.install()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = Appearance.asakusaRed
        window?.rootViewController = root
        window?.makeKeyAndVisible()
        
        registerPushNotification()
        
        return true
    }
    
    // MARK: - Push Notification
    
    func registerPushNotification() {
        let createMessageCategory = UIMutableUserNotificationCategory().tap { (c: UIMutableUserNotificationCategory) in
            c.identifier = "CREATE_MESSAGE"
            
            let star = UIMutableUserNotificationAction().tap { (a: UIMutableUserNotificationAction) in
                a.identifier = "star"
                a.title = "⭐️"
                a.activationMode = .Background
                a.authenticationRequired = false
            }
            
            let disagree = UIMutableUserNotificationAction().tap { (a: UIMutableUserNotificationAction) in
                a.identifier = "disagree"
                a.title = NSLocalizedString("えっ", comment: "")
                a.activationMode = .Background
                a.authenticationRequired = false
            }
            
            let agree = UIMutableUserNotificationAction().tap { (a: UIMutableUserNotificationAction) in
                a.identifier = "agree"
                a.title = NSLocalizedString("それな", comment: "")
                a.activationMode = .Background
                a.authenticationRequired = false
            }
            
            let reply = UIMutableUserNotificationAction().tap { (a: UIMutableUserNotificationAction) in
                a.identifier = "reply"
                a.title = NSLocalizedString("Reply", comment: "")
                a.activationMode = .Foreground
                a.authenticationRequired = false
            }
            
            c.setActions([star, disagree, agree, reply], forContext: .Default)
        }
        
        let settings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: [createMessageCategory])
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        if let apiKey = UserDefaults.apiKey {
            Client(apiKey: apiKey).addDevice(deviceToken, name: hwmachine() ?? UIDevice.currentDevice().model) { r in
                switch r {
                case .Success(_):
                    break
                case .Failure(let error):
                    UIAlertController.presentSimpleAlert(onViewController: self.root.topViewController, title: NSLocalizedString("Cannot Register for Notifications", comment: ""), error: error)
                }
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        UIAlertController.presentSimpleAlert(onViewController: root.topViewController, title: NSLocalizedString("Cannot Register for Notifications", comment: ""), error: error)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {

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
        case .Some("star"): post("⭐️")
        case .Some("disagree"): post(NSLocalizedString("えっ", comment: ""))
        case .Some("agree"): post(NSLocalizedString("それな", comment: ""))
        default: completionHandler()
        }
    }
    
    // MARK: - Custom Navigation Animation
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .Pop && fromVC is WelcomeViewController {
            return self
        }
        return nil
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) {
            if let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) {
                transitionContext.containerView().insertSubview(toVC.view, belowSubview: fromVC.view)
                UIView.animateWithDuration(
                    transitionDuration(transitionContext),
                    delay: 0,
                    usingSpringWithDamping: 1.0,
                    initialSpringVelocity: 0,
                    options: nil,
                    animations: {
                        let v = fromVC.view
                        v.frame = CGRectMake(0, transitionContext.containerView().frame.height, v.bounds.width, v.bounds.height)
                        v.alpha = 0.5
                    }, completion: { _ in
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
                })
            }
        }
    }
}

