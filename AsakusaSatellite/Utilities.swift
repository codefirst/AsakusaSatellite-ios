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
    func tap<T>(block: T -> Void) -> T {
        let s = self as T
        block(s)
        return s
    }
}

// workaround for swift crash at use of UILayoutPriority
private let priorities = (high: Float(750), low: Float(250), fittingSizeLevel: Float(50))


extension UIView {
    func autolayoutFormat(metrics: [String:CGFloat]?, _ views: [String:UIView]) -> String -> Void {
        return self.autolayoutFormat(metrics, views, options: NSLayoutFormatOptions.allZeros)
    }
    
    func autolayoutFormat(metrics: [String:CGFloat]?, _ views: [String:UIView], options: NSLayoutFormatOptions) -> String -> Void {
        for v in views.values {
            if !v.isDescendantOfView(self) {
                v.setTranslatesAutoresizingMaskIntoConstraints(false)
                self.addSubview(v)
            }
        }
        return { (format: String) in
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: metrics, views: views))
        }
    }
    
    func addEqualConstraint(attribute: NSLayoutAttribute, view: UIView, toView: UIView) {
        addConstraint(NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .Equal, toItem: toView, attribute: attribute, multiplier: 1, constant: 0))
    }
    
    func addCenterXConstraint(view: UIView) { addEqualConstraint(.CenterX, view: view, toView: self) }
    func addCenterYConstraint(view: UIView) { addEqualConstraint(.CenterY, view: view, toView: self) }
    
    // workaround for swift crash at use of UILayoutPriority
    func setContentCompressionResistancePriorityHigh(axis: UILayoutConstraintAxis) { setContentCompressionResistancePriority(priorities.high, forAxis: axis) }
    func setContentCompressionResistancePriorityLow(axis: UILayoutConstraintAxis) { setContentCompressionResistancePriority(priorities.low, forAxis: axis) }
    func setContentCompressionResistancePriorityFittingSizeLevel(axis: UILayoutConstraintAxis) { setContentCompressionResistancePriority(priorities.fittingSizeLevel, forAxis: axis) }
    func setContentHuggingPriorityHigh(axis: UILayoutConstraintAxis) { setContentHuggingPriority(priorities.high, forAxis: axis) }
    func setContentHuggingPriorityLow(axis: UILayoutConstraintAxis) { setContentHuggingPriority(priorities.low, forAxis: axis) }
    func setContentHuggingPriorityFittingSizeLevel(axis: UILayoutConstraintAxis) { setContentHuggingPriority(priorities.fittingSizeLevel, forAxis: axis) }
}


extension UIImage {
    class func colorImage(color: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        color.set()
        UIRectFillUsingBlendMode(CGRectMake(0, 0, size.width, size.height), kCGBlendModeCopy)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


class AutolayoutMinView: UIView {
    override func intrinsicContentSize() -> CGSize {
        return CGSizeZero
    }
}

