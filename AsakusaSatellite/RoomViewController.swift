//
//  RoomViewController.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/21.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite


private let kCellID = "Cell"


class RoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIWebViewDelegate {
    let client: Client
    var pusher: MessagePusherClient?
    var room: Room
    var messages = [Message]()

    let tableView = UITableView(frame: CGRectZero, style: .Plain)
    let refreshView = RefreshView()
    let postView = PostView()
    
    // MARK: - init
    
    init(client: Client, room: Room) {
        self.client = client
        self.room = room
        
        super.init(nibName: nil, bundle: nil)
        
        title = room.name
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = Appearance.backgroundColor
        tableView.backgroundColor = view.backgroundColor
        tableView.backgroundView = refreshView
        
        tableView.registerClass(TableCell.self, forCellReuseIdentifier: kCellID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        
        postView.containigViewController = self
        postView.onPost = { (text, attachments, completion) in
            self.postMessage(text, attachments: attachments) { success in
                completion(clearField: success)
            }
        }
        
        refreshView.onRefresh = { completion in
            self.reloadMessages(completion: completion)
        }
        
        let keyboardSpacer = KeyboardSpacerView()
        let autolayout = view.autolayoutFormat(["p": 8], [
            "table": tableView,
            "keyboard": keyboardSpacer
            ])
        autolayout("H:|[table]|")
        autolayout("V:|[table][keyboard]|")
        keyboardSpacer.installKeyboardHeightConstraint()
        keyboardSpacer.onHeightChange = { [weak self] _ in
            dispatch_async(dispatch_get_main_queue()) {
                if let s = self {
                    s.view.layoutIfNeeded()
                    s.tableView.scrollRectToVisible(s.tableView.tableFooterView!.frame, animated: true)
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshView.refresh()
        tableView.tableFooterView = postView
    }
    
    // MARK: -
    
    private func reloadMessages(completion: (Void -> Void)? = nil) {
        client.messagePusher(room.id) { pusher in
            self.pusher = pusher
            pusher?.onMessageCreate = self.onMessageCreate
            pusher?.connect()
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        client.messageList(room.id, count: 20, sinceID: messages.last?.id, untilID: nil, order: .Desc) { r in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            switch r {
            case .Success(let many):
                self.appendMessages(many.value.items.reverse())
                dispatch_async(dispatch_get_main_queue()) {
                    self.scrollToBottom()
                }
            case .Failure(let error):
                let ac = UIAlertController(title: NSLocalizedString("Cannot Load Messages", comment: ""), message: error?.localizedDescription, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
            }
            completion?()
        }
    }
    
    private func onMessageCreate(message: Message) {
        self.appendMessages([message])
    }
    
    private func appendMessages(messages: [Message]) {
        UIView.setAnimationsEnabled(false) // disable automatic animation
        let ids = self.messages.map{$0.id}
        for m in messages {
            if find(ids, m.id) == nil {
                self.messages.append(m)
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: self.messages.count - 1, inSection: 0)], withRowAnimation: .None)
            }
        }
        UIView.setAnimationsEnabled(true)
    }
    
    private func scrollToBottom() {
        // UITableViewAutomaticDimension does not support valid contentSize calculation before loading
        // http://stackoverflow.com/questions/25686490/ios-8-auto-cell-height-cant-scroll-to-last-row
        // tableView.setContentOffset(CGPointMake(0, max(0, tableView.contentSize.height - tableView.frame.height)), animated: true)
    }
    
    private func postMessage(text: String, attachments: [PostView.Attachment], completion: (Bool -> Void)?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let tmpFolder = NSTemporaryDirectory()
        var filenameIndex = 0
        var tmpFiles = [String]()
        for a in attachments {
            var file = ""
            do {
                file = tmpFolder.stringByAppendingPathComponent("upload-\(filenameIndex).\(a.ext)")
                ++filenameIndex
            } while NSFileManager.defaultManager().fileExistsAtPath(file)
            a.data.writeToFile(file, atomically: true)
            tmpFiles.append(file)
        }
        
        client.postMessage(text, roomID: room.id, files: tmpFiles) { r in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            for file in tmpFiles {
                NSFileManager.defaultManager().removeItemAtPath(file, error: nil)
            }
            
            switch r {
            case .Success(let postMessage):
                self.reloadMessages(completion: nil)
                completion?(true)
            case .Failure(let error):
                let ac = UIAlertController(title: NSLocalizedString("Cannot Send Message", comment: ""), message: error?.localizedDescription, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(ac, animated: true, completion: nil)
                completion?(false)
            }
        }
    }
    
    // MARK: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MessageView.layoutSize(forMessage: messages[indexPath.row], forWidth: tableView.frame.width).height
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellID, forIndexPath: indexPath) as! TableCell
        let message = messages[indexPath.row]
        cell.messageView.baseURL = NSURL(string: client.rootURL)
        cell.message = message
        cell.selectionStyle = .None
        cell.messageView.onLayoutChange = onLayoutChange
        cell.messageView.onLinkTapped = onLinkTapped
        return cell
    }
    
    func onLayoutChange(messageView: MessageView) {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    func onLinkTapped(messageView: MessageView, url: NSURL) {
        navigationController?.pushViewController(MessageDetailViewController(URL: url), animated: true)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if messages[indexPath.row].hasHTML {
            navigationController?.pushViewController(MessageDetailViewController(message: messages[indexPath.row], baseURL: client.rootURL), animated: true)
        }
    }
    
    // MARK: - WebView
    
    // MARK: - ScrollView

    func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshView.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.velocityInView(scrollView).y > 0 {
            postView.endEditing(true)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshView.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    // MARK: - Custom Cell
    
    private class TableCell: UITableViewCell {
        let messageView = MessageView(frame: CGRectZero)
        var message: Message? {
            get {
                return messageView.message
            }
            set {
                messageView.message = newValue
            }
        }
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            let autolayout = contentView.autolayoutFormat(nil, ["v": messageView])
            autolayout("H:|[v]|")
            autolayout("V:|[v]|")
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private override func prepareForReuse() {
            super.prepareForReuse()
            messageView.prepareForReuse()
        }
    }
}
