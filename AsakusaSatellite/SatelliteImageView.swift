//
//  SatelliteImageView.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/19.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import Kingfisher
import NorthLayout


private let kCellID = "Cell"


class SatelliteImageView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    var imageURLs: [NSURL] = [] {
        didSet {
            layout.invalidateLayout()
            collectionView.reloadData()
            orbitView.isHidden = imageURLs.count < 2
        }
    }
    
    let collectionView: UICollectionView
    private let layout = Layout()
    private let orbitView = OrbitView(frame: .zero)
    
    // MARK: - init
    
    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(Cell.self, forCellWithReuseIdentifier: kCellID)
        super.init(frame: frame)
        
        clipsToBounds = false
        collectionView.clipsToBounds = false
        backgroundColor = Appearance.backgroundColor
        collectionView.isUserInteractionEnabled = false // through taps
        
        orbitView.backgroundColor = backgroundColor
        collectionView.backgroundColor = backgroundColor
        collectionView.backgroundView = orbitView
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let autolayout = northLayoutFormat([:], ["collectionView": collectionView])
        autolayout("H:|[collectionView]|")
        autolayout("V:|[collectionView]|")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellID, for: indexPath) as! Cell
        let url = imageURLs[indexPath.item]
        cell.imageView.kf.cancelDownloadTask()
        cell.imageView.image = nil
        cell.imageView.kf.setImage(with: url as URL)
        
        // for layer animation
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        return cell
    }
    
    // MARK: - Cell
    
    private class Cell: UICollectionViewCell {
        let imageView = UIImageView(frame: .zero)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            imageView.clipsToBounds = true
            imageView.frame = (frame.isEmpty ? CGRect(x: 0, y: 0, width: 44, height: 44) : frame) // haneke requires initial non-zero rect
            
            let autolayout = contentView.northLayoutFormat([:], ["iv": imageView])
            autolayout("H:|[iv]|")
            autolayout("V:|[iv]|")
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        fileprivate override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
            imageView.layer.cornerRadius = layoutAttributes.size.width / 2
        }
    }
    
    // MARK: - Animations
    
    func displayLink(sender: CADisplayLink) {
        if imageURLs.count <= 1 { return }
        
        orbitView.radius = layout.radius * 1.25
        
        let time = CGFloat(NSDate().timeIntervalSince1970)
        let periodInSeconds = CGFloat(30)
        // let offset = time * 2 * CGFloat(M_PI) / periodInSeconds
        
        // NOTE:
        // invalidateLayout consume high cpu (> 60% on iPhone 6)
        // updating transform does consume less than it (~ 5% on iPhone 6)
        let xScale = CGFloat(0.20)
        let yScale = CGFloat(0.25)
        for i in 0..<imageURLs.count {
            let indexPath = IndexPath(item: i, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) {
                var t = CGAffineTransform.identity
                
                let animatedCenter = layout.centerForItemAt(percentage: time / periodInSeconds + CGFloat(i) / CGFloat(imageURLs.count), radiusScale: 1.25)
                t = t.translatedBy(x: animatedCenter.x - cell.center.x, y: animatedCenter.y - cell.center.y)
                
                let xOffset = animatedCenter.x - layout.contentSizeSide / 2
                let yOffset = animatedCenter.y - layout.contentSizeSide / 2
                t = t.translatedBy(x: 0, y: -(xOffset * xScale + yOffset * yScale))
                cell.layer.zPosition = animatedCenter.x * xScale + animatedCenter.y * yScale
                cell.transform = t
            }
        }
        
        var t = CGAffineTransform.identity
        t = t.rotated(by: -CGFloat.pi / 2 * xScale)
        t = t.scaledBy(x: 1, y: 2.5 * yScale)
        orbitView.transform = t
    }
    
    // MARK: - Layout
    
    private class Layout: UICollectionViewLayout {
        var contentSizeSide = CGFloat(0)
        var itemSide: CGFloat { return contentSizeSide / 3 }
        var itemSize: CGSize { return CGSize(width: itemSide, height: itemSide) }
        let section = 0
        var numberOfItems: Int { return collectionView?.numberOfItems(inSection: section) ?? 0 }
        var radius: CGFloat { return numberOfItems > 1 ? (contentSizeSide - itemSide) / 2 : 0 }
        
        fileprivate override func prepare() {
            let contentSize = collectionView?.bounds.size ?? .zero
            contentSizeSide = min(contentSize.width, contentSize.height)
        }
        
        func centerForItemAt(percentage: CGFloat, radiusScale: CGFloat = 1.0) -> CGPoint {
            let contentSize = collectionView?.bounds.size ?? .zero
            let center = CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
            
            let angle = CGFloat(-.pi / 2 + 2 * .pi * Double(percentage))
            return CGPoint(
                x: center.x + radius * radiusScale * cos(angle),
                y: center.y + radius * radiusScale * sin(angle))
        }
        
        fileprivate override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            let section = 0
            let numberOfItems = collectionView?.numberOfItems(inSection: section) ?? 0
            
            return [Int](0..<numberOfItems).map { n in
                let la = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: n, section: section))
                la.center = self.centerForItemAt(percentage: CGFloat(n) / CGFloat(numberOfItems ))
                la.size = self.itemSize
                return la
            }
        }

        fileprivate override var collectionViewContentSize: CGSize {
            return CGSize(width: contentSizeSide, height: contentSizeSide)
        }
    }
    
    // MARK: - ShapeLayerView
    
    private class ShapeLayerView: UIView {
        var shapeLayer: CAShapeLayer { return layer as! CAShapeLayer }
        override class var layerClass: AnyClass {return CAShapeLayer.self}
    }
    
    private class OrbitView: ShapeLayerView {
        var radius: CGFloat = 0 {
            didSet {
                if oldValue != radius {
                    layoutSubviews()
                }
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            shapeLayer.lineWidth = 1.0 / UIScreen.main.scale
            shapeLayer.strokeColor = Appearance.asakusaRed.withAlphaComponent(0.25).cgColor
            shapeLayer.fillColor = nil
        }

        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        fileprivate override func layoutSubviews() {
            super.layoutSubviews()
            
            let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
            shapeLayer.path = UIBezierPath(ovalIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)).cgPath
        }
    }
}
