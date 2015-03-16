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
    static let tintColor = asakusaRed
}
