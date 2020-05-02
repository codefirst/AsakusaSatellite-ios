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


class AsakusaSatelliteSpec : QuickSpec {
    
    private func message(body: String, htmlBody: String) -> Message? {
        try? Message.decoder.decode(Message.self, from: """
            {
            "body": "\(body.replacingOccurrences(of: "\n", with: "\\n"))",
            "html_body": "\(htmlBody)",
            "id": "1",
            "name": "nobody",
            "screen_name": "nobody",
            "profile_image_url": "http://localhost/profile.png",
            "created_at": "2015-12-31 23:59:59 +0900"
            }
            """.data(using: .utf8)!)
    }
    
    override func spec() {
        describe("Message") {
            describe("HTML") {
                it("body is same to htmlBody") {
                    let m = self.message(body: "some text", htmlBody: "some text")!
                    expect(m.hasHTML).to(beFalse())
                }
                
                it("body differ from htmlBody") {
                    let m = self.message(body: "some text", htmlBody: "<div>some text</div>")!
                    expect(m.hasHTML).to(beTrue())
                }
                
                it("HTMLs are only newlines") {
                    let m = self.message(body: "\nsome\n\ntext\n", htmlBody: "<br/>some<br/><br/>text<br/>")!
                    expect(m.hasHTML).to(beFalse())
                }
            }
        }
    }
}
