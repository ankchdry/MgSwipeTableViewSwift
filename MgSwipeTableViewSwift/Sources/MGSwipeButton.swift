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
    typealias MGSwipeButtonCallback = (MGSwipeTableCell) -> Bool

    var callback: MGSwipeButtonCallback?
    /// A width for the expanded buttons. Defaults to 0, which means sizeToFit will be called.
    var buttonWidth: CGFloat = 0.0
    //  Converted to Swift 5.1 by Swiftify v5.1.31847 - https://swiftify.com/
    class func button(withTitle title: String?, backgroundColor color: UIColor?) -> Self {
        return self.button(withTitle: title, icon: nil, backgroundColor: color)
    }

    class func button(withTitle title: String?, backgroundColor color: UIColor?, padding: Int) -> Self {
        return self.button(withTitle: title, icon: nil, backgroundColor: color, insets: UIEdgeInsets(top: 0, left: CGFloat(padding), bottom: 0, right: CGFloat(padding)))
    }

    class func button(withTitle title: String?, backgroundColor color: UIColor?, insets: UIEdgeInsets) -> Self {
        return self.button(withTitle: title, icon: nil, backgroundColor: color, insets: insets)
    }

    class func button(withTitle title: String?, backgroundColor color: UIColor?, callback: @escaping MGSwipeButtonCallback) -> Self {
        return self.button(withTitle: title, icon: nil, backgroundColor: color, callback: callback)
    }

    class func button(withTitle title: String?, backgroundColor color: UIColor?, padding: Int, callback: @escaping MGSwipeButtonCallback) -> Self {
        return self.button(withTitle: title, icon: nil, backgroundColor: color, insets: UIEdgeInsets(top: 0, left: CGFloat(padding), bottom: 0, right: CGFloat(padding)), callback: callback)
    }

    class func button(withTitle title: String?, backgroundColor color: UIColor?, insets: UIEdgeInsets, callback: @escaping MGSwipeButtonCallback) -> Self {
        return self.button(withTitle: title, icon: nil, backgroundColor: color, insets: insets, callback: callback)
    }

    class func button(withTitle title: String?, icon: UIImage?, backgroundColor color: UIColor?) -> Self {
        return self.button(withTitle: title, icon: icon, backgroundColor: color, callback: nil)
    }

    class func button(withTitle title: String?, icon: UIImage?, backgroundColor color: UIColor?, padding: Int) -> Self {
        return self.button(withTitle: title, icon: icon, backgroundColor: color, insets: UIEdgeInsets(top: 0, left: CGFloat(padding), bottom: 0, right: CGFloat(padding)), callback: nil)
    }
    class func button(withTitle title: String?, icon: UIImage?, backgroundColor color: UIColor?, insets: UIEdgeInsets) -> Self {
        return self.button(withTitle: title, icon: icon, backgroundColor: color, insets: insets, callback: nil)
    }

    class func button(withTitle title: String?, icon: UIImage?, backgroundColor color: UIColor?, callback: MGSwipeButtonCallback?) -> Self {
        return self.button(withTitle: title, icon: icon, backgroundColor: color, padding: 10, callback: callback)
    }

    class func button(withTitle title: String?, icon: UIImage?, backgroundColor color: UIColor?, padding: Int, callback: MGSwipeButtonCallback?) -> Self {
        return self.button(withTitle: title, icon: icon, backgroundColor: color, insets: UIEdgeInsets(top: 0, left: CGFloat(padding), bottom: 0, right: CGFloat(padding)), callback: callback)
    }

    class func button(withTitle title: String?, icon: UIImage?, backgroundColor color: UIColor?, insets: UIEdgeInsets, callback: MGSwipeButtonCallback?) -> Self {
        let button = self.init(type: .custom)
        button.backgroundColor = color
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setImage(icon, for: .normal)
        button.callback = callback
        //button.edgeInsets = insets
        return button
    }

}

