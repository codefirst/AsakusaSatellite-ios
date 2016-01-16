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


private let cachedRoomListFile = AppGroup.pathForResource("Caches/rooms.json")

// FIXME: need more design
struct CachedRoomList {
    static func loadCachedRoomList() -> [Room]? {
        guard let many = Many<Room>(file: cachedRoomListFile) else { return nil }
        return many.items
    }

    static func cacheRoomList(many: Many<Room>) {
        many.saveToFile(cachedRoomListFile)
    }
}
