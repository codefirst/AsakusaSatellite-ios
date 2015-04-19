//
//  Appearance.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/16.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit


private func RGBA(r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> UIColor {
    return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
}

private func RGB(r: UInt8, g: UInt8, b: UInt8) -> UIColor {
    return RGBA(r, g, b, 255)
}

private func GRAY(y: UInt8) -> UIColor {
    return RGB(y, y, y)
}


extension UIColor {
    var cssString: String? {
        var (r, g, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return "rgba(\(Int(r * 255)), \(Int(g * 255)), \(Int(b * 255)), \(Int(a * 255)))"
        }
        if getWhite(&r, alpha: &a) {
            return "rgba(\(Int(r * 255)), \(Int(r * 255)), \(Int(r * 255)), \(Int(a * 255)))"
        }
        return nil
    }
}


struct Appearance {
    static let asakusaRed = RGB(200, 2, 2)
    static let navBarColor = asakusaRed
    static let tintColor = asakusaRed
    static let textColorOnTintColor = UIColor.whiteColor()
    static let highlightedColor = RGB(100, 1, 1)
    static let backgroundColor = UIColor.whiteColor()
    static let lightBackgroundColor = GRAY(250)
    static let lightDarkBackgroundColor = GRAY(222)
    static let textColorOnLightDarkBackgroundColor = GRAY(128)
    static let darkBackgroundColor = GRAY(96)
    static let onepx = 1 / UIScreen.mainScreen().scale
    static let messageBodyColor = GRAY(51)
    static let messageBodyFontSize = CGFloat(14)
    
    static func install() {
        UINavigationBar.appearance().barTintColor = navBarColor
        UINavigationBar.appearance().tintColor = textColorOnTintColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: textColorOnTintColor,
        ]
        UINavigationBar.appearance().setBackgroundImage(UIImage.colorImage(navBarColor, size: CGSizeMake(1, 1)), forBarPosition: .Any, barMetrics: .Default) // no shadow
        UINavigationBar.appearance().shadowImage = UIImage() // no shadow
        
        UIToolbar.appearance().barTintColor = backgroundColor
        UIToolbar.appearance().tintColor = tintColor
        
        UIButton.appearance().tintColor = tintColor

        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    static func hiraginoW3(size: CGFloat) -> UIFont {
        return UIFont(name: "HiraKakuProN-W3", size: size) ?? UIFont.systemFontOfSize(size)
    }
    
    static func hiraginoW6(size: CGFloat) -> UIFont {
        return UIFont(name: "HiraKakuProN-W6", size: size) ?? UIFont.boldSystemFontOfSize(size)
    }
    
    static func roundRectButtonOnTintColor(title: String) -> UIButton {
        return roundRectButton(title, titleColor: self.tintColor, backgroundColor: self.backgroundColor, highlightedColor: self.highlightedColor)
    }
    
    static func roundRectButtonOnBackgroundColor(title: String) -> UIButton {
        return roundRectButton(title, titleColor: self.textColorOnTintColor, backgroundColor: self.tintColor, highlightedColor: self.highlightedColor)
    }
    
    static func roundRectButton(title: String, titleColor: UIColor, backgroundColor: UIColor, highlightedColor: UIColor) -> UIButton {
        return UIButton().tap { (b: UIButton) in
            b.clipsToBounds = true
            b.layer.cornerRadius = 4
            b.setTitle(title, forState: .Normal)
            b.setTitleColor(titleColor, forState: .Normal)
            b.setBackgroundImage(UIImage.colorImage(backgroundColor, size: CGSizeMake(1, 1)), forState: .Normal)
            b.setBackgroundImage(UIImage.colorImage(highlightedColor, size: CGSizeMake(1, 1)), forState: .Highlighted)
            b.contentEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        }
    }
    
    static func separatorView() -> UIView {
        return UIView().tap{$0.backgroundColor = UIColor(white: 0.9, alpha: 1.0)}
    }
}
