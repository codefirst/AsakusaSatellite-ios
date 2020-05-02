//
//  WelcomeViewController.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/16.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite
import NorthLayout
import SafariServices
import Ikemen


class WelcomeViewController: UIViewController, OpenURLAuthCallbackDelegate {
    let logoView = UIImageView(image: UIImage(named: "Logo"))
    let signinButton = Appearance.roundRectButtonOnTintColor("Sign in with Twitter")
    private var auth: Auth?
    
    var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        view.backgroundColor = Appearance.asakusaRed
        
        let alpha = CGFloat(0.9)
        logoView.contentMode = .scaleAspectFit
        logoView.alpha = alpha
        signinButton.alpha = alpha
        signinButton.addTarget(self, action: #selector(signin), for: .touchUpInside)
        
        let autolayout = view.northLayoutFormat([
            "p": 20,
            ], [
                "logo": logoView,
                "signin": signinButton,
                "spacerT": AutolayoutMinView(),
                "spacerB": AutolayoutMinView(),
            ])
        view.addCenterXConstraint(view: logoView)
        view.addCenterXConstraint(view: signinButton)
        view.addEqualConstraint(attribute: .width, view: signinButton, toView: logoView)
        autolayout("V:|-p-[spacerT][logo]-p-[signin(==44)][spacerB(==spacerT)]-p-|")
        logoView.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .vertical)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {return .lightContent}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        startAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopAnimation()
    }
    
    // MARK: -
    
    fileprivate func startAnimation() {
        stopAnimation()
        displayLink = CADisplayLink(target: self, selector: #selector(displayLink(_:)))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc func displayLink(_ sender: CADisplayLink) {
        let time = CGFloat(NSDate().timeIntervalSince1970)
        let periodInSeconds = CGFloat(5)
        let amplitude = CGFloat(8)
        let offset = amplitude * sin(time * 2 * CGFloat.pi / periodInSeconds)
        
        logoView.transform = CGAffineTransform(translationX: 0, y: offset)
    }

    // MARK: - Auth and OpenURLAuthCallbackDelegate
    
    @objc private func signin() {
        guard let rootURL = URL(string: Client(apiKey: nil).rootURL) else { return }
        UserDefaults.apiKey = nil

        let auth = Auth()
        auth.completion = { apiKey in
            if let apiKey = apiKey {
                // signed in
                UserDefaults.apiKey = apiKey
                appDelegate.registerPushNotification()
                _ = self.navigationController?.popViewController(animated: false)
            } else {
                // not signed in
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.startAnimation()
            }
            self.auth = nil
        }
        auth.presentSignInViewController(on: self, rootURL: rootURL, callbackScheme: kURLSchemeAuthCallback)
        self.auth = auth
    }

    func open(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return auth?.open(url: url, options: [:]) ?? false
    }
}
