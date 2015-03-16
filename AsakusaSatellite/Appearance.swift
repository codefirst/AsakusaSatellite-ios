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


struct Appearance {
    private static let asakusaRed = RGB(200, 2, 2)
    static let barTintColor = asakusaRed
    static let tintColor = UIColor.whiteColor()
    static let highlightedColor = RGB(100, 1, 1)
    
    static func install() {
        UINavigationBar.appearance().barTintColor = barTintColor
        UINavigationBar.appearance().tintColor = tintColor
        UIToolbar.appearance().barTintColor = barTintColor
        UIToolbar.appearance().tintColor = tintColor
    }
    
    static func roundRectButton(title: String) -> UIButton {
        return UIButton().tap { (b: UIButton) in
            b.clipsToBounds = true
            b.layer.cornerRadius = 4
            b.setTitle(title, forState: .Normal)
            b.setTitleColor(self.barTintColor, forState: .Normal)
            b.setBackgroundImage(UIImage.colorImage(self.tintColor, size: CGSizeMake(1, 1)), forState: .Normal)
            b.setBackgroundImage(UIImage.colorImage(self.highlightedColor, size: CGSizeMake(1, 1)), forState: .Highlighted)
            b.contentEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        }
    }
}
