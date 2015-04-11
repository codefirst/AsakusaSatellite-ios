//
//  AsakusaSatelliteSpec.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/04/11.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import Foundation
import Quick
import Nimble
import AsakusaSatelliteApp
import AsakusaSatellite
import SwiftyJSON


class AsakusaSatelliteSpec : QuickSpec {
    
    private func message(#body: String, htmlBody: String) -> Message? {
        return Message(SwiftyJSON.JSON([
            "body": body,
            "html_body": htmlBody,
            "id": "1",
            "name": "nobody",
            "screen_name": "nobody",
            "profile_image_url": "http://localhost/profile.png",
            "created_at": "2015-12-31 23:59:59 +0900",
            ]))
    }
    
    override func spec() {
        describe("Message") {
            describe("HTML") {
                it("does not have HTML when body == htmlBody") {
                    let m = self.message(body: "some text", htmlBody: "some text")!
                    expect(m.hasHTML).to(beFalse())
                }
                
                it("has HTML when body != htmlBody") {
                    let m = self.message(body: "some text", htmlBody: "<div>some text</div>")!
                    expect(m.hasHTML).to(beTrue())
                }
            }
        }
    }
}