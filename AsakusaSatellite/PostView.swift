//
//  PostView.swift
//  AsakusaSatellite
//
//  Created by BAN Jun on 2015/03/22.
//  Copyright (c) 2015年 codefirst. All rights reserved.
//

import UIKit

class PostView: UIView, UITextFieldDelegate {
    let textField = UITextField()
    let sendButton = Appearance.roundRectButtonOnBackgroundColor(NSLocalizedString("Send", comment: ""))
    
    var onPost: ((text: String, completion: (clearField: Bool) -> Void) -> Void)?
    
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
        
        onPost?(text: textField.text) { (clearField: Bool) -> Void in
            if clearField {
                self.textField.text = ""
            }
            self.updateViews()
        }
    }
}
