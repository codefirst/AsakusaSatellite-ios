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


class MessageDetailViewController: UIViewController, UIWebViewDelegate {
    let message: Message
    let baseURL: String
    let webview = UIWebView(frame: CGRectZero)
    var prevButton: UIBarButtonItem!
    var nextButton: UIBarButtonItem!
    var reloadButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    
    init(message: Message, baseURL: String) {
        self.message = message
        self.baseURL = baseURL
        
        super.init(nibName: nil, bundle:nil)
        
        title = message.name
        webview.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
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
        
        webview.loadHTMLString(message.html, baseURL: NSURL(string: baseURL))
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
        if navigationType == .LinkClicked {
            webview.scalesPageToFit = true
            navigationController?.setToolbarHidden(false, animated: true)
        }
        updateToolbar()
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        updateToolbar()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if let title = webview.stringByEvaluatingJavaScriptFromString("document.title") {
            self.title = title
        }
        updateToolbar()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        UIAlertController.presentSimpleAlert(onViewController: self, title: NSLocalizedString("Cannot Load", comment: ""), error: error)
        updateToolbar()
    }
}
