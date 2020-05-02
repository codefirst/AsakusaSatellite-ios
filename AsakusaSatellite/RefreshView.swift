//
//  RefreshView.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/22.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import Ikemen

class RefreshView: UIView, UIScrollViewDelegate {
    var onRefresh: ((_ completion: @escaping () -> Void) -> Void)?
    
    let statusLabel = UILabel(frame: .zero) ※ { l in
        l.textAlignment = .center
        l.font = UIFont.systemFont(ofSize: 18)
        l.textColor = Appearance.textColorOnLightDarkBackgroundColor
        return
    }
    
    enum State {
        case None, ReadyToRefresh, Refreshing
        
        var backgroundColor: UIColor {
            switch self {
            case .None: return Appearance.lightDarkBackgroundColor
            case .ReadyToRefresh: return Appearance.darkBackgroundColor
            case .Refreshing: return Appearance.lightDarkBackgroundColor
            }
        }
        
        var statusText: String {
            switch self {
            case .None: return NSLocalizedString("refresh", comment: "")
            case .ReadyToRefresh: return NSLocalizedString("refresh", comment: "")
            case .Refreshing: return NSLocalizedString("refreshing...", comment: "")
            }
        }
    }
    var state: State = .None {
        didSet {
            updateState()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if statusLabel.superview == nil && bounds.size.width >= 16 {
            // delay layout until self.size is non-zero
            
            let autolayout = northLayoutFormat(["p": 8, "pp": 16], [
                "status": statusLabel,
                ])
            autolayout("H:|-p-[status]-p-|")
            autolayout("V:[status]-pp-|")
            updateState()
        }
    }
    
    func updateState() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                self.backgroundColor = self.state.backgroundColor
                self.statusLabel.text = self.state.statusText
                self.setNeedsUpdateConstraints()
        }, completion: nil)
    }
    
    func refresh() {
        state = .Refreshing
        onRefresh?() {
            self.state = .None
        }        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if state == .Refreshing { return }
        
        let heightForNothing = frame.size.height - statusLabel.frame.origin.y
        let heightForReadyToRefresh = heightForNothing + 88
        let overScrollHeight = scrollView.contentOffset.y + scrollView.frame.height - scrollView.contentSize.height
        
        if overScrollHeight > heightForReadyToRefresh {
            state = .ReadyToRefresh
        } else {
            state = .None
        }
        
        if overScrollHeight - heightForNothing > 0 {
            let ratio = min(1.0, (overScrollHeight - heightForNothing) / (heightForReadyToRefresh - heightForNothing))
            
            var t = CATransform3DIdentity
            t.m34 = -1.0 / 100
            t = CATransform3DRotate(t, ratio * CGFloat.pi / 2, 1, 0, 0)
            statusLabel.layer.transform = t
        } else {
            statusLabel.layer.transform = CATransform3DIdentity
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                self.statusLabel.layer.transform = CATransform3DIdentity
            }, completion: nil)
        
        if state == .ReadyToRefresh {
            refresh()
        }
    }
}
