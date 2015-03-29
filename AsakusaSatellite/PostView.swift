//
//  PostView.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/22.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit


private let kCellID = "Cell"


class PostView: UIView, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    let textField = UITextField()
    private let postAccessoryView = PostAccessoryView(frame: CGRectZero)
    let sendButton = Appearance.roundRectButtonOnBackgroundColor(NSLocalizedString("Send", comment: ""))
    
    typealias Attachment = (data: NSData, ext: String)
    var attachments: [Attachment] = []
    
    var onPost: ((text: String, attachments: [Attachment], completion: (clearField: Bool) -> Void) -> Void)?
    weak var containigViewController: UIViewController?
    
    override init() {
        super.init(frame: CGRectMake(0, 0, 320, 50))
        autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin // table footer does not support autolayout
        
        backgroundColor = Appearance.lightBackgroundColor
        
        textField.tap { (tf: UITextField) in
            tf.placeholder = NSLocalizedString("message", comment: "")
            tf.font = Appearance.hiraginoW3(14)
            tf.backgroundColor = Appearance.backgroundColor
            tf.borderStyle = .RoundedRect
            tf.delegate = self
            tf.addTarget(self, action: "textChanged:", forControlEvents: .EditingChanged)
            tf.setContentCompressionResistancePriorityHigh(.Horizontal)

            self.postAccessoryView.photoButton.addTarget(self, action: "addPhoto:", forControlEvents: .TouchUpInside)
            self.postAccessoryView.attachmentsView.dataSource = self
            self.postAccessoryView.attachmentsView.delegate = self
            self.postAccessoryView.attachmentsView.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: kCellID)
            tf.inputAccessoryView = self.postAccessoryView
        }
        sendButton.tap { (b: UIButton) in
            b.addTarget(self, action: "post:", forControlEvents: .TouchUpInside)
            b.setContentHuggingPriorityHigh(.Horizontal)
        }
        
        let autolayout = autolayoutFormat(["p": 8, "onepx": Appearance.onepx], [
            "text": textField,
            "send": sendButton,
            "border": Appearance.separatorView(),
            ])
        autolayout("H:|-p-[text]-p-[send]-p-|")
        autolayout("H:|[border]|")
        autolayout("V:|-p-[text]-p-|")
        autolayout("V:|-p-[send]-p-|")
        autolayout("V:[border(==onepx)]|")
        
        updateViews()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateViews() {
        textField.enabled = true
        sendButton.enabled = !textField.text.isEmpty
    }
    
    func textChanged(sender: AnyObject?) {
        updateViews()
    }
    
    func post(sender: AnyObject?) {
        endEditing(true)
        textField.enabled = false
        sendButton.enabled = false
        
        onPost?(text: textField.text, attachments: attachments) { (clearField: Bool) -> Void in
            if clearField {
                self.textField.text = ""
                self.attachments.removeAll(keepCapacity: false)
            }
            self.updateViews()
        }
    }
    
    func addPhoto(sender: AnyObject?) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        containigViewController?.presentViewController(picker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true) {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage ?? info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.attachments += [(data: image.jpegData(1 * 1024 * 1024), ext: "jpg")]
                self.postAccessoryView.attachmentsView.reloadData()
                self.textField.becomeFirstResponder()
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true){}
        self.textField.becomeFirstResponder()
    }
    
    // MARK: - Collection View
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellID, forIndexPath: indexPath) as ImageCollectionViewCell
        cell.imageView.image = UIImage(data: attachments[indexPath.item].data, scale: UIScreen.mainScreen().scale)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: .Destructive) { _ -> Void in
            self.attachments.removeAtIndex(indexPath.item)
            self.postAccessoryView.attachmentsView.reloadData()
        })
        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        containigViewController?.presentViewController(ac, animated: true, completion: nil)
    }
    
    // MARK: - Input Accessory View
    
    private class PostAccessoryView: UIView {
        let photoButton = UIButton.buttonWithType(.System) as UIButton
        let attachmentsView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout().tap { (l: UICollectionViewFlowLayout) in
            l.scrollDirection = .Horizontal
            l.itemSize = CGSizeMake(256, 44 - 8)
            l.sectionInset = UIEdgeInsetsMake(0, 0, 0, 8)
        })
        
        override init(frame: CGRect) {
            super.init(frame: CGRectMake(frame.origin.x, frame.origin.y, frame.width, 44))
            autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
            
            backgroundColor = Appearance.lightBackgroundColor
            photoButton.setTitle(NSLocalizedString("Photo", comment: ""), forState: .Normal)
            attachmentsView.backgroundColor = backgroundColor
            attachmentsView.showsHorizontalScrollIndicator = false
            attachmentsView.showsVerticalScrollIndicator = false
            
            let autolayout = autolayoutFormat(["p": 8], ["photo": photoButton, "attachments": attachmentsView])
            autolayout("H:|-p-[photo]-p-[attachments]|")
            autolayout("V:|-p-[photo]-p-|")
            autolayout("V:|[attachments]|")
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
