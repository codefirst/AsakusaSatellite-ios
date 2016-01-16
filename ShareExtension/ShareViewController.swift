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


class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        guard let inputItems = self.extensionContext?.inputItems as? [NSExtensionItem] where !inputItems.isEmpty else {
            self.extensionContext?.completeRequestReturningItems([], completionHandler: nil)
            return
        }

        // FIXME: debug info
        let client = Client(apiKey: //"apikey)
        let room = //"room"

        var asyncTasks: UInt = 0
        let completeRequestIfFinished = {
            if asyncTasks == 0 {
                self.extensionContext!.completeRequestReturningItems([], completionHandler: nil)
            }
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

                    client.postMessage("from Share Extension", roomID: room, files: [jpegFileURL.path!]) { _ in
                            completeRequestIfFinished()
                    }
                }
            }
        }

        completeRequestIfFinished()
    }

    override func configurationItems() -> [AnyObject]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
