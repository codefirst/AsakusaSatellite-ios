//
//  PostView.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/22.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit
import Ikemen

private let kCellID = "Cell"


class PostView: UIView, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    let textField = UITextField()
    private let postAccessoryView = PostAccessoryView(frame: .zero)
    let sendButton = Appearance.roundRectButtonOnBackgroundColor(NSLocalizedString("Send", comment: ""))
    
    typealias Attachment = (data: Data, ext: String)
    var attachments: [Attachment] = [] {
        didSet {
            postAccessoryView.attachmentsView.reloadData()
            updateViews()
        }
    }
    
    var onPost: ((_ text: String, _ attachments: [Attachment], _ completion: @escaping (_ clearField: Bool) -> Void) -> Void)?
    weak var containigViewController: UIViewController?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        autoresizingMask = [.flexibleWidth, .flexibleBottomMargin] // table footer does not support autolayout
        
        backgroundColor = Appearance.lightBackgroundColor
        
        _ = textField ※ { tf in
            tf.placeholder = NSLocalizedString("message", comment: "")
            tf.font = Appearance.hiraginoW3(14)
            tf.backgroundColor = Appearance.backgroundColor
            tf.borderStyle = .roundedRect
            tf.delegate = self
            tf.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
            tf.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)

            self.postAccessoryView.photoButton.addTarget(self, action: #selector(addPhoto(_:)), for: .touchUpInside)
            self.postAccessoryView.attachmentsView.dataSource = self
            self.postAccessoryView.attachmentsView.delegate = self
            self.postAccessoryView.attachmentsView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: kCellID)
//            tf.inputAccessoryView = self.postAccessoryView
        }
        _ = sendButton ※ { b in
            b.addTarget(self, action: #selector(post(_:)), for: .touchUpInside)
            b.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: .horizontal)
        }
        
        let autolayout = northLayoutFormat(["p": 8, "onepx": Appearance.onepx], [
            "text": textField,
            "send": sendButton,
            "border": Appearance.separatorView(),
            ])
        autolayout("H:|-p-[text]-p-[send]-p-|")
        autolayout("H:|[border]|")
        autolayout("V:|-p-[text]-p-|")
        autolayout("V:|-p-[send]-p-|")
        autolayout("V:[border(==onepx)]|")
        sendButton.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        
        updateViews()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateViews() {
        textField.isEnabled = true
        sendButton.isEnabled = !(textField.text?.isEmpty ?? true) || attachments.count > 0
    }
    
    @objc func textChanged(_ sender: AnyObject?) {
        updateViews()
    }
    
    @objc func post(_ sender: AnyObject?) {
        endEditing(true)
        textField.isEnabled = false
        sendButton.isEnabled = false
        
        onPost?(textField.text ?? "", attachments) { (clearField: Bool) -> Void in
            if clearField {
                self.textField.text = ""
                self.attachments.removeAll(keepingCapacity: false)
            }
            self.updateViews()
        }
    }
    
    @objc func addPhoto(_ sender: AnyObject?) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        containigViewController?.present(picker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate

    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if  let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage,
                let jpegData = image.jpegData(maxSize: 1 * 1024 * 1024) {
                self.attachments.append((data: jpegData, ext: "jpg"))
                self.textField.becomeFirstResponder()
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true){}
        self.textField.becomeFirstResponder()
    }
    
    // MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellID, for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = UIImage(data: attachments[indexPath.item].data, scale: UIScreen.main.scale)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: .destructive) { _ -> Void in
            self.attachments.remove(at: indexPath.item)
            ()
        })
        ac.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        containigViewController?.present(ac, animated: true, completion: nil)
    }
    
    // MARK: - Input Accessory View
    
    private class PostAccessoryView: UIView {
        let photoButton = UIButton(type: .system)
        let attachmentsView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout() ※ { l in
            l.scrollDirection = .horizontal
            l.itemSize = CGSize(width: 256, height: 44 - 8)
            l.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        })
        
        override init(frame: CGRect) {
            super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 44))
            autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            
            backgroundColor = Appearance.lightBackgroundColor
            photoButton.setTitle(NSLocalizedString("Photo", comment: ""), for: .normal)
            attachmentsView.backgroundColor = backgroundColor
            attachmentsView.showsHorizontalScrollIndicator = false
            attachmentsView.showsVerticalScrollIndicator = false
            
            let autolayout = northLayoutFormat(["p": 8], ["photo": photoButton, "attachments": attachmentsView])
            autolayout("H:|-p-[photo]-p-[attachments]|")
            autolayout("V:|-p-[photo]-p-|")
            autolayout("V:|[attachments]|")
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
