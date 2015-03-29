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
private let kCellID = "Cell"
private let kPadding = CGFloat(8)
private let kAttachmentsSize = CGSizeMake(256, 64)


class MessageView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    var message: Message? {
        didSet {
            if let u: NSURL = (message.map{NSURL(string: $0.profileImageURL)} ?? nil)  {
                if CGRectIsEmpty(iconView.frame) {
                    iconView.frame = CGRectMake(iconView.frame.origin.x, iconView.frame.origin.y, 44, 44) // haneke requires non-zero imageview
                }
                iconView.hnk_setImageFromURL(u)
            }
            
            nameLabel.text = message?.name
            dateLabel.text = message.map{dateFormatter.stringFromDate($0.createdAt)}
            bodyLabel.text = message?.body
            attachments = message?.imageAttachments ?? []
        }
    }
    var attachments: [Attachment] = [] {
        didSet {
            attachmentsViewConstraint.constant = attachments.count > 0 ? kAttachmentsSize.height + kPadding : 0
            attachmentsView.reloadData()
        }
    }
    let iconView = UIImageView(frame: CGRectZero)
    let nameLabel = UILabel()
    let dateLabel = UILabel()
    let bodyLabel = UILabel()
    let attachmentsView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout().tap { (l: UICollectionViewFlowLayout) in
        l.scrollDirection = .Horizontal
        l.itemSize = kAttachmentsSize
        l.sectionInset = UIEdgeInsetsMake(0, kPadding, kPadding, 0)
    })
    let attachmentsViewConstraint: NSLayoutConstraint
    
    override init(frame: CGRect) {
        attachmentsViewConstraint = NSLayoutConstraint(item: attachmentsView, attribute: .Height, relatedBy: .Equal, toItem: attachmentsView, attribute: .Height, multiplier: 0, constant: 0)
        attachmentsView.addConstraint(attachmentsViewConstraint)
        
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
        
        attachmentsView.dataSource = self
        attachmentsView.delegate = self
        attachmentsView.registerClass(ImageCell.self, forCellWithReuseIdentifier: kCellID)
        attachmentsView.backgroundColor = Appearance.backgroundColor
        attachmentsView.showsHorizontalScrollIndicator = false
        attachmentsView.showsVerticalScrollIndicator = false
        
        let autolayout = autolayoutFormat([
            "sp": kPadding / 2,
            "p": kPadding,
            "iconSize": iconSize,
            "onepx": Appearance.onepx,
            ], [
                "icon": iconView,
                "name": nameLabel,
                "date": dateLabel,
                "body": bodyLabel,
                "attachments": attachmentsView,
                "separator": Appearance.separatorView()
            ])
        autolayout("H:|-p-[icon(==iconSize)]-p-[name][date]-p-|")
        autolayout("H:|-p-[body]-p-|")
        autolayout("H:|[attachments]|")
        autolayout("H:|[separator]|")
        autolayout("V:|-p-[icon(==iconSize)]-p-[body]-p-[attachments][separator(==onepx)]|")
        autolayout("V:|-sp-[date]")
        addEqualConstraint(.CenterY, view: nameLabel, toView: iconView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func layoutSize(forMessage m: Message, forWidth w: CGFloat) -> CGSize {
        struct LayoutStatic { static let view = MessageView(frame: CGRectZero) }
        let v = LayoutStatic.view
        // only body and attachments affects the layout size
        v.bodyLabel.text = m.body
        v.attachments = m.attachments
        return v.systemLayoutSizeFittingSize(CGSizeMake(w, 70), withHorizontalFittingPriority: 1000, verticalFittingPriority: 50)
    }
    
    func prepareForReuse() {
        // clear for reusing MessageView, for example, contained in a cell
        
        iconView.hnk_cancelSetImage()
        iconView.image = nil
        
        attachmentsViewConstraint.constant = 0 // UITableView.dequeue cause layout before contents set that may result in autolayout error
    }
    
    // MARK: - CollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellID, forIndexPath: indexPath) as ImageCell

        if let url = NSURL(string: attachments[indexPath.item].url) {
            cell.imageView.hnk_setImageFromURL(url)
        } else {
            cell.imageView.hnk_cancelSetImage()
            cell.imageView.image = nil
        }
        
        return cell
    }
    
    private class ImageCell: UICollectionViewCell {
        let imageView = UIImageView(frame: CGRectMake(0, 0, kAttachmentsSize.width, kAttachmentsSize.height))
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            imageView.contentMode = .ScaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 4
            
            let autolayout = contentView.autolayoutFormat(nil, ["v" : imageView])
            autolayout("H:|[v]|")
            autolayout("V:|[v]|")
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
