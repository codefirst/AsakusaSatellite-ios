//
//  WelcomeViewController.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/16.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite


class WelcomeViewController: UIViewController {
    let logoView = UIImageView(image: UIImage(named: "Logo"))
    let signinButton = Appearance.roundRectButton("Sign in with Twitter")
    var signinVC: TwitterAuthViewController?
    
    var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = nil
        view.backgroundColor = Appearance.asakusaRed
        
        let alpha = CGFloat(0.9)
        logoView.contentMode = .ScaleAspectFit
        logoView.alpha = alpha
        signinButton.alpha = alpha
        signinButton.addTarget(self, action: "signin:", forControlEvents: .TouchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .Plain, target: self, action: "cancelSignin:")
        
        let autolayout = view.autolayoutFormat([
            "p": 20,
            ], [
                "logo": logoView,
                "signin": signinButton,
                "spacerT": AutolayoutMinView(),
                "spacerB": AutolayoutMinView(),
            ])
        view.addCenterXConstraint(logoView)
        view.addCenterXConstraint(signinButton)
        view.addEqualConstraint(.Width, view: signinButton, toView: logoView)
        autolayout("V:|-p-[spacerT][logo]-p-[signin(==44)][spacerB(==spacerT)]-p-|")
        logoView.setContentHuggingPriorityHigh(.Vertical)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        startAnimation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopAnimation()
    }
    
    // MARK: -
    
    private func startAnimation() {
        stopAnimation()
        displayLink = CADisplayLink(target: self, selector: "displayLink:")
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func displayLink(sender: CADisplayLink) {
        let time = CGFloat(NSDate().timeIntervalSince1970)
        let periodInSeconds = CGFloat(5)
        let amplitude = CGFloat(8)
        let offset = amplitude * sin(time * 2 * CGFloat(M_PI) / periodInSeconds)
        
        logoView.transform = CGAffineTransformMakeTranslation(0, offset)
    }
    
    func signin(sender: AnyObject?) {
        UserDefaults.apiKey = nil
        
        signinVC = TwitterAuthViewController(rootURL: NSURL(string: Client(apiKey: nil).rootURL)!) { apiKey in
            UserDefaults.apiKey = apiKey
            self.closeSigninViewController()
        }
        
        
        addChildViewController(signinVC!)
        view.addSubview(signinVC!.view)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        signinVC!.view.frame = CGRectMake(0, view.bounds.height, view.bounds.width, view.bounds.height)
        signinVC!.view.alpha = 0.5
        UIView.animateWithDuration(
            0.5,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: nil,
            animations: { [weak self] in
                if let s = self {
                    s.signinVC?.view.frame = s.view.bounds
                    s.signinVC?.view.alpha = 1.0
                    s.signinVC?.didMoveToParentViewController(self)
                    s.stopAnimation()
                }
                return
        }, completion: nil)
    }
    
    func cancelSignin(sender: AnyObject?) {
        closeSigninViewController()
    }
    
    func closeSigninViewController() {
        if UserDefaults.apiKey != nil {
            // signed in
            navigationController?.popViewControllerAnimated(true)
            return
        }
        
        if let vc = signinVC {
            vc.willMoveToParentViewController(nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
        navigationController?.setNavigationBarHidden(true, animated: true)
        startAnimation()
    }
}
