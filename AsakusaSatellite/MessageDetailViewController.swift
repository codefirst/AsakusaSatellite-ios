//
//  MessageDetailViewController.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/22.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite
import TUSafariActivity
import SafariServices


class MessageDetailViewController: UIViewController, UIWebViewDelegate {
    let message: Message?
    let baseURL: NSURL?
    let initialURL: NSURL?
    let webview = UIWebView(frame: CGRectZero)
    var prevButton: UIBarButtonItem!
    var nextButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    
    private init(message: Message?, baseURL: NSURL?, initialURL: NSURL?) {
        self.message = message
        self.baseURL = baseURL
        self.initialURL = initialURL
        super.init(nibName: nil, bundle: nil)
        webview.delegate = self
    }
    
    convenience init(message: Message, baseURL: String) {
        self.init(message: message, baseURL: NSURL(string: baseURL), initialURL: nil)
    }
    
    convenience init (URL: NSURL) {
        self.init(message: nil, baseURL: nil, initialURL: URL)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = message?.name

        view = webview
        view.backgroundColor = Appearance.backgroundColor
        
        prevButton = UIBarButtonItem(title: "❮", style: .Plain, target: self, action: "prev:")
        nextButton = UIBarButtonItem(title: "❯", style: .Plain, target: self, action: "next:")
        reloadButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "reload:")
        shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share:")
        toolbarItems = [
            prevButton, flexibleBarButtonItem(),
            nextButton, flexibleBarButtonItem(),
            reloadButton, flexibleBarButtonItem(),
            shareButton]
        
        if let u = initialURL {
            navigationController?.setToolbarHidden(false, animated: true)
            webview.scalesPageToFit = true
            webview.loadRequest(NSURLRequest(URL: u))
        } else {
            webview.loadHTMLString(message?.html() ?? "", baseURL: baseURL)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func updateToolbar() {
        prevButton.enabled = webview.canGoBack
        nextButton.enabled = webview.canGoForward
        reloadButton.enabled = !webview.loading
        shareButton.enabled = (webview.request?.URL != nil)
    }
    
    // MARK: - Actions
    
    func prev(sender: AnyObject?) { webview.goBack() }
    func next(sender: AnyObject?) { webview.goForward() }
    func reload(sender: AnyObject?) { webview.reload() }
    
    func share(sender: AnyObject?) {
        if let url = webview.request?.URL {
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [TUSafariActivity()])
            presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - WebView
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked, let url = request.URL {
            if #available(iOS 9.0, *) {
                navigationController?.presentViewController(SFSafariViewController(URL: url), animated: true, completion: nil)
                return false
            } else {
                webview.scalesPageToFit = true
                navigationController?.setToolbarHidden(false, animated: true)
            }
        }
        updateToolbar()
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        updateToolbar()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let title = webview.stringByEvaluatingJavaScriptFromString("document.title") {
            if !title.isEmpty {
                self.title = title
            }
        }
        updateToolbar()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        UIAlertController.presentSimpleAlert(onViewController: self, title: NSLocalizedString("Cannot Load", comment: ""), error: error)
        updateToolbar()
    }
}
