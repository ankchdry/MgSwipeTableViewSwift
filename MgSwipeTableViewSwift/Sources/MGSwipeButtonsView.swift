//
//  MGSwipeButtonsView.swift
//  MgSwipeTableViewSwift
//
//  Created by Lokesh Kumar on 31/07/20.
//  Copyright © 2020 Lokesh Kumar. All rights reserved.
//

import Foundation
import UIKit
class MGSwipeButtonsView: UIView {
    weak var cell: MGSwipeTableCell?
    var backgroundColorCopy: UIColor?
    
    var buttons: [UIView]? = nil
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
    
    init(buttons buttonsArray: [UIView], direction: MGSwipeDirection, swipeSettings settings: MGSwipeSettings?, safeInset: CGFloat) {
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
            container?.insertSubview(button, at: rightCount)
        }
        if safeInset > 0 && settings?.expandLastButtonBySafeAreaInsets ?? true && buttons?.count ?? 0 > 0 {
            let notchButton = direction == MGSwipeDirection.rightToLeft ? buttons?.last : buttons?.first
            notchButton?.frame = CGRect(x: 0, y: 0, width: (notchButton?.frame.size.width ?? 0.0) + safeInset, height: notchButton?.frame.size.height ?? 0.0)
            adjustContentEdge(notchButton, edgeDelta: safeInset)
        }
        self.resetButtons()
    }
    func resetButtons() {
        var offsetX: CGFloat = 0
        let lastButton = buttons?.last
        for button in buttons ?? [] {
            button.frame = CGRect(x: offsetX, y: 0, width: button.bounds.size.width, height: bounds.size.height)
            button.autoresizingMask = .flexibleHeight
            offsetX += button.bounds.size.width + (lastButton == button ? 0 : buttonsDistance)
        }
    }
    func setSafeInset(_ safeInset: CGFloat, extendEdgeButton: Bool, isRTL: Bool) {
         let diff = safeInset - self.safeInset
        if diff != 0 {
            //safeInset = safeInset    // Skipping redundant initializing to itself
            // Adjust last button length (fit the safeInset to make it look good with a notch)
            if extendEdgeButton {
                let edgeButton = direction == MGSwipeDirection.rightToLeft ? buttons?.last : buttons?.first
                edgeButton?.frame = CGRect(x: 0, y: 0, width: (edgeButton?.bounds.size.width ?? 0.0) + diff, height: edgeButton?.frame.size.height ?? 0.0)
                // Adjust last button content edge (to correctly align the text/icon)
                adjustContentEdge(edgeButton, edgeDelta: diff)
            }
            var frame = self.frame
            let transform = self.transform
            self.transform = CGAffineTransform.identity
            // Adjust container width
            frame.size.width += diff
            // Adjust position to match width and safeInsets chages
            if direction == MGSwipeDirection.leftToRight {
                frame.origin.x = -frame.size.width + safeInset * (isRTL ? 1 : -1)
            } else {
                frame.origin.x = superview!.bounds.size.width + safeInset * (isRTL ? 1 : -1)
            }
            self.frame = frame
            self.transform = transform
            self.resetButtons()
        }
    }
    
    func adjustContentEdge(_ view: UIView?, edgeDelta delta: CGFloat) {
        if (view is UIButton) {
            let btn = view as? UIButton
            var contentInsets = btn?.contentEdgeInsets
            if direction == MGSwipeDirection.leftToRight {
                contentInsets?.right += delta
            } else {
                contentInsets?.left += delta
            }
            if let contentInsets = contentInsets {
                btn?.contentEdgeInsets = contentInsets
            }
        }
    }
    func layoutExpansion(_ offset: CGFloat) {
        expansionOffset = offset
        container?.frame = CGRect(x: fromLeft ? 0 : bounds.size.width - offset, y: 0, width: offset, height: bounds.size.height)
        if (expansionBackgroundAnimated != nil) && (expandedButtonAnimated != nil) {
            expansionBackgroundAnimated!.frame = expansionBackgroundRect(expandedButtonAnimated!)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if (expandedButton != nil) {
            layoutExpansion(expansionOffset)
        } else {
            container?.frame = bounds
        }
    }
    func expansionBackgroundRect(_ button: UIView) -> CGRect {
        let extra: CGFloat = 100.0 //extra size to avoid expansion background size issue on iOS 7.0
        if fromLeft {
            return CGRect(x: -extra, y: 0, width: button.frame.origin.x + extra, height: container?.bounds.size.height ?? 0.0)
        } else {
            let xVal = button.frame.origin.x + button.bounds.size.width
            let widthVal = (container?.bounds.size.width ?? 0.0) - (button.frame.origin.x + button.bounds.size.width) + extra
            let heightVal = container?.bounds.size.height ?? 0.0
            return CGRect(x: xVal, y: 0, width: widthVal, height: heightVal)
        }

    }
    func expand(toOffset offset: CGFloat, settings: MGSwipeExpansionSettings) {
        if settings.buttonIndex ?? 0 < 0 || settings.buttonIndex >= buttons?.count ?? 0 {
            return
        }
        if expandedButton == nil {
            expandedButton = buttons?[fromLeft ? settings.buttonIndex : (buttons?.count ?? 0) - settings.buttonIndex - 1]
            let previusRect = container?.frame
            layoutExpansion(offset)
            resetButtons()
            if !fromLeft {
                //Fix expansion animation for right buttons
                for button in buttons ?? [] {
                    var frame = button.frame
                    frame.origin.x += (container?.bounds.size.width ?? 0.0) - (previusRect?.size.width ?? 0.0)
                    button.frame = frame
                }
            }
            expansionBackground = UIView(frame: expansionBackgroundRect(expandedButton!))
            expansionBackground?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            if (settings.expansionColor != nil) {
                backgroundColorCopy = expandedButton!.backgroundColor
                expandedButton!.backgroundColor = settings.expansionColor
            }
            expansionBackground?.backgroundColor = expandedButton!.backgroundColor
            if UIColor.clear == expandedButton?.backgroundColor {
                // Provides access to more complex content for display on the background
                expansionBackground?.layer.contents = expandedButton!.layer.contents
            }
            container?.addSubview(expansionBackground!)
            expansionLayout = settings.expansionLayout

            let duration = CGFloat((fromLeft ? cell?.leftExpansion.animationDuration : cell?.rightExpansion.animationDuration) ?? 0)
            UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: .beginFromCurrentState, animations: {
                self.expandedButton?.isHidden = false
                if self.expansionLayout == MGSwipeExpansionLayout.center {
                    self.expandedButtonBoundsCopy = self.expandedButton!.bounds
                    self.expandedButton!.layer.mask = nil
                    self.expandedButton!.layer.transform = CATransform3DIdentity
                    self.expandedButton!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
                    self.expandedButton!.superview!.bringSubviewToFront(self.expandedButton!)
                    self.expandedButton!.frame = self.container?.bounds ?? CGRect.zero
                    self.expansionBackground?.frame = self.expansionBackgroundRect(self.expandedButton!)
                } else if self.expansionLayout == MGSwipeExpansionLayout.none {
                    self.expandedButton?.superview!.bringSubviewToFront(self.expandedButton!)
                    self.expansionBackground?.frame = self.container?.bounds ?? CGRect.zero
                }
                else if self.fromLeft {
                    self.expandedButton!.frame = CGRect(x: (self.container?.bounds.size.width ?? 0.0) - self.expandedButton!.bounds.size.width, y: 0, width: self.expandedButton!.bounds.size.width, height: self.expandedButton!.bounds.size.height)
                    self.expandedButton!.autoresizingMask.insert(.flexibleLeftMargin)
                    self.expansionBackground?.frame = self.expansionBackgroundRect(self.expandedButton!)
                } else {
                    self.expandedButton!.frame = CGRect(x: 0, y: 0, width: self.expandedButton!.bounds.size.width, height: self.expandedButton!.bounds.size.height)
                    self.expandedButton!.autoresizingMask.insert(.flexibleRightMargin)
                    self.expansionBackground?.frame = self.expansionBackgroundRect(self.expandedButton!)
                }
            }) { finished in
            }
            return;
        }
        self.layoutExpansion(offset)
    }
    func endExpansion(animated: Bool) {
        if (expandedButton != nil) {
            expandedButtonAnimated = expandedButton
            if (expansionBackgroundAnimated != nil) && expansionBackgroundAnimated != expansionBackground {
                expansionBackgroundAnimated!.removeFromSuperview()
            }
            expansionBackgroundAnimated = expansionBackground
            expansionBackground = nil
            expandedButton = nil
            if (backgroundColorCopy != nil) {
                expansionBackgroundAnimated?.backgroundColor = backgroundColorCopy
                expandedButtonAnimated?.backgroundColor = backgroundColorCopy
                backgroundColorCopy = nil
            }
            let duration = CGFloat((fromLeft ? cell?.leftExpansion.animationDuration : cell?.rightExpansion.animationDuration) ?? 0.0)
            UIView.animate(withDuration: TimeInterval(animated ? duration : 0.0), delay: 0, options: .beginFromCurrentState, animations: {
                self.container?.frame = self.bounds
                if self.expansionLayout == MGSwipeExpansionLayout.center {
                    self.expandedButtonAnimated?.frame = self.expandedButtonBoundsCopy
                }
                self.resetButtons()
                self.expansionBackgroundAnimated?.frame = self.expansionBackgroundRect(self.expandedButtonAnimated ?? UIButton())
            }) { finished in
                self.expansionBackgroundAnimated?.removeFromSuperview()
            }
        }
        else if (expansionBackground != nil) {
            expansionBackground!.removeFromSuperview()
            expansionBackground = nil
        }

    }
    // MARK: Trigger Actions
    func handleClick(_ sender: Any?, fromExpansion: Bool) -> Bool {
        var autoHide = false
        guard let senderUnwrapped = sender as? MGSwipeButton else {
            return autoHide
        }
        if (senderUnwrapped.responds(to: #selector(senderUnwrapped.callMGSwipeConvenienceCallback(_:)))) {
            autoHide = (senderUnwrapped.perform(#selector(senderUnwrapped.callMGSwipeConvenienceCallback(_:)), with: cell!) != nil)
        }
        if fromExpansion && autoHide {
            expandedButton = nil
            cell?.setSwipeOffset(0)
        } else if autoHide {
            cell?.hideSwipe(animated: true)
        }
        return autoHide
    }
//    func handleMgButtonClick(_ sender: MGSwipeButton?, fromExpansion: Bool) -> Bool {
//        var autoHide = false
//        guard let senderUnwrapped = sender else {
//            return autoHide
//        }
//        if (senderUnwrapped.responds(to: #selector(senderUnwrapped.callMGSwipeConvenienceCallback(_:)))) {
//            autoHide = (senderUnwrapped.perform(#selector(senderUnwrapped.callMGSwipeConvenienceCallback(_:)), with: cell!) != nil)
//        }
//        if fromExpansion && autoHide {
//            expandedButton = nil
//            cell?.setSwipeOffset(0)
//        } else if autoHide {
//            cell?.hideSwipe(animated: true)
//        }
//        return autoHide
//    }
    @objc func mgButtonClicked(_ sender: Any?) {
       _ = handleClick(sender as? MGSwipeButton, fromExpansion: false)
    }
    func getExpandedButton() -> UIView? {
        return expandedButton
    }
    
    // MARK: Transitions
    func transitionStatic(_ t: CGFloat) {
        let dx = bounds.size.width * (1.0 - t)
        var offsetX: CGFloat = 0

        let lastButton = buttons?.last
        for button in buttons ?? [] {
            var frame = button.frame
            frame.origin.x = offsetX + (fromLeft ? dx : -dx)
            button.frame = frame
            offsetX += frame.size.width + (button == lastButton ? 0 : buttonsDistance)
        }
    }
    func transitionDrag(_ t: CGFloat) {
        //No Op, nothing to do ;)
    }
    func transitionClip(_ t: CGFloat) {
        let selfWidth = bounds.size.width
        var offsetX: CGFloat = 0

        let lastButton = buttons?.last
        for button in buttons ?? [] {
            var frame = button.frame
            let dx = CGFloat(roundf(Float(frame.size.width * 0.5 * (1.0 - t))))
            let lhs = (selfWidth - frame.size.width - offsetX) * (1.0 - t) + offsetX + dx
            let rhs = offsetX * t - dx
            frame.origin.x = fromLeft ? lhs : rhs
            button.frame = frame

            if (buttons?.count ?? 0) > 1 {
                let maskLayer = CAShapeLayer()
                let maskRect = CGRect(x: dx - 0.5, y: 0, width: frame.size.width - 2 * dx + 1.5, height: frame.size.height)
                let path = CGPath(rect: maskRect, transform: nil)
                maskLayer.path = path
                button.layer.mask = maskLayer
            }

            offsetX += frame.size.width + (button == lastButton ? 0 : buttonsDistance)
        }
    }
    func transtitionFloatBorder(_ t: CGFloat) {
        let selfWidth = bounds.size.width
        var offsetX: CGFloat = 0

        let lastButton = buttons?.last
        for button in buttons ?? [] {
            var frame = button.frame
            frame.origin.x = fromLeft ? (selfWidth - frame.size.width - offsetX) * (1.0 - t) + offsetX : offsetX * t
            button.frame = frame
            offsetX += frame.size.width + (button == lastButton ? 0 : buttonsDistance)
        }
    }
    func transition3D(_ t: CGFloat) {
        let invert: CGFloat = fromLeft ? 1.0 : -1.0
        let angle = CGFloat.pi/2 * (1.0 - t) * invert
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 400.0 //perspective 1/z
        let dx = -(container?.bounds.size.width ?? 0.0) * 0.5 * invert
        let offset = dx * 2 * (1.0 - t)
        transform = CATransform3DTranslate(transform, dx - offset, 0, 0)
        transform = CATransform3DRotate(transform, angle, 0.0, 1.0, 0.0)
        transform = CATransform3DTranslate(transform, -dx, 0, 0)
        container?.layer.transform = transform
    }
    func transition(_ mode: MGSwipeTransition, percent t: CGFloat) {
        switch mode {
        case MGSwipeTransition.static:
                transitionStatic(t)
            case MGSwipeTransition.drag:
                transitionDrag(t)
            case MGSwipeTransition.clipCenter:
                transitionClip(t)
            case MGSwipeTransition.border:
                transtitionFloatBorder(t)
            case MGSwipeTransition.rotate3D:
                transition3D(t)
            default:
                break
        }
        if (expandedButtonAnimated != nil) && (expansionBackgroundAnimated != nil) {
            expansionBackgroundAnimated!.frame = expansionBackgroundRect(expandedButtonAnimated!)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

