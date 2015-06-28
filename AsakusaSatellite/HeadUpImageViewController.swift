//
//  HeadUpImageViewController.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/29.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit

class HeadUpImageViewController: UIViewController {
    let imageView: UIImageView
    var image: UIImage? {
        didSet {
            self.showImageView()
        }
    }
    
    init(imageURL: NSURL) {
        imageView = UIImageView(frame: CGRectMake(0, 0, 320, 320))
        imageView.contentMode = .ScaleAspectFit
        imageView.hidden = true
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .OverFullScreen
        modalTransitionStyle = .CrossDissolve
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        imageView.hnk_setImageFromURL(imageURL, success: {self.image = $0})
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "close:"))
        
        let autolayout = view.autolayoutFormat(nil, ["image": imageView])
        autolayout("H:|[image]|")
        autolayout("V:|[image]|")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        showImageView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        hideImageView()
        imageView.hnk_cancelSetImage()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func showImageView() {
        if image == nil { return }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        imageView.image = image
        imageView.transform = CGAffineTransformMakeScale(1.1, 1.1)
        imageView.alpha = 0.0
        imageView.hidden = false
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            options: [],
            animations: { () -> Void in
                self.imageView.transform = CGAffineTransformIdentity
                self.imageView.alpha = 1.0
            }, completion: nil)
    }
    
    func hideImageView() {
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            options: [],
            animations: { () -> Void in
                self.imageView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                self.imageView.alpha = 0.0
            }, completion: nil)
    }
    
    func close(sender: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
