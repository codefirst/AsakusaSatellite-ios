//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by BAN Jun on 2016/01/15.
//  Copyright © 2016年 codefirst. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import AsakusaSatellite
import AppGroup


class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func didSelectPost() {
        var asyncTasks: UInt = 0
        let completeRequestIfFinished = {
            if asyncTasks == 0 {
                self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
            }
        }

        let client = Client(apiKey: UserDefaults.apiKey)
        guard let inputItems = self.extensionContext?.inputItems as? [NSExtensionItem] where !inputItems.isEmpty,
            let roomID = UserDefaults.currentRoom?.id else {
            completeRequestIfFinished()
            return
        }

        for items in inputItems {
            let itemProviders = items.attachments as? [NSItemProvider] ?? []
            itemProviders.forEach { ip in
                asyncTasks += 1
                ip.loadItemForTypeIdentifier(kUTTypeImage as String, options: nil) { object, error in
                    let jpegFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("jpg")

                    asyncTasks -= 1
                    guard error == nil,
                        let imageURL = object as? NSURL where imageURL.fileURL,
                        let image = UIImage(contentsOfFile: imageURL.path!)
                        where UIImageJPEGRepresentation(image, 0.8)?.writeToURL(jpegFileURL, atomically: true) == true else {
                            return completeRequestIfFinished()
                    }

                    client.postMessage(self.contentText, roomID: roomID, files: [jpegFileURL.path!]) { _ in
                        completeRequestIfFinished()
                    }
                }

                asyncTasks += 1
                ip.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil) { object, error in
                    asyncTasks -= 1
                    guard error == nil,
                        let url = object as? NSURL else {
                            return completeRequestIfFinished()
                    }

                    client.postMessage(url.absoluteString + "\n" + self.contentText, roomID: roomID, files: []) { _ in
                        completeRequestIfFinished()
                    }
                }

                asyncTasks += 1
                ip.loadItemForTypeIdentifier(kUTTypeText as String, options: nil) { object, error in
                    asyncTasks -= 1
                    guard error == nil,
                        let _ = object as? String else {
                            return completeRequestIfFinished()
                    }

                    client.postMessage(self.contentText, roomID: roomID, files: []) { _ in
                        completeRequestIfFinished()
                    }
                }
            }
        }

        completeRequestIfFinished()
    }

    override func configurationItems() -> [AnyObject]! {
        let room = UserDefaults.currentRoom
        let roomConfigurationItem = SLComposeSheetConfigurationItem()
        roomConfigurationItem.title = "To"
        roomConfigurationItem.value = room?.name ?? "(not logged in)"

        return [roomConfigurationItem]
    }

}
