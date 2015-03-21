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
            stopAnimation()
            
            layout.invalidateLayout()
            collectionView.reloadData()
            
            if imageURLs.count > 0 {
                startAnimation()
            }
        }
    }
    
    let collectionView: UICollectionView
    private let layout = Layout()
    
    private var displayLink: CADisplayLink?
    
    // MARK: - init
    
    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.registerClass(Cell.self, forCellWithReuseIdentifier: kCellID)
        super.init(frame: frame)
        
        clipsToBounds = false
        collectionView.clipsToBounds = false
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
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        stopAnimation()
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
        
        // for layer animation
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
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
    
    // MARK: - Animations
    
    private func startAnimation() {
        stopAnimation()
        displayLink = CADisplayLink(target: self, selector: "displayLink:")
        displayLink?.frameInterval = 2
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func displayLink(sender: CADisplayLink) {
        let time = CGFloat(NSDate().timeIntervalSince1970)
        let periodInSeconds = CGFloat(30)
        let offset = time * 2 * CGFloat(M_PI) / periodInSeconds
        
        // NOTE:
        // invalidateLayout consume high cpu (> 60% on iPhone 6)
        // updating transform does consume less than it (~ 5% on iPhone 6)
        for i in 0..<imageURLs.count {
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                var t = CGAffineTransformIdentity
                
                let animatedCenter = layout.centerForItemAt(percentage: time / periodInSeconds + CGFloat(i) / CGFloat(imageURLs.count), radiusScale: 1.25)
                t = CGAffineTransformTranslate(t, animatedCenter.x - cell.center.x, animatedCenter.y - cell.center.y)
                
                let xScale = CGFloat(0.20)
                let yScale = CGFloat(0.25)
                let xOffset = animatedCenter.x - layout.contentSizeSide / 2
                let yOffset = animatedCenter.y - layout.contentSizeSide / 2
                t = CGAffineTransformTranslate(t, 0, -(xOffset * xScale + yOffset * yScale))
                cell.layer.zPosition = animatedCenter.x * xScale + animatedCenter.y * yScale
                cell.transform = t
            }
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
        
        func centerForItemAt(#percentage: CGFloat, radiusScale: CGFloat = 1.0) -> CGPoint {
            let section = 0
            let numberOfItems = collectionView?.numberOfItemsInSection(section) ?? 0
            
            let radius = numberOfItems > 1 ? (contentSizeSide - itemSide) / 2 : 0
            let contentSize = collectionView?.bounds.size ?? CGSizeZero
            let center = CGPointMake(contentSize.width / 2, contentSize.height / 2)
            
            let angle = CGFloat(-M_PI_2 + 2 * M_PI * Double(percentage))
            return CGPointMake(
                center.x + radius * radiusScale * cos(angle),
                center.y + radius * radiusScale * sin(angle))
        }
        
        private override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
            let section = 0
            let numberOfItems = collectionView?.numberOfItemsInSection(section) ?? 0
            
            return [Int](0..<numberOfItems).map { n in
                let la = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: n, inSection: section))
                la.center = self.centerForItemAt(percentage: CGFloat(n) / CGFloat(numberOfItems ))
                la.size = self.itemSize
                return la
            }
        }
        
        private override func collectionViewContentSize() -> CGSize {
            return CGSizeMake(contentSizeSide, contentSizeSide)
        }
    }
}
