//
//  MGSwipeButtonsView.swift
//  MgSwipeTableViewSwift
//
//  Created by Ankit Chaudhary on 31/07/20.
//  Copyright © 2020 Ankit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
class MGSwipeButtonsView: UIView {
    weak var cell: MGSwipeTableCell?
    var backgroundColorCopy: UIColor?
    
    var buttons: [MGSwipeButton]? = nil
    var container: UIView? = nil
    var fromLeft: Bool = false
    var expandedButton: UIView? = nil
    var expandedButtonAnimated: UIView? = nil
    var expansionBackground: UIView? = nil
    var expansionBackgroundAnimated: UIView? = nil
    var expandedButtonBoundsCopy: CGRect = CGRect.init()
    var direction: MGSwipeDirection?
    var expansionLayout: MGSwipeExpansionLayout?
    var expansionOffset: CGFloat = 0.0
    var buttonsDistance: CGFloat = 0.0
    var safeInset: CGFloat = 0.0
    var autoHideExpansion: Bool = false
    
    init(buttons buttonsArray: [MGSwipeButton], direction: MGSwipeDirection, swipeSettings settings: MGSwipeSettings?, safeInset: CGFloat) {
        var containerWidth: CGFloat = 0
        var maxSize = CGSize.zero
        let lastButton = buttonsArray.last
        for button in buttonsArray {
            containerWidth += button.bounds.size.width + ((lastButton == button ? 0 : settings?.buttonsDistance) ?? 0.0)
            maxSize.width = max(maxSize.width, button.bounds.size.width)
            maxSize.height = max(maxSize.height, button.bounds.size.height)
        }
        if settings?.allowsButtonsWithDifferentWidth == nil {
            let width1 = maxSize.width * CGFloat(buttonsArray.count)
            let width2 = (settings?.buttonsDistance ?? 0.0) * CGFloat(buttonsArray.count-1)
            containerWidth = width1 + width2
        }
        super.init(frame: CGRect(x: 0, y: 0, width: containerWidth + safeInset, height: maxSize.height))
        fromLeft = direction == MGSwipeDirection.leftToRight
        buttonsDistance = settings?.buttonsDistance ?? 0.0
        container = UIView(frame: bounds)
        container?.clipsToBounds = true
        container?.backgroundColor = UIColor.clear
        //direction = direction    // Skipping redundant initializing to itself
        //safeInset = safeInset    // Skipping redundant initializing to itself
        if container != nil {
            addSubview(container!)
        }
        buttons = fromLeft ? buttonsArray : buttonsArray.reversed()
        for button in buttons ?? [] {
            if (button is UIButton) {
                let btn = button as? UIButton
                btn?.removeTarget(nil, action: #selector(mgButtonClicked(_:)), for: .touchUpInside) //Remove all targets to avoid problems with reused buttons among many cells
                btn?.addTarget(self, action: #selector(mgButtonClicked(_:)), for: .touchUpInside)
            }
            if !(settings?.allowsButtonsWithDifferentWidth ?? false) {
                button.frame = CGRect(x: 0, y: 0, width: maxSize.width, height: maxSize.height)
            }
            button.autoresizingMask = .flexibleHeight
            let rightCount = container?.subviews.count ?? 0
            container?.insertSubview(button, at: (fromLeft ? 0 : rightCount))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func mgButtonClicked(_ sender: Any?) {
        //handleClick(sender, fromExpansion: false)
    }
}

