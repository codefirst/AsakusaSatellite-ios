//
//  RoomViewController.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/21.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite
import SafariServices


private let kCellID = "Cell"
private let kNumberOfCachedMessages = 20


class RoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    let client: Client
    var pusher: MessagePusherClient?
    var room: Room
    var messages = [Message]()

    let tableView = UITableView(frame: .zero, style: .plain)
    let refreshView = RefreshView()
    let postView = PostView()
    
    // MARK: - init
    
    init(client: Client, room: Room) {
        self.client = client
        self.room = room
        
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController
    
    override func loadView() {
        super.loadView()
        
        title = room.name
        
        view.backgroundColor = Appearance.backgroundColor
        tableView.backgroundColor = view.backgroundColor
        tableView.backgroundView = refreshView
        
        tableView.register(TableCell.self, forCellReuseIdentifier: kCellID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        postView.containigViewController = self
        postView.onPost = { text, attachments, completion in
            self.postMessage(text: text, attachments: attachments) { success in
                completion(success)
            }
        }
        
        refreshView.onRefresh = { completion in
            self.reloadMessages(completion: completion)
        }
        
        let keyboardSpacer = KeyboardSpacerView()
        let autolayout = view.northLayoutFormat(["p": 8], [
            "table": tableView,
            "keyboard": keyboardSpacer
            ])
        autolayout("H:|[table]|")
        autolayout("V:|[table][keyboard]|")
        keyboardSpacer.installKeyboardHeightConstraint()
        keyboardSpacer.onHeightChange = { [weak self] _ in
            DispatchQueue.main.async {
                if let s = self {
                    s.view.layoutIfNeeded()
                    s.tableView.scrollRectToVisible(s.tableView.tableFooterView!.frame, animated: true)
                }
            }
        }
        
        loadCachedMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshView.refresh()
        tableView.tableFooterView = postView
    }
    
    // MARK: - Caches
    
    private var cachedMessagesFile: String { return "\(NSHomeDirectory())/Library/Caches/\(room.id)-messages.json" }
    
    private func loadCachedMessages() {
        guard let many = Many<Message>(file: cachedMessagesFile) else { return }
        appendMessages(messages: many.items)
    }
    
    private func cacheMessages() {
        let messagesForCache = [Message](messages[max(0, messages.count - kNumberOfCachedMessages)..<messages.count])
        _ = Many<Message>(items: messagesForCache)?.saveToFile(cachedMessagesFile)
    }
    
    // MARK: -
    
    private func reloadMessages(completion: ((Void) -> Void)? = nil) {
        client.messagePusher(room.id) { pusher in
            self.pusher = pusher
            pusher?.onMessageCreate = self.onMessageCreate
            pusher?.connect()
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        client.messageList(room.id, count: 20, sinceID: messages.last?.id, untilID: nil, order: .Desc) { r in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch r {
            case .success(let many):
                self.appendMessages(messages: many.items.reversed())
                DispatchQueue.main.async {
                    self.scrollToBottom()
                }
            case .failure(let error):
                let ac = UIAlertController(title: NSLocalizedString("Cannot Load Messages", comment: ""), message: error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
            completion?()
        }
    }
    
    private func onMessageCreate(message: Message) {
        self.appendMessages(messages: [message])
    }
    
    private func appendMessages(messages: [Message]) {
        insertMessages(messagesToInsert: messages, beforeID: nil)
    }
    
    private func insertMessages(messagesToInsert: [Message], beforeID: String?) {
        UIView.setAnimationsEnabled(false) // disable automatic animation
        tableView.beginUpdates()
        
        // reload cells with load button
        let reloadedIndexes = messages.filter{!hasPreviousMessage(message: $0)}.flatMap{m in messages.index{$0.id == m.id}}
        tableView.reloadRows(at: reloadedIndexes.map{IndexPath(item: $0, section: 0)}, with: .none)
        
        var indexToInsert = messages.index{$0.id == beforeID} ?? messages.count
        for m in messagesToInsert {
            if let cachedIndex = messages.map({$0.id}).index(of: m.id) {
                // update (m is already loaded into tableView)
                if messages[cachedIndex].prevID == nil {
                    messages[cachedIndex] = m
                }
            } else {
                // insert or append
                messages.insert(m, at: indexToInsert)
                tableView.insertRows(at: [IndexPath(item: indexToInsert, section: 0)], with: .none)
                indexToInsert += 1
            }
        }
        
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        
        cacheMessages()
    }
    
    private func scrollToBottom() {
        // UITableViewAutomaticDimension does not support valid contentSize calculation before loading
        // http://stackoverflow.com/questions/25686490/ios-8-auto-cell-height-cant-scroll-to-last-row
        // tableView.setContentOffset(CGPointMake(0, max(0, tableView.contentSize.height - tableView.frame.height)), animated: true)
    }
    
    private func postMessage(text: String, attachments: [PostView.Attachment], completion: @escaping (Bool) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let tmpFolder = NSTemporaryDirectory()
        var filenameIndex = 0
        var tmpFiles = [String]()
        for a in attachments {
            var file = ""
            repeat {
                file = "\(tmpFolder)/upload-\(filenameIndex).\(a.ext)"
                filenameIndex += 1
            } while FileManager.default.fileExists(atPath: file)
            _ = try? a.data.write(to: URL(fileURLWithPath: file), options: .atomic)
            tmpFiles.append(file)
        }
        
        client.postMessage(text, roomID: room.id, files: tmpFiles) { r in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            for file in tmpFiles {
                do {
                    try FileManager.default.removeItem(atPath: file)
                } catch _ {}
            }
            
            switch r {
            case .success(_):
                self.reloadMessages(completion: nil)
                completion(true)
            case .failure(let error):
                let ac = UIAlertController(title: NSLocalizedString("Cannot Send Message", comment: ""), message: error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
                completion(false)
            }
        }
    }
    
    // MARK: - TableView
    
    private func hasPreviousMessage(message: Message) -> Bool {
        guard let prevID = message.prevID else { return false }
        return messages.contains{$0.id == prevID}
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        return MessageView.layoutSize(forMessage: message, showsLoadButton: !hasPreviousMessage(message: message), forWidth: max(tableView.frame.width, 60)).height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellID, for: indexPath) as! TableCell
        let message = messages[indexPath.row]
        cell.messageView.baseURL = URL(string: client.rootURL)
        cell.message = message
        cell.selectionStyle = .none
        cell.messageView.onLayoutChange = onLayoutChange
        cell.messageView.onLinkTapped = onLinkTapped
        cell.messageView.onLoadTapped = hasPreviousMessage(message: message) ? nil : onLoadTapped
        return cell
    }
    
    func onLayoutChange(messageView: MessageView) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    func onLinkTapped(messageView: MessageView, url: URL) {
        if #available(iOS 9.0, *) {
            navigationController?.present(SFSafariViewController(url: url), animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func onLoadTapped(messageView: MessageView, completion: @escaping (Void) -> Void) {
        guard let message = messageView.message else { return }
        let sinceID = messages.index{$0.id == message.id}.flatMap{$0 > 0 ? messages[$0 - 1].id : nil}
        let untilID = message.id
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        client.messageList(room.id, count: 20, sinceID: sinceID, untilID: untilID, order: .Asc) { r in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch r {
            case .success(let many):
                self.insertMessages(messagesToInsert: many.items, beforeID: untilID)
            case .failure(let error):
                let ac = UIAlertController(title: NSLocalizedString("Cannot Load Messages", comment: ""), message: error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }
            completion()
        }
    }
    
    // MARK: - ScrollView

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshView.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.velocity(in: scrollView).y > 0 {
            postView.endEditing(true)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshView.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    // MARK: - Custom Cell
    
    private class TableCell: UITableViewCell {
        let messageView = MessageView(frame: .zero)
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
            
            let autolayout = contentView.northLayoutFormat([:], ["v": messageView])
            autolayout("H:|[v]|")
            autolayout("V:|[v]|")
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        fileprivate override func prepareForReuse() {
            super.prepareForReuse()
            messageView.prepareForReuse()
        }
    }
}
