//
//  AsakusaSatellite.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/04/11.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import Foundation
import AsakusaSatellite

extension Message {
    var hasHTML: Bool {
        let simplyTranslated = body.stringByReplacingOccurrencesOfString("\n", withString: "<br/>", options: [], range: nil)
        return simplyTranslated != htmlBody
    }
    func html(bodyFontSize: CGFloat = Appearance.messageBodyFontSize, bodyColor: UIColor = Appearance.messageBodyColor) -> String {
        let bodyColorCSS = bodyColor.cssString ?? "black"
        return "<!DOCTYPE html>"
        + "<html>"
        + "<head>"
        + "<meta content=\"width=device-width, initial-scale=1.0, maximum-scale=4.0, user-scalable=yes\" name=\"viewport\">"
        + "<link href=\"assets/application.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
        + "<style>body{font-family: 'Hiragino Kaku Gothic ProN'; font-size: \(bodyFontSize)px; color: \(bodyColorCSS); margin:0; padding:0; background-color: white;} iframe{margin-left:-5px;} .thumbnail img {max-width: 100%;}</style>"
        + "</head>"
        + "<body><div id=\"AsakusaSatMessageContent\" style=\"padding: 8px;\">\(htmlBody)</div></body>"
        + "</html>"
    }
}
