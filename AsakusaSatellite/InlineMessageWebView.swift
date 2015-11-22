//
//  InlineMessageWebView.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/31.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite


private let kContentSize = "contentSize"


class InlineMessageWebView: UIWebView {
    let baseURL: NSURL?
    var onContentSizeChange: (CGSize -> Void)?
    var message: Message? {
        didSet {
            if let m = message {
                loadHTMLString(m.html(), baseURL: baseURL)
            } else {
                // clear content
                stopLoading()
                stringByEvaluatingJavaScriptFromString("document.body.innerHTML = \"\";")
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
        
        super.init(frame: frame)
        
        suppressesIncrementalRendering = true
        
        scrollView.scrollEnabled = false
        scrollView.addObserver(self, forKeyPath: kContentSize, options: [], context: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: kContentSize)
    }
    
    func loadMessageHTML(message: Message?, baseURL: NSURL?) {
        loadHTMLString(message?.html() ?? "", baseURL: baseURL)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if object === scrollView && keyPath == kContentSize {
            let height = Int(stringByEvaluatingJavaScriptFromString("document.getElementById(\"AsakusaSatMessageContent\").clientHeight") ?? "").map{CGFloat($0)} ?? 0
            contentSize = CGSizeMake(scrollView.contentSize.width, height)
            return
        }
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
    
    override func intrinsicContentSize() -> CGSize {
        return contentSize
    }
}
