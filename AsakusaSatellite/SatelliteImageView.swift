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
        
        backgroundColor = UIColor.whiteColor()
        collectionView.backgroundColor = backgroundColor
        collectionView.userInteractionEnabled = false // through taps
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let autolayout = autolayoutFormat(nil, ["collectionView": collectionView])
        autolayout("H:|[collectionView]|")
        autolayout("V:|[collectionView]|")
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
        cell.imageView.hnk_cancelSetImage()
        cell.imageView.image = nil
        cell.imageView.hnk_setImageFromURL(url)
        return cell
    }
    
    // MARK: - Cell
    
    private class Cell: UICollectionViewCell {
        let imageView = UIImageView(frame: CGRectZero)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            imageView.clipsToBounds = true
            imageView.frame = (CGRectIsEmpty(frame) ? CGRectMake(0, 0, 44, 44) : frame) // haneke requires initial non-zero rect
            
            let autolayout = contentView.autolayoutFormat(nil, ["iv": imageView])
            autolayout("H:|[iv]|")
            autolayout("V:|[iv]|")
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
            imageView.layer.cornerRadius = layoutAttributes.size.width / 2
        }
    }
    
    // MARK: - Layout
    
    private class Layout: UICollectionViewLayout {
        private var contentSizeSide = CGFloat(0)
        private var itemSide: CGFloat { return contentSizeSide / 3 }
        private var itemSize: CGSize { return CGSizeMake(itemSide, itemSide) }
        
        private override func prepareLayout() {
            let contentSize = collectionView?.bounds.size ?? CGSizeZero
            contentSizeSide = min(contentSize.width, contentSize.height)
        }
        
        private override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
            let section = 0
            let numberOfItems = collectionView?.numberOfItemsInSection(section) ?? 0
            
            let radius = (contentSizeSide - itemSide) / 2
            let contentSize = collectionView?.bounds.size ?? CGSizeZero
            let center = CGPointMake(contentSize.width / 2, contentSize.height / 2)
            
            return [Int](0..<numberOfItems).map { n in
                let la = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: n, inSection: section))
                let angle = CGFloat(-M_PI_2 + 2 * M_PI * Double(n) / Double(numberOfItems))
                la.center = CGPointMake(
                    center.x + radius * cos(angle),
                    center.y + radius * sin(angle))
                la.size = self.itemSize
                return la
            }
        }
        
        private override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
            indexPath
            return nil
        }
        
        private override func collectionViewContentSize() -> CGSize {
            return CGSizeMake(contentSizeSide, contentSizeSide)
        }
    }
}
