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
    let imageView = UIImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        imageView.contentMode = .scaleAspectFill
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
        
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
}
