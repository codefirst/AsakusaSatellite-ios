//
//  MessageView.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/21.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import AsakusaSatellite


private let dateFormatter: NSDateFormatter = NSDateFormatter().tap{$0.dateFormat = "yyyy-MM-dd HH:mm"}


class MessageView: UIView {
    var message: Message? {
        didSet {
            // clear for reusing MessageView, for example, contained in a cell
            iconView.hnk_cancelSetImage()
            iconView.image = nil
            
            if let u: NSURL = (message.map{NSURL(string: $0.profileImageURL)} ?? nil)  {
                if CGRectIsEmpty(iconView.frame) {
                    iconView.frame = CGRectMake(iconView.frame.origin.x, iconView.frame.origin.y, 44, 44) // haneke requires non-zero imageview
                }
                iconView.hnk_setImageFromURL(u)
            }
            
            nameLabel.text = message?.name
            dateLabel.text = message.map{dateFormatter.stringFromDate($0.createdAt)}
            bodyLabel.text = message?.body
        }
    }
    let iconView = UIImageView(frame: CGRectZero)
    let nameLabel = UILabel()
    let dateLabel = UILabel()
    let bodyLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let iconSize = CGFloat(32)
        iconView.layer.cornerRadius = iconSize / 2
        iconView.clipsToBounds = true
        
        nameLabel.numberOfLines = 1
        nameLabel.font = Appearance.hiraginoW6(13)
        nameLabel.textColor = UIColor.blackColor()
        nameLabel.setContentCompressionResistancePriorityHigh(.Vertical)
        
        dateLabel.numberOfLines = 1
        dateLabel.font = Appearance.hiraginoW3(10)
        dateLabel.textColor = UIColor.grayColor()
        dateLabel.textAlignment = .Right
        dateLabel.setContentCompressionResistancePriorityHigh(.Vertical)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.font = Appearance.hiraginoW3(14)
        bodyLabel.textColor = UIColor.blackColor()
        bodyLabel.setContentCompressionResistancePriorityHigh(.Vertical)
        
        let autolayout = autolayoutFormat([
            "sp": 4,
            "p": 8,
            "iconSize": iconSize,
            "onepx": 1 / UIScreen.mainScreen().scale,
            ], [
                "icon": iconView,
                "name": nameLabel,
                "date": dateLabel,
                "body": bodyLabel,
                "separator": UIView().tap{$0.backgroundColor = UIColor(white: 0.9, alpha: 1.0)},
            ])
        autolayout("H:|-p-[icon(==iconSize)]-p-[name][date]-p-|")
        autolayout("H:|-p-[body]-p-|")
        autolayout("H:|[separator]|")
        autolayout("V:|-p-[icon(==iconSize)]-p-[body]-p-[separator(==onepx)]|")
        autolayout("V:|-sp-[date]")
        addEqualConstraint(.CenterY, view: nameLabel, toView: iconView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
