//
//  UserDefaults.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/18.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import Foundation


private let defaults = NSUserDefaults.standardUserDefaults()

private let kApiKey = "apikey"

private func saveObject(value: AnyObject?, forKey: String) {
    defaults.setObject(value, forKey: forKey)
    defaults.synchronize()
}


struct UserDefaults {
    static var apiKey: String? {
        get { return defaults.stringForKey(kApiKey) }
        set { saveObject(newValue, forKey: kApiKey) }
    }
}
