//
//  NotificationController.swift
//  AsakusaSatellite WatchKit Extension
//
//  Created by BAN Jun on 2015/04/26.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import WatchKit
import Foundation
import Ikemen


private let kAppGroupID = "group.org.codefirst.asakusasatellite"


class NotificationController: WKUserNotificationInterfaceController {
    @IBOutlet var group: WKInterfaceGroup?
    @IBOutlet var notificationAlertLabel: WKInterfaceLabel?

    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    /*
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a local notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.Custom)
    }
    */
    
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // let roomID = remoteNotification["room_id"] as? String
        let user = remoteNotification["user"] as? String
        if  let aps = remoteNotification["aps"] as? [String: AnyObject],
            let alert = aps["alert"] as? String {
                let separatorLocation = (alert as NSString).rangeOfString(" / ").location
                let body = (separatorLocation != NSNotFound ? (alert as NSString).substringFromIndex(separatorLocation + 3) : alert)
                
                let attrs: [String: AnyObject] = [
                    NSParagraphStyleAttributeName: (NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle) ※ { (p: NSMutableParagraphStyle) in
                        // p.firstLineHeadIndent = 16 + 4 // iOS 8.3 + Watch OS 8.2: firstLineHeadIndent cause incorrect line break on the first line. use space characters instead.
                        p.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    }
                ]
                let attrString = NSAttributedString(string: "　　" + body, attributes: attrs)
                notificationAlertLabel?.setAttributedText(attrString)
            
                let fm = NSFileManager.defaultManager()
                if  let cacheKey = user,
                    let cachePath = fm.containerURLForSecurityApplicationGroupIdentifier(kAppGroupID)?.path.map({"\($0)/NotificationUserIcon/\(cacheKey).png"}),
                    let iconPath = fm.containerURLForSecurityApplicationGroupIdentifier(kAppGroupID)?.path.map({"\($0)/UserIcon/\(cacheKey).png"}) {
                        let inCache: Bool
                        do {
                            let lastModified = try fm.attributesOfItemAtPath(cachePath)[NSFileModificationDate] as? NSDate
                            inCache = lastModified.map({NSDate().timeIntervalSinceDate($0) < (60 * 60)}) ?? false
                        } catch _ {
                            inCache = false
                        }
                        if inCache {
                            // NSLog("hit cache for \(cacheKey)")
                        } else {
                            // NSLog("caching for \(cacheKey)")
                            if let icon = UIImage(contentsOfFile: iconPath) {
                                let side = CGFloat(20)
                                let margin = CGSizeMake(4, 3)
                                UIGraphicsBeginImageContextWithOptions(CGSizeMake(margin.width + side, margin.height + side), false, 2.0)
                                UIBezierPath(ovalInRect: CGRectMake(margin.width, margin.height, side, side)).addClip()
                                icon.drawInRect(CGRectMake(margin.width, margin.height, side, side))
                                let data = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext()!)
                                UIGraphicsEndImageContext()
                                
                                do {
                                    try fm.createDirectoryAtPath((cachePath as NSString).stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
                                } catch _ {
                                }
                                
                                if let data = data {
                                    data.writeToFile(cachePath, atomically: true)
                                }
                            }
                        }
                        
                        if let cachedImage = UIImage(contentsOfFile: cachePath) {
                            group?.setBackgroundImage(cachedImage)
                        }
                }
                
                completionHandler(.Custom)
        } else {
            completionHandler(.Default)
        }
    }
}
