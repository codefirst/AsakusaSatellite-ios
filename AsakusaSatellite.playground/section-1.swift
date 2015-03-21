// Playground - noun: a place where people can play

import UIKit
import HanekeSwift



//// Utilities

// workaround for swift crash at use of UILayoutPriority
private let priorities = (high: Float(750), low: Float(250), fittingSizeLevel: Float(50))

extension UIView {
    func autolayoutFormat(metrics: [String:CGFloat]?, _ views: [String:UIView]) -> String -> Void {
        return self.autolayoutFormat(metrics, views, options: NSLayoutFormatOptions.allZeros)
    }
    
    func autolayoutFormat(metrics: [String:CGFloat]?, _ views: [String:UIView], options: NSLayoutFormatOptions) -> String -> Void {
        for v in views.values {
            if !v.isDescendantOfView(self) {
                v.setTranslatesAutoresizingMaskIntoConstraints(false)
                self.addSubview(v)
            }
        }
        return { (format: String) in
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: options, metrics: metrics, views: views))
        }
    }
    
    func addEqualConstraint(attribute: NSLayoutAttribute, view: UIView, toView: UIView) {
        addConstraint(NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .Equal, toItem: toView, attribute: attribute, multiplier: 1, constant: 0))
    }
    
    func addCenterXConstraint(view: UIView) { addEqualConstraint(.CenterX, view: view, toView: self) }
    func addCenterYConstraint(view: UIView) { addEqualConstraint(.CenterY, view: view, toView: self) }
    
    // workaround for swift crash at use of UILayoutPriority
    func setContentCompressionResistancePriorityHigh(axis: UILayoutConstraintAxis) { setContentCompressionResistancePriority(priorities.high, forAxis: axis) }
    func setContentCompressionResistancePriorityLow(axis: UILayoutConstraintAxis) { setContentCompressionResistancePriority(priorities.low, forAxis: axis) }
    func setContentCompressionResistancePriorityFittingSizeLevel(axis: UILayoutConstraintAxis) { setContentCompressionResistancePriority(priorities.fittingSizeLevel, forAxis: axis) }
    func setContentHuggingPriorityHigh(axis: UILayoutConstraintAxis) { setContentHuggingPriority(priorities.high, forAxis: axis) }
    func setContentHuggingPriorityLow(axis: UILayoutConstraintAxis) { setContentHuggingPriority(priorities.low, forAxis: axis) }
    func setContentHuggingPriorityFittingSizeLevel(axis: UILayoutConstraintAxis) { setContentHuggingPriority(priorities.fittingSizeLevel, forAxis: axis) }
}

////

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
            layoutAttributes.size
            imageView.layer.cornerRadius = layoutAttributes.size.width / 2
        }
    }
    
    // MARK: - Layout
    
    private class Layout: UICollectionViewLayout {
        private var contentSizeSide = CGFloat(0)
        private var itemSide: CGFloat { return contentSizeSide / 2.75 }
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
                la.center
                la.size = self.itemSize
                la.size
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


let sat = SatelliteImageView(frame: CGRectMake(0, 0, 256, 128))
sat.layoutIfNeeded()
sat.collectionView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
sat.imageURLs = [
    "https://dl.dropboxusercontent.com/u/4388504/yuna.png",
    "https://dl.dropboxusercontent.com/u/4388504/yuna.png",
    "https://dl.dropboxusercontent.com/u/4388504/yuna.png",
    "https://dl.dropboxusercontent.com/u/4388504/yuna.png",
    "https://dl.dropboxusercontent.com/u/4388504/yuna.png",
//    "https://dl.dropboxusercontent.com/u/4388504/yuna.png",
    ].map{NSURL(string: $0)!}
sat

NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 3.0))
sat

