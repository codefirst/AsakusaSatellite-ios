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
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }

        let client = Client(apiKey: UserDefaults.apiKey)
        guard let inputItems = self.extensionContext?.inputItems as? [NSExtensionItem], !inputItems.isEmpty,
            let roomID = UserDefaults.currentRoom?.id else {
                completeRequestIfFinished()
                return
        }

        gatherValidContents() { text, imageFileURLs, urls in
            let postText = (urls.compactMap{$0.absoluteString} + [self.contentText] ).joined(separator: "\n")
            client.postMessage(postText, roomID: roomID, files: imageFileURLs.map{$0.path}) {_ in
                completeRequestIfFinished()
            }
        }
    }

    private func gatherValidContents(completion: @escaping (_ text: String, _ imageFileURLs: [URL], _ urls: [URL]) -> Void) {
        guard let inputItems = self.extensionContext?.inputItems as? [NSExtensionItem] else { return completion("", [], []) }

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let text = contentText
        var imageFileURLs = [URL]()
        var urls = [URL]()

        inputItems.compactMap{$0.attachments}.joined().forEach { itemProvider in
            // Images
            queue.addOperation {
                let sem = DispatchSemaphore(value: 0)

                itemProvider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { object, error in
                    if  let image = self.imageFromObject(object: object), error == nil {
                        let jpegFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString).appendingPathExtension("jpg")
                        if let _ = try? image.jpegData(compressionQuality: 0.8)?.write(to: jpegFileURL, options: [.atomic]) {
                            imageFileURLs.append(jpegFileURL)
                        }
                    }
                    sem.signal()
                }

                _ = sem.wait(timeout: .distantFuture)
            }

            // URLs
            queue.addOperation {
                let sem = DispatchSemaphore(value: 0)

                itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { object, error in
                    if let url = object as? URL, error == nil {
                        urls.append(url)
                    }
                    sem.signal()
                }

                _ = sem.wait(timeout: .distantFuture)
            }
        }

        DispatchQueue.global().async {
            queue.waitUntilAllOperationsAreFinished()
            completion(text!, imageFileURLs, urls)
        }
    }

    private func orientationFixedImage(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        let orientationFixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return orientationFixedImage!
    }

    
    override func configurationItems() -> [Any]! {
        let room = UserDefaults.currentRoom
        guard let roomConfigurationItem = SLComposeSheetConfigurationItem() else { return [] }
        roomConfigurationItem.title = "To"
        roomConfigurationItem.value = room?.name ?? "(not logged in)"
        
        return [roomConfigurationItem]
    }

    private func imageFromObject(object : AnyObject?) -> UIImage? {
        if  let imageURL = object as? NSURL, imageURL.isFileURL,
            let imageURLPath = imageURL.path {
                return UIImage(contentsOfFile: imageURLPath).map({self.orientationFixedImage(image: $0)})
        } else {
            return object as? UIImage
        }
    }
}
