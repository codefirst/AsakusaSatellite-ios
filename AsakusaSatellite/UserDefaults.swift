//
//  UserDefaults.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/18.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import Foundation
import AppGroup
import AsakusaSatellite
import SwiftyJSON


private let standardDefaults = NSUserDefaults.standardUserDefaults()
private let appGroupDefaults = AppGroup.userDefaults()

private let kApiKey = "apikey"
private let kCurrentRoomJsonKey = "currentRoomJson"

private func saveObject(defaults: NSUserDefaults = standardDefaults, value: AnyObject?, forKey: String) {
    defaults.setObject(value, forKey: forKey)
    defaults.synchronize()
}


struct UserDefaults {
    static var apiKey: String? {
        get { return appGroupDefaults.stringForKey(kApiKey) }
        set { saveObject(appGroupDefaults, value: newValue, forKey: kApiKey) }
    }

    static var currentRoom: Room? {
        get {
        let jsonData = appGroupDefaults.stringForKey(kCurrentRoomJsonKey)?.dataUsingEncoding(NSUTF8StringEncoding)
        return jsonData.flatMap{Room(json: JSON(data: $0))}
        }
        set {
            saveObject(appGroupDefaults, value: newValue?.json.rawString(), forKey: kCurrentRoomJsonKey)
        }
    }
}
