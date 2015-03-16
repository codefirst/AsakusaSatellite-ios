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
    
    var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Appearance.barTintColor
        
        let alpha = CGFloat(0.9)
        logoView.contentMode = .ScaleAspectFit
        logoView.alpha = alpha
        signinButton.alpha = alpha
        signinButton.addTarget(self, action: "signin:", forControlEvents: .TouchUpInside)
        
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
        
        startAnimation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
        let vc = TwitterAuthViewController(rootURL: NSURL(string: Client(apiKey: nil).rootURL)!) { apiKey in
            NSLog("apiKey: \(apiKey)")
        }
        
        presentViewController(vc, animated: true, completion: nil)
    }
}
