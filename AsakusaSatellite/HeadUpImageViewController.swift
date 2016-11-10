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
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        imageView.hnk_setImageFromURL(imageURL as URL, success: {self.image = $0})
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close(_:))))
        
        let autolayout = view.northLayoutFormat([:], ["image": imageView])
        autolayout("H:|[image]|")
        autolayout("V:|[image]|")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showImageView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideImageView()
        imageView.hnk_cancelSetImage()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func showImageView() {
        if image == nil { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        imageView.image = image
        imageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        imageView.alpha = 0.0
        imageView.isHidden = false
        UIView.animate(withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            options: [],
            animations: { () -> Void in
                self.imageView.transform = .identity
                self.imageView.alpha = 1.0
            }, completion: nil)
    }
    
    func hideImageView() {
        UIView.animate(withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.0,
            options: [],
            animations: { () -> Void in
                self.imageView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                self.imageView.alpha = 0.0
            }, completion: nil)
    }
    
    func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
