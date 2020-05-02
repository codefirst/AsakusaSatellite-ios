//
//  RoomList.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2016/01/16.
//  Copyright © 2016年 codefirst. All rights reserved.
//

import Foundation
import AppGroup
import AsakusaSatellite


private let cachedRoomListFile = AppGroup.path(forResource: "Library/Caches/rooms.json")

// FIXME: need more design
struct CachedRoomList {
    static func loadCachedRoomList() -> [Room]? {
        guard let f = cachedRoomListFile else { return nil }
        return try? [Room](file: f)
    }

    static func cacheRoomList(_ many: [Room]) {
        guard let f = cachedRoomListFile else { return }
        _ = many.saveToFile(f)
    }
}
