//
//  SatelliteImageView.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/19.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import HanekeSwift


private let kCellID = "Cell"


class SatelliteImageView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    var imageURLs: [NSURL] = [] {
        didSet {
            layout.invalidateLayout()
            collectionView.reloadData()
        }
    }
    
    let collectionView: UICollectionView
    private let layout = Layout()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(Cell.self, forCellWithReuseIdentifier: kCellID)
        super.init(frame: frame)
        
        backgroundColor = UIColor.blueColor() // stub
        collectionView.backgroundColor = UIColor.greenColor() // stub
        
        let autolayout = autolayoutFormat(nil, ["collectionView": collectionView])
        autolayout("H:|[collectionView]")
        autolayout("V:|[collectionView]")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellID, forIndexPath: indexPath) as Cell
        let url = imageURLs[indexPath.item]
        cell.imageView.hnk_setImageFromURL(url)
        return cell
    }
    
    // MARK: - Cell
    
    private class Cell: UICollectionViewCell {
        let imageView = UIImageView(frame: CGRectZero)
    }
    
    // MARK: - Layout
    
    private class Layout: UICollectionViewLayout {
        
    }
}
