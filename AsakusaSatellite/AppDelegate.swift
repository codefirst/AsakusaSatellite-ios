//
//  AppDelegate.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/16.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit


let AppFullName = "AsakusaSatellite"


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
        return true
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

