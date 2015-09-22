//
//  ImageCollectionViewCell.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/29.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import NorthLayout

class ImageCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView(frame: CGRectZero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = CGRectMake(0, 0, frame.width, frame.height)
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        
        let autolayout = contentView.northLayoutFormat([:], ["v" : imageView])
        autolayout("H:|[v]|")
        autolayout("V:|[v]|")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.hnk_cancelSetImage()
        imageView.image = nil
    }
}
