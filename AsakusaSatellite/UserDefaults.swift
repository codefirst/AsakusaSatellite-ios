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


private let standardDefaults = Foundation.UserDefaults.standard
private let appGroupDefaults = AppGroup.userDefaults()!

private let kApiKey = "apikey"
private let kCurrentRoomJsonKey = "currentRoomJson"

private func saveObject(_ defaults: Foundation.UserDefaults = standardDefaults, value: AnyObject?, forKey: String) {
    defaults.set(value, forKey: forKey)
    defaults.synchronize()
}


struct UserDefaults {
    static var apiKey: String? {
        get { return appGroupDefaults.string(forKey: kApiKey) }
        set { saveObject(appGroupDefaults, value: newValue as AnyObject?, forKey: kApiKey) }
    }

    static var currentRoom: Room? {
        get {
            let jsonData = appGroupDefaults.string(forKey: kCurrentRoomJsonKey)?.data(using: .utf8)
        return jsonData.flatMap{Room(json: JSON(data: $0))}
        }
        set {
            saveObject(appGroupDefaults, value: newValue?.json.rawString() as AnyObject?, forKey: kCurrentRoomJsonKey)
        }
    }
}
