//
//  Utilities.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/16.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    class func colorImage(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        color.set()
        UIRectFillUsingBlendMode(CGRect(x: 0, y: 0, width: size.width, height: size.height), .copy)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }    
    
    func jpegData(maxSize: Int) -> Data? {
        var quality = CGFloat(0.9)
        var jpg = self.jpegData(compressionQuality: quality)
        while (jpg != nil && jpg!.count > maxSize && quality > 0.1) {
            quality -= 0.1
            jpg = self.jpegData(compressionQuality: quality)
        }
        return jpg
    }
}

#if os(iOS)
    extension UIView {
        func addEqualConstraint(attribute: NSLayoutConstraint.Attribute, view: UIView, toView: UIView) {
            addConstraint(NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .equal, toItem: toView, attribute: attribute, multiplier: 1, constant: 0))
        }
        
        func addCenterXConstraint(view: UIView) { addEqualConstraint(attribute: .centerX, view: view, toView: self) }
        func addCenterYConstraint(view: UIView) { addEqualConstraint(attribute: .centerY, view: view, toView: self) }
    }
    
    extension UIAlertController {
        class func presentSimpleAlert(onViewController vc: UIViewController, title: String, error: Error?) {
            let ac = UIAlertController(title: title, message: error?.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            vc.present(ac, animated: true, completion: nil)
        }
    }
    
    
    class AutolayoutMinView: UIView {
        override var intrinsicContentSize: CGSize {return .zero}
    }
    
    class KeyboardSpacerView : UIView {
        var keyboardHeightConstraint: NSLayoutConstraint?
        var onHeightChange: ((CGFloat) -> Void)?
        
        func installKeyboardHeightConstraint() {
            keyboardHeightConstraint = NSLayoutConstraint(item: self,
                                                          attribute: .height,
                                                          relatedBy: .equal,
                toItem: superview,
                attribute: .height,
                multiplier: 0,
                constant: 0)
            keyboardHeightConstraint?.priority = UILayoutPriority(rawValue: 1000)
            addConstraint(keyboardHeightConstraint!)
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { (n: Notification) -> Void in
                if let userInfo = n.userInfo {
                    if let f = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                        self.keyboardHeightConstraint?.constant = f.size.height
                        self.onHeightChange?(f.size.height)
                    }
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (n: Notification) -> Void in
                self.keyboardHeightConstraint?.constant = 0
                self.onHeightChange?(0)
            }
        }
    }
    
    func flexibleBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    }
#endif


func hwmachine() -> String? {
    let name = NSString(string: "hw.machine")
    
    var size: Int = 0
    if sysctlbyname(name.utf8String, nil, &size, nil, 0) != 0 {
        return nil
    }

    if let data = NSMutableData(length: Int(size)) {
        sysctlbyname(name.utf8String, data.mutableBytes, &size, nil, 0)
        return String(data: data as Data, encoding: .utf8)
    }
    return nil
}

