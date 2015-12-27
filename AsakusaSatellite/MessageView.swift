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


private let dateFormatter: NSDateFormatter = NSDateFormatter().tap{$0.dateFormat = "yyyy-MM-dd HH:mm"}
private let kCellID = "Cell"
private let kPadding = CGFloat(8)
private let kAttachmentsSize = CGSizeMake(256, 64)


private let kAppGroupID = "group.org.codefirst.asakusasatellite"


class MessageView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UIWebViewDelegate {
    var message: Message? {
        didSet {
            if let u: NSURL = (message.map{NSURL(string: $0.profileImageURL)} ?? nil)  {
                if CGRectIsEmpty(iconView.frame) {
                    iconView.frame = CGRectMake(iconView.frame.origin.x, iconView.frame.origin.y, 44, 44) // haneke requires non-zero imageview
                }
                
                iconView.hnk_setImageFromURL(u, success: { image in
                    self.iconView.image = image
                    
                    // cache to watch
                    let fm = NSFileManager.defaultManager()
                    if  let cacheKey = self.message?.screenName,
                        let cachePath = fm.containerURLForSecurityApplicationGroupIdentifier(kAppGroupID)?.path.map({"\($0)/UserIcon/\(cacheKey).png"}) {
                            do {
                                try fm.createDirectoryAtPath((cachePath as NSString).stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
                                let lastModified = try fm.attributesOfItemAtPath(cachePath)[NSFileModificationDate] as? NSDate
                                
                                let needsCache = lastModified.map({NSDate().timeIntervalSinceDate($0) > (60 * 60)}) ?? true
                                if needsCache {
                                    if let png = UIImagePNGRepresentation(image) {
                                        NSLog("cache size = \(png.length)")
                                        png.writeToFile(cachePath, atomically: true)
                                    }
                                }
                            } catch _ {
                            }
                    }
                })
            }
            
            nameLabel.text = message?.name
            dateLabel.text = message.map{dateFormatter.stringFromDate($0.createdAt)}
            bodyLabel.text = message?.body
            attachments = message?.imageAttachments ?? []

            if message?.hasHTML == .Some(true) {
                let autolayout = northLayoutFormat(["p": kPadding], [
                    "icon": iconView,
                    "web": webView,
                    "attachments": attachmentsView,
                    ])
                autolayout("H:|[web]|")
                autolayout("V:[icon][web(>=1)][attachments]")
                webView.message = message
                bringSubviewToFront(webView)
                bringSubviewToFront(separator)
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
    
    let loadButton = UIButton(type: .System)
    let loadButtonHeightConstraint: NSLayoutConstraint
    let iconView = UIImageView(frame: CGRectZero)
    let nameLabel = UILabel()
    let dateLabel = UILabel()
    let bodyLabel = UILabel()
    let attachmentsView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout().tap { (l: UICollectionViewFlowLayout) in
        l.scrollDirection = .Horizontal
        l.itemSize = kAttachmentsSize
        l.sectionInset = UIEdgeInsetsMake(0, kPadding, kPadding, kPadding)
    })
    let attachmentsViewConstraint: NSLayoutConstraint
    var webView: InlineMessageWebView = InlineMessageWebView(frame: CGRectMake(0, 0, 1, 1), baseURL: nil) {
        didSet {
            webView.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
            webView.onContentSizeChange = self.cacheWebViewContentSize
// TODO: use alternative to UIWebViewDelegate:            webView.delegate = self
        }
    }
    let separator = Appearance.separatorView()
    var baseURL: NSURL? {
        didSet {
            if oldValue != baseURL {
                webView = InlineMessageWebView(frame: CGRectMake(0, 0, 1, 1), baseURL: baseURL)
            }
        }
    }
    var onLayoutChange: (MessageView -> Void)?
    var onLinkTapped: ((MessageView, NSURL) -> Void)?
    var onLoadTapped: ((MessageView, completion: (Void) -> Void)-> Void)? {
        didSet {
            let showsLoadButton = (onLoadTapped != nil)
            loadButtonHeightConstraint.constant = showsLoadButton ? 44 : 0
            loadButton.hidden = !showsLoadButton
        }
    }
    
    override init(frame: CGRect) {
        loadButtonHeightConstraint = NSLayoutConstraint(item: loadButton, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0, constant: 0)
        loadButtonHeightConstraint.active = true
        attachmentsViewConstraint = NSLayoutConstraint(item: attachmentsView, attribute: .Height, relatedBy: .Equal, toItem: attachmentsView, attribute: .Height, multiplier: 0, constant: 0)
        attachmentsView.addConstraint(attachmentsViewConstraint)
        
        super.init(frame: frame)
        
        loadButton.setTitle(NSLocalizedString("Load", comment: ""), forState: .Normal)
        loadButton.addTarget(self, action: "load:", forControlEvents: .TouchUpInside)
        loadButton.backgroundColor = Appearance.lightDarkBackgroundColor
        
        let iconSize = CGFloat(32)
        iconView.layer.cornerRadius = iconSize / 2
        iconView.clipsToBounds = true
        
        nameLabel.numberOfLines = 1
        nameLabel.font = Appearance.hiraginoW6(13)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        
        dateLabel.numberOfLines = 1
        dateLabel.font = Appearance.hiraginoW3(10)
        dateLabel.textColor = UIColor.grayColor()
        dateLabel.textAlignment = .Right
        dateLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.font = Appearance.hiraginoW3(Appearance.messageBodyFontSize)
        bodyLabel.textColor = Appearance.messageBodyColor
        bodyLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        
        attachmentsView.dataSource = self
        attachmentsView.delegate = self
        attachmentsView.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: kCellID)
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
        addEqualConstraint(.CenterY, view: nameLabel, toView: iconView)
        bringSubviewToFront(separator)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func load(sender: AnyObject?) {
        loadButton.enabled = false
        onLoadTapped?(self) {
            self.loadButton.enabled = true
        }
    }
    
    // MARK: - Layout Size
    
    struct LayoutStatic {
        static let view = MessageView(frame: CGRectZero)
        static var webViewHeightsCache = [String: CGFloat]() // map: message.id -> height
    }
    
    class func layoutSize(forMessage m: Message, showsLoadButton: Bool, forWidth w: CGFloat) -> CGSize {
        let v = LayoutStatic.view
        v.bodyLabel.text = m.body
        v.attachments = m.attachments
        v.onLoadTapped = showsLoadButton ? {_ in ()} : nil
        
        // we cannot calculate webview height synchronously.
        // add webview height after once loaded and cached the webview height
        let size = v.systemLayoutSizeFittingSize(CGSizeMake(w, 70), withHorizontalFittingPriority: 1000, verticalFittingPriority: 50)
        if let h = LayoutStatic.webViewHeightsCache[m.id] {
            // NSLog("%@", "cache hit for \(m.body), height = \(h)")
            let bodyLabelHeight = v.bodyLabel.systemLayoutSizeFittingSize(CGSizeMake(w - 2 * kPadding, 70), withHorizontalFittingPriority: 1000, verticalFittingPriority: 50).height
            let increments: CGFloat = h - bodyLabelHeight - 2 * kPadding
            return CGSizeMake(size.width, size.height + max(0, increments))
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
    
    // MARK: - WebView
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            if let u = request.URL { onLinkTapped?(self, u) }
            return false
        }
        return true
    }
    
    // MARK: - CollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellID, forIndexPath: indexPath) as! ImageCollectionViewCell

        if let url = NSURL(string: attachments[indexPath.item].url) {
            cell.imageView.hnk_setImageFromURL(url)
        } else {
            cell.imageView.hnk_cancelSetImage()
            cell.imageView.image = nil
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let url = NSURL(string: attachments[indexPath.item].url) {
            let vc = HeadUpImageViewController(imageURL: url)
            appDelegate.root.topViewController!.presentViewController(vc, animated: true, completion: nil)
        }
    }
}

