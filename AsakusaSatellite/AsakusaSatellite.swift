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
        let simplyTranslated = body.stringByReplacingOccurrencesOfString("\n", withString: "<br/>", options: nil, range: nil)
        return simplyTranslated != htmlBody
    }
    func html(var bodyFontSize: CGFloat = Appearance.messageBodyFontSize) -> String {
        return "<!DOCTYPE html>"
        + "<html>"
        + "<head>"
        + "<meta content=\"width=device-width, initial-scale=1.0, maximum-scale=4.0, user-scalable=yes\" name=\"viewport\">"
        + "<link href=\"assets/application.css\" media=\"screen\" rel=\"stylesheet\" type=\"text/css\">"
        + "<style>body{font-size: \(bodyFontSize); margin:0; padding:0; background-color: white;} iframe{margin-left:-5px;}</style>"
        + "</head>"
        + "<body><div id=\"AsakusaSatMessageContent\" style=\"padding: 8px;\">\(htmlBody)</div></body>"
        + "</html>"
    }
}
