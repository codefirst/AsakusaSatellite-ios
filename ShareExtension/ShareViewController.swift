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
        let completeRequestIfFinished = {
            self.extensionContext?.completeRequestReturningItems([], completionHandler: nil)
        }

        let client = Client(apiKey: UserDefaults.apiKey)
        guard let inputItems = self.extensionContext?.inputItems as? [NSExtensionItem] where !inputItems.isEmpty,
            let roomID = UserDefaults.currentRoom?.id else {
                completeRequestIfFinished()
                return
        }

        gatherValidContents() { text, imageFileURLs, urls in
            let postText = (urls.map{$0.absoluteString} + [self.contentText] ).joinWithSeparator("\n")
            client.postMessage(postText, roomID: roomID, files: imageFileURLs.map{$0.path!}) {_ in
                completeRequestIfFinished()
            }
        }
    }

    private func gatherValidContents(completion: (text: String, imageFileURLs: [NSURL], urls: [NSURL]) -> Void) {
        guard let inputItems = self.extensionContext?.inputItems as? [NSExtensionItem] else { return completion(text: "", imageFileURLs: [], urls: []) }

        let queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        let text = contentText
        var imageFileURLs = [NSURL]()
        var urls = [NSURL]()

        inputItems.flatMap{$0.attachments as? [NSItemProvider]}.flatten().forEach { itemProvider in
            // Images
            queue.addOperationWithBlock {
                let sem = dispatch_semaphore_create(0)

                itemProvider.loadItemForTypeIdentifier(kUTTypeImage as String, options: nil) { object, error in
                    if  let imageURL = object as? NSURL where imageURL.fileURL,
                        let imageURLPath = imageURL.path,
                        let image = UIImage(contentsOfFile: imageURLPath).map({self.orientationFixedImage($0)}),
                        let jpegFileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("jpg") as NSURL?
                        where error == nil && UIImageJPEGRepresentation(image, 0.8)?.writeToURL(jpegFileURL, atomically: true) == true {
                            imageFileURLs.append(jpegFileURL)
                    }
                    dispatch_semaphore_signal(sem)
                }

                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
            }

            // URLs
            queue.addOperationWithBlock {
                let sem = dispatch_semaphore_create(0)

                itemProvider.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil) { object, error in
                    if let url = object as? NSURL where error == nil {
                        urls.append(url)
                    }
                    dispatch_semaphore_signal(sem)
                }

                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER)
            }
        }

        dispatch_async(dispatch_get_global_queue(0, 0)) {
            queue.waitUntilAllOperationsAreFinished()
            completion(text: text, imageFileURLs: imageFileURLs, urls: urls)
        }
    }

    private func orientationFixedImage(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.drawAtPoint(CGPointZero)
        let orientationFixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return orientationFixedImage
    }

    override func configurationItems() -> [AnyObject]! {
        let room = UserDefaults.currentRoom
        let roomConfigurationItem = SLComposeSheetConfigurationItem()
        roomConfigurationItem.title = "To"
        roomConfigurationItem.value = room?.name ?? "(not logged in)"
        
        return [roomConfigurationItem]
    }

}
