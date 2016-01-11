//
//  Utilities.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/16.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import Foundation
import UIKit


extension NSObject {
    func tap<T>(@noescape block: T -> Void) -> T {
        let s = self as! T
        block(s)
        return s
    }
}


extension UIImage {
    class func colorImage(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        color.set()
        UIRectFillUsingBlendMode(CGRectMake(0, 0, size.width, size.height), .Copy)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }    
    
    func jpegData(maxSize: Int) -> NSData? {
        var quality = CGFloat(0.9)
        var jpg = UIImageJPEGRepresentation(self, quality)
        while (jpg != nil && jpg!.length > maxSize && quality > 0.1) {
            quality -= 0.1
            jpg = UIImageJPEGRepresentation(self, quality)
        }
        return jpg
    }
}

#if os(iOS)
    extension UIView {
        func addEqualConstraint(attribute: NSLayoutAttribute, view: UIView, toView: UIView) {
            addConstraint(NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .Equal, toItem: toView, attribute: attribute, multiplier: 1, constant: 0))
        }
        
        func addCenterXConstraint(view: UIView) { addEqualConstraint(.CenterX, view: view, toView: self) }
        func addCenterYConstraint(view: UIView) { addEqualConstraint(.CenterY, view: view, toView: self) }
    }
    
    extension UIAlertController {
        class func presentSimpleAlert(onViewController vc: UIViewController, title: String, error: NSError?) {
            let ac = UIAlertController(title: title, message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
            vc.presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    
    class AutolayoutMinView: UIView {
        override func intrinsicContentSize() -> CGSize {
            return CGSizeZero
        }
    }
    
    class KeyboardSpacerView : UIView {
        var keyboardHeightConstraint: NSLayoutConstraint?
        var onHeightChange: (CGFloat -> Void)?
        
        func installKeyboardHeightConstraint() {
            keyboardHeightConstraint = NSLayoutConstraint(item: self,
                attribute: NSLayoutAttribute.Height,
                relatedBy: NSLayoutRelation.Equal,
                toItem: superview,
                attribute: NSLayoutAttribute.Height,
                multiplier: 0,
                constant: 0)
            keyboardHeightConstraint?.priority = 1000
            addConstraint(keyboardHeightConstraint!)
            
            NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillChangeFrameNotification, object: nil, queue: nil) { (n: NSNotification) -> Void in
                if let userInfo = n.userInfo {
                    if let f = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                        self.keyboardHeightConstraint?.constant = f.size.height
                        self.onHeightChange?(f.size.height)
                    }
                }
            }
            
            NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: nil) { (n: NSNotification) -> Void in
                self.keyboardHeightConstraint?.constant = 0
                self.onHeightChange?(0)
            }
        }
    }
    
    func flexibleBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    }
#endif


func hwmachine() -> String? {
    let name = NSString(string: "hw.machine")
    
    var size: Int = 0
    if sysctlbyname(name.UTF8String, nil, &size, nil, 0) != 0 {
        return nil
    }
    
    if let data = NSMutableData(length: Int(size)) {
        sysctlbyname(name.UTF8String, data.mutableBytes, &size, nil, 0)
        return NSString(data: data, encoding: NSUTF8StringEncoding) as String?
    }
    return nil
}

