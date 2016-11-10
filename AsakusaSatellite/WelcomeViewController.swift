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


class WelcomeViewController: UIViewController {
    let logoView = UIImageView(image: UIImage(named: "Logo"))
    let signinButton = Appearance.roundRectButtonOnTintColor("Sign in with Twitter")
    var signinVC: UIViewController?
    
    var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        view.backgroundColor = Appearance.asakusaRed
        
        let alpha = CGFloat(0.9)
        logoView.contentMode = .scaleAspectFit
        logoView.alpha = alpha
        signinButton.alpha = alpha
        signinButton.addTarget(self, action: #selector(signin(_:)), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: self, action: #selector(cancelSignin(_:)))
        
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
        logoView.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)
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
        displayLink?.add(to: .main, forMode: .commonModes)
    }
    
    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func displayLink(_ sender: CADisplayLink) {
        let time = CGFloat(NSDate().timeIntervalSince1970)
        let periodInSeconds = CGFloat(5)
        let amplitude = CGFloat(8)
        let offset = amplitude * sin(time * 2 * CGFloat(M_PI) / periodInSeconds)
        
        logoView.transform = CGAffineTransform(translationX: 0, y: offset)
    }
    
    func signin(_ sender: AnyObject?) {
        UserDefaults.apiKey = nil

        if #available(iOS 9.0, *) {
            appDelegate.openURLAuthCallbackDelegate = self
            guard let authURL = URL(string: "/auth/twitter?callback_scheme=\(kURLSchemeAuthCallback)", relativeTo: URL(string: Client(apiKey: nil).rootURL)) else { return }
            signinVC = SFSafariViewController(url: authURL) ※ { (vc: SFSafariViewController) in
                vc.delegate = self
                vc.modalPresentationStyle = .formSheet
                present(vc, animated: true, completion: nil)
            }
            return
        }
        
        signinVC = TwitterAuthViewController(rootURL: URL(string: Client(apiKey: nil).rootURL)!) { apiKey in
            UserDefaults.apiKey = apiKey
            self.closeSigninViewController()
        }
        
        
        addChildViewController(signinVC!)
        view.addSubview(signinVC!.view)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        signinVC!.view.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height)
        signinVC!.view.alpha = 0.5
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: [],
            animations: { [weak self] in
                if let s = self {
                    s.signinVC?.view.frame = s.view.bounds
                    s.signinVC?.view.alpha = 1.0
                    s.signinVC?.didMove(toParentViewController: self)
                    s.stopAnimation()
                }
                return
        }, completion: nil)
    }
    
    func cancelSignin(_ sender: AnyObject?) {
        closeSigninViewController()
    }
    
    func closeSigninViewController() {
        if UserDefaults.apiKey != nil {
            // signed in
            appDelegate.registerPushNotification()
            _ = navigationController?.popViewController(animated: true)
            return
        }
        
        if let vc = signinVC {
            vc.willMove(toParentViewController: nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
        navigationController?.setNavigationBarHidden(true, animated: true)
        startAnimation()
    }
}


extension WelcomeViewController: OpenURLAuthCallbackDelegate, SFSafariViewControllerDelegate {
    func openURL(url: URL, sourceApplication: String?) -> Bool {
        appDelegate.openURLAuthCallbackDelegate = nil

        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false)
        if let apiKey = components?.queryItems?.filter({$0.name == "api_key"}).first?.value {
            // signed in
            UserDefaults.apiKey = apiKey
            appDelegate.registerPushNotification()
            _ = navigationController?.popViewController(animated: false)
        } else {
            // not signed in
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.startAnimation()
        }

        signinVC?.dismiss(animated: true, completion: nil)
        return true
    }

    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        appDelegate.openURLAuthCallbackDelegate = nil
        signinVC = nil
    }
}

