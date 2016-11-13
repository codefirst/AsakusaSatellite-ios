//
//  MessageView.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/21.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite
import NorthLayout
import WebKit
import Ikemen


private let dateFormatter: DateFormatter = DateFormatter() ※ {$0.dateFormat = "yyyy-MM-dd HH:mm"}
private let kCellID = "Cell"
private let kPadding = CGFloat(8)
private let kAttachmentsSize = CGSize(width: 256, height: 64)


private let kAppGroupID = "group.org.codefirst.asakusasatellite"


class MessageView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    var message: Message? {
        didSet {
            if let u: NSURL = (message.map{NSURL(string: $0.profileImageURL)} ?? nil)  {
                if iconView.frame.isEmpty {
                    iconView.frame = CGRect(x: iconView.frame.origin.x, y: iconView.frame.origin.y, width: 44, height: 44) // haneke requires non-zero imageview
                }
                
                iconView.hnk_setImageFromURL(u as URL, success: { image in
                    self.iconView.image = image
                    
                    // cache to watch
                    let fm = FileManager.default
                    if  let cacheKey = self.message?.screenName,
                        let containerURL = fm.containerURL(forSecurityApplicationGroupIdentifier: kAppGroupID) {
                        let cachePath = containerURL.appendingPathComponent("UserIcon").appendingPathComponent("\(cacheKey).png")
                        do {
                            try fm.createDirectory(at: cachePath.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                            let lastModified = try fm.attributesOfItem(atPath: cachePath.path)[FileAttributeKey.modificationDate] as? Date

                            let needsCache = lastModified.map({Date().timeIntervalSince($0) > (60 * 60)}) ?? true
                            if needsCache {
                                if let png = UIImagePNGRepresentation(image) {
                                    NSLog("cache size = \(png.count)")
                                    try png.write(to: cachePath, options: .atomic)
                                }
                            }
                        } catch _ {
                        }
                    }
                })
            }

            nameLabel.text = message?.name
            dateLabel.text = message.map{dateFormatter.string(from: $0.createdAt)}
            bodyLabel.text = message?.body
            attachments = message?.imageAttachments ?? []

            if message?.hasHTML == true {
                let autolayout = northLayoutFormat(["p": kPadding], [
                    "icon": iconView,
                    "web": webView,
                    "attachments": attachmentsView,
                    ])
                autolayout("H:|[web]|")
                autolayout("V:[icon][web(>=1)][attachments]")
                webView.message = message
                bringSubview(toFront: webView)
                bringSubview(toFront: separator)
            } else {
                webView.message = nil
            }
        }
    }
    var attachments: [Attachment] = [] {
        didSet {
            attachmentsViewConstraint.constant = attachments.count > 0 ? kAttachmentsSize.height + kPadding : 0
            attachmentsView.reloadData()
        }
    }
    
    let loadButton = UIButton(type: .system)
    let loadButtonHeightConstraint: NSLayoutConstraint
    let iconView = UIImageView(frame: .zero)
    let nameLabel = UILabel()
    let dateLabel = UILabel()
    let bodyLabel = UILabel()
    let attachmentsView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout() ※ { (l: UICollectionViewFlowLayout) in
        l.scrollDirection = .horizontal
        l.itemSize = kAttachmentsSize
        l.sectionInset = UIEdgeInsetsMake(0, kPadding, kPadding, kPadding)
    })
    let attachmentsViewConstraint: NSLayoutConstraint
    var webView: InlineMessageWebView = InlineMessageWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), baseURL: nil) {
        didSet {
            webView.setContentCompressionResistancePriority(1000, for: .vertical)
            webView.onContentSizeChange = self.cacheWebViewContentSize
            webView.navigationDelegate = self
        }
    }
    let separator = Appearance.separatorView()
    var baseURL: URL? {
        didSet {
            if oldValue != baseURL {
                webView = InlineMessageWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), baseURL: baseURL)
            }
        }
    }
    var onLayoutChange: ((MessageView) -> Void)?
    var onLinkTapped: ((MessageView, URL) -> Void)?
    var onLoadTapped: ((MessageView, _ completion: @escaping (Void) -> Void)-> Void)? {
        didSet {
            let showsLoadButton = (onLoadTapped != nil)
            loadButtonHeightConstraint.constant = showsLoadButton ? 44 : 0
            loadButton.isHidden = !showsLoadButton
        }
    }
    
    override init(frame: CGRect) {
        loadButtonHeightConstraint = NSLayoutConstraint(item: loadButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 0)
        loadButtonHeightConstraint.isActive = true
        attachmentsViewConstraint = NSLayoutConstraint(item: attachmentsView, attribute: .height, relatedBy: .equal, toItem: attachmentsView, attribute: .height, multiplier: 0, constant: 0)
        attachmentsView.addConstraint(attachmentsViewConstraint)
        
        super.init(frame: frame)
        
        loadButton.setTitle(NSLocalizedString("Load", comment: ""), for: .normal)
        loadButton.addTarget(self, action: #selector(load(_:)), for: .touchUpInside)
        loadButton.backgroundColor = Appearance.lightDarkBackgroundColor
        
        let iconSize = CGFloat(32)
        iconView.layer.cornerRadius = iconSize / 2
        iconView.clipsToBounds = true
        
        nameLabel.numberOfLines = 1
        nameLabel.font = Appearance.hiraginoW6(13)
        nameLabel.textColor = .black
        nameLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        
        dateLabel.numberOfLines = 1
        dateLabel.font = Appearance.hiraginoW3(10)
        dateLabel.textColor = .gray
        dateLabel.textAlignment = .right
        dateLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.font = Appearance.hiraginoW3(Appearance.messageBodyFontSize)
        bodyLabel.textColor = Appearance.messageBodyColor
        bodyLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .vertical)
        
        attachmentsView.dataSource = self
        attachmentsView.delegate = self
        attachmentsView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: kCellID)
        attachmentsView.backgroundColor = Appearance.backgroundColor
        attachmentsView.showsHorizontalScrollIndicator = false
        attachmentsView.showsVerticalScrollIndicator = false
        
        let autolayout = northLayoutFormat([
            "sp": kPadding / 2,
            "p": kPadding,
            "iconSize": iconSize,
            "onepx": Appearance.onepx,
            ], [
                "load": loadButton,
                "icon": iconView,
                "name": nameLabel,
                "date": dateLabel,
                "body": bodyLabel,
                "attachments": attachmentsView,
                "web": webView,
                "separator": separator
            ])
        autolayout("H:|[load]|")
        autolayout("H:|-p-[icon(==iconSize)]-p-[name][date]-p-|")
        autolayout("H:|-p-[body]-p-|")
        autolayout("H:|[attachments]|")
        autolayout("H:|[separator]|")
        autolayout("V:|[load]")
        autolayout("V:[load]-sp-[date]")
        autolayout("V:[load]-p-[icon(==iconSize)]-p-[body]-p-[attachments]|")
        autolayout("V:[separator(==onepx)]|")
        addEqualConstraint(attribute: .centerY, view: nameLabel, toView: iconView)
        bringSubview(toFront: separator)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func load(_ sender: AnyObject?) {
        loadButton.isEnabled = false
        onLoadTapped?(self) {
            self.loadButton.isEnabled = true
        }
    }
    
    // MARK: - Layout Size
    
    struct LayoutStatic {
        static let view = MessageView(frame: .zero)
        static var webViewHeightsCache = [String: CGFloat]() // map: message.id -> height
    }
    
    class func layoutSize(forMessage m: Message, showsLoadButton: Bool, forWidth w: CGFloat) -> CGSize {
        let v = LayoutStatic.view
        v.bodyLabel.text = m.body
        v.attachments = m.attachments
        v.onLoadTapped = showsLoadButton ? {_ in ()} : nil
        
        // we cannot calculate webview height synchronously.
        // add webview height after once loaded and cached the webview height
        let size = v.systemLayoutSizeFitting(CGSize(width: w, height: 70), withHorizontalFittingPriority: 1000, verticalFittingPriority: 50)
        if let h = LayoutStatic.webViewHeightsCache[m.id] {
            // NSLog("%@", "cache hit for \(m.body), height = \(h)")
            let bodyLabelHeight = v.bodyLabel.systemLayoutSizeFitting(CGSize(width: w - 2 * kPadding, height: 70), withHorizontalFittingPriority: 1000, verticalFittingPriority: 50).height
            let increments: CGFloat = h - bodyLabelHeight - 2 * kPadding
            return CGSize(width: size.width, height: size.height + max(0, increments))
        }
        
        return size
    }
    
    func cacheWebViewContentSize(contentSize: CGSize) {
        let height = contentSize.height
        if height > 0 {
            if let key = webView.message?.id {
                let oldHeight = LayoutStatic.webViewHeightsCache[key]
                if oldHeight != height {
                    // NSLog("%@", "caching height = \(height) for \(message?.body)")
                    LayoutStatic.webViewHeightsCache[key] = height
                    onLayoutChange?(self)
                }
            }
        }
    }
    
    func prepareForReuse() {
        // clear for reusing MessageView, for example, contained in a cell
        
        iconView.hnk_cancelSetImage()
        iconView.image = nil
        
        attachmentsViewConstraint.constant = 0 // UITableView.dequeue cause layout before contents set that may result in autolayout error
        loadButtonHeightConstraint.constant = 0
        
        webView.message = nil // clear content
        webView.removeFromSuperview() // remove constraints
    }
    
    // MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellID, for: indexPath) as! ImageCollectionViewCell

        if let url = NSURL(string: attachments[indexPath.item].url) {
            cell.imageView.hnk_setImageFromURL(url as URL)
        } else {
            cell.imageView.hnk_cancelSetImage()
            cell.imageView.image = nil
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = NSURL(string: attachments[indexPath.item].url) {
            let vc = HeadUpImageViewController(imageURL: url)
            appDelegate.root.topViewController!.present(vc, animated: true, completion: nil)
        }
    }
}


// MARK: WKNavigationDelegate
extension MessageView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            if let u = navigationAction.request.url { onLinkTapped?(self, u) }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

