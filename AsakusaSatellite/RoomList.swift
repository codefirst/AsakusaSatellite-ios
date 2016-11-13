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


private let cachedRoomListFile = AppGroup.path(forResource: "Caches/rooms.json")

// FIXME: need more design
struct CachedRoomList {
    static func loadCachedRoomList() -> [Room]? {
        guard let f = cachedRoomListFile, let many = Many<Room>(file: f) else { return nil }
        return many.items
    }

    static func cacheRoomList(_ many: Many<Room>) {
        guard let f = cachedRoomListFile else { return }
        _ = many.saveToFile(f)
    }
}
