//
//  WelcomeViewController.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/16.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    let logoView = UIImageView(image: UIImage(named: "Logo"))
    let signinButton = Appearance.roundRectButton("Sign in with Twitter")
    
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
        autolayout("V:|-p-[spacerT][logo]-p-[signin][spacerB(==spacerT)]-p-|")
        logoView.setContentHuggingPriorityHigh(.Vertical)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func signin(sender: AnyObject?) {
        NSLog("hoge")
    }
}
