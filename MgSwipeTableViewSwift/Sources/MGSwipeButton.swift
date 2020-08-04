//
//  MGSwipeButton.swift
//  Conversion
//
//  Created by Lokesh Kumar on 31/07/20.
//  Copyright © 2020 Lokesh Kumar. All rights reserved.
//

import Foundation
import UIKit

class MGSwipeButton: UIButton {
    
    private let defaultPadding : CGFloat = 10.0
    typealias MGSwipeButtonCallback = (MGSwipeTableCell) -> Bool
    var callback: MGSwipeButtonCallback?
    
    /// A width for the expanded buttons. Defaults to 0, which means sizeToFit will be called.
    var buttonWidth: CGFloat = 0.0
    convenience init(title: String?, backgroundColor color: UIColor?){
        self.init(type: .custom)
        setupButton(withTitle: title, icon: nil, backgroundColor: color, insets: UIEdgeInsets.init(top: 0, left: defaultPadding, bottom: 0, right: defaultPadding), callback: nil)
    }

    convenience init(title: String?, backgroundColor color: UIColor?, padding: Int) {
        self.init(type: .custom)
        setupButton(withTitle: title, icon: nil, backgroundColor: color, insets: UIEdgeInsets.init(top: 0, left: CGFloat(padding), bottom: 0, right: CGFloat(padding)), callback: nil)
    }

    convenience init(title: String?, backgroundColor color: UIColor?, insets: UIEdgeInsets) {
        self.init(type: .custom)
        setupButton(withTitle: title, icon: nil, backgroundColor: color, insets: insets, callback: nil)
    }

    convenience init(title: String?, backgroundColor color: UIColor?, callback: @escaping MGSwipeButtonCallback) {
        self.init(type: .custom)
        setupButton(withTitle: title, icon: nil, backgroundColor: color, insets: UIEdgeInsets.init(top: 0, left: defaultPadding, bottom: 0, right: defaultPadding), callback: callback)
    }
    
    convenience init(title: String?, backgroundColor color: UIColor?, padding: Int, callback: @escaping MGSwipeButtonCallback) {
        self.init(type: .custom)
        setupButton(withTitle: title, icon: nil, backgroundColor: color, insets: UIEdgeInsets.init(top: 0, left: CGFloat(padding), bottom: 0, right: CGFloat(padding)), callback: callback)
    }

    convenience init(title: String?, backgroundColor color: UIColor?, insets: UIEdgeInsets, callback: @escaping MGSwipeButtonCallback) {
        self.init(type: .custom)
        setupButton(withTitle: title, icon: nil, backgroundColor: color, insets: insets, callback: callback)
    }

    convenience init(title: String?, icon: UIImage?, backgroundColor color: UIColor?) {
        self.init(type: .custom)
        setupButton(withTitle: title, icon: icon, backgroundColor: color, insets: UIEdgeInsets.init(top: 0, left: defaultPadding, bottom: 0, right: defaultPadding), callback: nil)
    }

    convenience init(title: String?, icon: UIImage?, backgroundColor color: UIColor?, padding: Int) {
        self.init(type: .custom)
        setupButton(withTitle: title, icon: icon, backgroundColor: color, insets: UIEdgeInsets.init(top: 0, left: CGFloat(padding), bottom: 0, right: CGFloat(padding)), callback: nil)
    }
    convenience init(title: String?, icon: UIImage?, backgroundColor color: UIColor?, insets: UIEdgeInsets) {
        self.init(type: .custom)
        setupButton(withTitle: title, icon: icon, backgroundColor: color, insets: UIEdgeInsets.init(top: 0, left: defaultPadding, bottom: 0, right: defaultPadding), callback: nil)
    }

    convenience init(title: String?, icon: UIImage?, backgroundColor color: UIColor?, callback: MGSwipeButtonCallback?) {
        self.init(type: .custom)
        setupButton(withTitle: title, icon: icon, backgroundColor: color, insets: UIEdgeInsets.init(top: 0, left: defaultPadding, bottom: 0, right: defaultPadding), callback: callback)
    }

    convenience init(title: String?, icon: UIImage?, backgroundColor color: UIColor?, padding: Int, callback: MGSwipeButtonCallback?) {
        self.init(type: .custom)
        setupButton(withTitle: title, icon: icon, backgroundColor: color, insets: UIEdgeInsets.init(top: 0, left: CGFloat(padding), bottom: 0, right: CGFloat(padding)), callback: nil)
    }

    convenience init(withTitle title: String?, icon: UIImage?, backgroundColor color: UIColor?, insets: UIEdgeInsets, callback: MGSwipeButtonCallback?){
        self.init(type: .custom)
        setupButton(withTitle: title, icon: icon, backgroundColor: color, insets: insets, callback: callback)
    }
    private func setupButton(withTitle title: String?, icon: UIImage?, backgroundColor color: UIColor?, insets: UIEdgeInsets, callback: MGSwipeButtonCallback?){
        self.backgroundColor = color
        self.titleLabel?.lineBreakMode = .byWordWrapping
        self.titleLabel?.textAlignment = .center
        self.setTitle(title, for: .normal)
        self.setTitleColor(UIColor.white, for: .normal)
        self.setImage(icon, for: .normal)
        self.callback = callback
        self.setEdgeInsets(insets)
    }
    @objc func callMGSwipeConvenienceCallback(_ sender: MGSwipeTableCell?) -> Bool {
        if (callback != nil && sender != nil) {
            return (callback!)(sender!)
        }
        return false
    }

    func centerIconOverText() {
        centerIconOverText(withSpacing: 3.0)
    }
    func centerIconOverText(withSpacing spacing: CGFloat) {
        var size = imageView?.image?.size

        if Float(UIDevice.current.systemVersion) ?? 0.0 >= 9.0 && isRTLLocale() {
            titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -((size?.height ?? 0.0) + spacing), right: -(size?.width ?? 0.0))
            if let font = titleLabel?.font {
                size = titleLabel?.text?.size(withAttributes: [
                NSAttributedString.Key.font: font
                ])
            }
            imageEdgeInsets = UIEdgeInsets(top: -((size?.height ?? 0.0) + spacing), left: -(size?.width ?? 0.0), bottom: 0.0, right: 0.0)
        }
        else {
            titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -(size?.width ?? 0.0), bottom: -((size?.height ?? 0.0) + spacing), right: 0.0)
            if let font = titleLabel?.font {
                size = titleLabel?.text?.size(withAttributes: [
                NSAttributedString.Key.font: font
                ])
            }
            imageEdgeInsets = UIEdgeInsets(top: -((size?.height ?? 0.0) + spacing), left: 0.0, bottom: 0.0, right: -(size?.width ?? 0.0))
        }
    }
    
    func setPadding(_ padding: CGFloat) {
        contentEdgeInsets = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        sizeToFit()
    }

    func setButtonWidth(_ buttonWidth: CGFloat) {
        self.buttonWidth = buttonWidth
        if self.buttonWidth > 0 {
            var frame = self.frame
            frame.size.width = self.buttonWidth
            self.frame = frame
        } else {
            sizeToFit()
        }
    }
    func setEdgeInsets(_ insets: UIEdgeInsets) {
        contentEdgeInsets = insets
        sizeToFit()
    }

    func iconTintColor(_ tintColor: UIColor?) {
        var currentIcon = imageView?.image
        if currentIcon?.renderingMode != .alwaysTemplate {
            currentIcon = currentIcon?.withRenderingMode(.alwaysTemplate)
            setImage(currentIcon, for: .normal)
        }
        self.tintColor = tintColor
    }

    func isAppExtension() -> Bool {
        return (Bundle.main.executablePath as NSString?)?.range(of: ".appex/").location != NSNotFound
    }
    func isRTLLocale() -> Bool {
        if #available(iOS 9.0, *) {
          if UIView.userInterfaceLayoutDirection(
            for: self.semanticContentAttribute) == .rightToLeft {
               return true
          }
        } else {
            if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
                return true
            }
        }
        return false
    }
}

