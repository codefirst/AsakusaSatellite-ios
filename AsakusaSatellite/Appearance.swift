//
//  Appearance.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/16.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import Ikemen


private func RGBA(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) -> UIColor {
    return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
}

private func RGB(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> UIColor {
    return RGBA(r, g, b, 255)
}

private func GRAY(_ y: UInt8) -> UIColor {
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
    static let navBarColor: UIColor = {
        guard #available(iOS 13, *) else { return asakusaRed }
        return UIColor {
            switch $0.userInterfaceStyle {
            case .dark: return .systemBackground
            case .light, .unspecified: return asakusaRed
            @unknown default: return asakusaRed
            }
        }
    }()
    static let tintColor = asakusaRed
    static let textColorOnTintColor: UIColor = {
        guard #available(iOS 13, *) else { return backgroundColor }
        return UIColor {
            switch $0.userInterfaceStyle {
            case .dark: return asakusaRed
            case .light, .unspecified: return backgroundColor
            @unknown default: return backgroundColor
            }
        }
    }()
    static let highlightedColor = RGB(100, 1, 1)
    static let backgroundColor: UIColor = {
        guard #available(iOS 13, *) else { return .white }
        return .systemBackground
    }()
    static let lightBackgroundColor: UIColor = {
        guard #available(iOS 13, *) else { return GRAY(250) }
        return .secondarySystemBackground
    }()
    static let lightDarkBackgroundColor: UIColor = {
        guard #available(iOS 13, *) else { return GRAY(222) }
        return .tertiarySystemBackground
    }()
    static let textColorOnLightDarkBackgroundColor: UIColor = {
        guard #available(iOS 13, *) else { return GRAY(128) }
        return .tertiaryLabel
    }()
    static let darkBackgroundColor: UIColor = {
        guard #available(iOS 13, *) else { return GRAY(96) }
        return .secondarySystemGroupedBackground
    }()
    static let onepx = 1 / UIScreen.main.scale
    static let messageBodyColor: UIColor = {
        guard #available(iOS 13, *) else { return GRAY(51) }
        return .label
    }()
    static let messageDateColor: UIColor = {
        guard #available(iOS 13, *) else { return GRAY(127) }
        return .secondaryLabel
    }()
    static let messageBodyFontSize = CGFloat(14)
    
    static func install() {
        UINavigationBar.appearance().barTintColor = navBarColor
        UINavigationBar.appearance().tintColor = textColorOnTintColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: textColorOnTintColor,
        ]
        UINavigationBar.appearance().shadowImage = UIImage() // no shadow
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: textColorOnTintColor], for: .normal)
        
        UIToolbar.appearance().barTintColor = backgroundColor
        UIToolbar.appearance().tintColor = tintColor
        
        UIButton.appearance().tintColor = tintColor
    }
    
    static func hiraginoW3(_ size: CGFloat) -> UIFont {
        return UIFont(name: "HiraKakuProN-W3", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func hiraginoW6(_ size: CGFloat) -> UIFont {
        return UIFont(name: "HiraKakuProN-W6", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    static func roundRectButtonOnTintColor(_ title: String) -> UIButton {
        return roundRectButton(title: title, titleColor: self.tintColor, backgroundColor: self.backgroundColor, highlightedColor: self.highlightedColor)
    }
    
    static func roundRectButtonOnBackgroundColor(_ title: String) -> UIButton {
        return roundRectButton(title: title, titleColor: self.backgroundColor, backgroundColor: self.tintColor, highlightedColor: self.highlightedColor)
    }
    
    static func roundRectButton(title: String, titleColor: UIColor, backgroundColor: UIColor, highlightedColor: UIColor) -> UIButton {
        return UIButton() ※ { b in
            b.clipsToBounds = true
            b.layer.cornerRadius = 4
            b.setTitle(title, for: .normal)
            b.setTitleColor(titleColor, for: .normal)
            b.setBackgroundImage(UIImage.colorImage(color: backgroundColor, size: CGSize(width: 1, height: 1)), for: .normal)
            b.setBackgroundImage(UIImage.colorImage(color: highlightedColor, size: CGSize(width: 1, height: 1)), for: .highlighted)
            b.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        }
    }
    
    static func separatorView() -> UIView {
        return UIView() ※ {
            $0.backgroundColor = {
                guard #available(iOS 13, *) else { return UIColor(white: 0.9, alpha: 1.0) }
                return .separator
            }()
        }
    }
}
