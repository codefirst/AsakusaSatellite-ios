//
//  InlineMessageWebView.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/31.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import WebKit
import AsakusaSatellite


private let kContentSize = "contentSize"


class InlineMessageWebView: WKWebView {
    let baseURL: NSURL?
    var onContentSizeChange: (CGSize -> Void)?
    var message: Message? {
        didSet {
            if let m = message {
                loadHTMLString(m.html(), baseURL: baseURL)
            } else {
                // clear content
                stopLoading()
                evaluateJavaScript("document.body.innerHTML = \"\";", completionHandler: nil)
            }
        }
    }
    var contentSize: CGSize = CGSizeZero {
        didSet {
            invalidateIntrinsicContentSize()
            onContentSizeChange?(contentSize)
        }
    }
    
    init(frame: CGRect, baseURL: NSURL?) {
        self.baseURL = baseURL
        super.init(frame: frame, configuration: WKWebViewConfiguration().tap { c in
            c.suppressesIncrementalRendering = true
            })
        
        scrollView.scrollEnabled = false
        scrollView.addObserver(self, forKeyPath: kContentSize, options: [], context: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: kContentSize)
    }
    
    func loadMessageHTML(message: Message?, baseURL: NSURL?) {
        loadHTMLString(message?.html() ?? "", baseURL: baseURL)
    }

    private func checkClientHeight(handler: CGFloat? -> Void) {
        evaluateJavaScript("document.getElementById(\"AsakusaSatMessageContent\").clientHeight") { (obj, error) in
            handler((obj as? NSNumber).map{CGFloat($0)})
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object === scrollView && keyPath == kContentSize {
            checkClientHeight { height in
                guard let height = height else { return }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    // change contentSize when height is stable
                    // heights of some web contents are unstable after finished loading
                    self.checkClientHeight { heightAfterAWhile in
                        if height == heightAfterAWhile {
                            self.contentSize = CGSizeMake(self.scrollView.contentSize.width, height)
                        }
                    }
                }
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return contentSize
    }
}
