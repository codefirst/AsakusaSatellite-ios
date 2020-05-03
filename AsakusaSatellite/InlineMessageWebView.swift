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
import Ikemen


private let kContentSize = "contentSize"


class InlineMessageWebView: WKWebView {
    let baseURL: URL?
    var onContentSizeChange: ((CGSize) -> Void)?
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
    var contentSize: CGSize = .zero {
        didSet {
            invalidateIntrinsicContentSize()
            onContentSizeChange?(contentSize)
        }
    }
    
    init(frame: CGRect, baseURL: URL?) {
        self.baseURL = baseURL
        super.init(frame: frame, configuration: WKWebViewConfiguration() ※ { c in
            c.suppressesIncrementalRendering = true
            })
        
        scrollView.isScrollEnabled = false
        scrollView.addObserver(self, forKeyPath: kContentSize, options: [], context: nil)
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: kContentSize)
    }
    
    func loadMessageHTML(message: Message?, baseURL: URL?) {
        loadHTMLString(message?.html() ?? "", baseURL: baseURL)
    }

    private func checkClientHeight(handler: @escaping (CGFloat?) -> Void) {
        evaluateJavaScript("document.getElementById(\"AsakusaSatMessageContent\").clientHeight") { (obj, error) in
            handler((obj as? NSNumber).map{CGFloat(truncating: $0)})
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if scrollView.isEqual(object) && keyPath == kContentSize {
            checkClientHeight { height in
                guard let height = height else { return }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    // change contentSize when height is stable
                    // heights of some web contents are unstable after finished loading
                    self.checkClientHeight { heightAfterAWhile in
                        if height == heightAfterAWhile {
                            self.contentSize = CGSize(width: self.scrollView.contentSize.width, height: height)
                        }
                    }
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    override var intrinsicContentSize: CGSize {return contentSize}
}
