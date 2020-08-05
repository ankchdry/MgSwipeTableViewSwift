//
//  MGSwipeTableCell.swift
//  MgSwipeTableViewSwift
//
//  Created by Lokesh Kumar on 31/07/20.
//  Copyright © 2020 Lokesh Kumar. All rights reserved.
//

import Foundation
import UIKit
protocol MGSwipeTableCellDelegate: NSObject {
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool;

    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool;
    func swipeTableCell(_ cell: MGSwipeTableCell, didChange state: MGSwipeState, gestureIsActive: Bool);

    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool;

    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]?;

    func swipeTableCell(_ cell: MGSwipeTableCell, shouldHideSwipeOnTap point: CGPoint) -> Bool;

    func swipeTableCellWillBeginSwiping(_ cell: MGSwipeTableCell);

    func swipeTableCellWillEndSwiping(_ cell: MGSwipeTableCell);
}
extension MGSwipeTableCellDelegate {
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection, from point: CGPoint) -> Bool {
        print("Default canSwipe delegate called");
        return true;
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        print("Default canSwipe delegate called");
        return true;
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, didChange state: MGSwipeState, gestureIsActive: Bool) {
        print("Default didChange delegate called");
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        print("Default tappedButtonAt delegate called");
        return false;
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        print("Default swipeButtonsFor delegate called");
        return nil;
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, shouldHideSwipeOnTap point: CGPoint) -> Bool {
        print("Default shouldHideSwipeOnTap delegate called");
        return true;
    }

    func swipeTableCellWillBeginSwiping(_ cell: MGSwipeTableCell) {
        print("Default swipeTableCellWillBeginSwiping delegate called");
    }

    func swipeTableCellWillEndSwiping(_ cell: MGSwipeTableCell) {
        print("Default swipeTableCellWillEndSwiping delegate called");
    }
}
class MGSwipeTableCell: UITableViewCell {
    weak var delegate: MGSwipeTableCellDelegate?
    /// optional to use contentView alternative. Use this property instead of contentView to support animated views while swiping
    //private(set) var swipeContentView: UIView!
    /// Left and right swipe buttons and its settings.
    /// Buttons can be any kind of UIView but it's recommended to use the convenience MGSwipeButton class
    var leftButtons: [UIView] = []
    var rightButtons: [UIView] = []
    var leftSwipeSettings: MGSwipeSettings!
    var rightSwipeSettings: MGSwipeSettings!
    var leftExpansion: MGSwipeExpansionSettings!
    var rightExpansion: MGSwipeExpansionSettings!
    /// Readonly property to fetch the current swipe state
    private(set) var swipeState: MGSwipeState?
    /// Readonly property to check if the user swipe gesture is currently active
    //private(set) var isSwipeGestureActive = false
    // default is NO. Controls whether multiple cells can be swiped simultaneously
    var allowsMultipleSwipe = false
    // default is NO. Controls whether buttons with different width are allowed. Buttons are resized to have the same size by default.
    var allowsButtonsWithDifferentWidth = false
    var allowsSwipeWhenTappingButtons = false
    //default is YES. Controls whether swipe gesture is allowed in opposite directions. NO value disables swiping in opposite direction once started in one direction
    var allowsOppositeSwipe = false
    // default is NO.  Controls whether the cell selection/highlight status is preserved when expansion occurs
    var preservesSelectionStatus = false
    /* default is NO. Controls whether dismissing a swiped cell when tapping outside of the cell generates a real touch event on the other cell.
     Default behaviour is the same as the Mail app on iOS. Enable it if you want to allow to start a new swipe while a cell is already in swiped in a single step.  */
    var touchOnDismissSwipe = false
    var swipeBackgroundColor: UIColor?
    /// Property to read or change the current swipe offset programmatically
    var swipeOffset: CGFloat = 0.0
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    var panRecognizer : UIPanGestureRecognizer? = nil
    var panStartPoint: CGPoint = CGPoint.zero
    var panStartOffset: CGFloat = 0.0
    var targetOffset: CGFloat = 0.0

    var swipeOverlay: UIView? = nil
    var swipeView: UIImageView? = nil
    var swipeContentView: UIView? = nil
    var leftView: MGSwipeButtonsView? = nil
    var rightView: MGSwipeButtonsView? = nil
    var allowSwipeRightToLeft = false
    var allowSwipeLeftToRight = false
    weak var activeExpansion: MGSwipeButtonsView?
    
    var tableInputOverlay: MGSwipeTableInputOverlay? = nil
    var overlayEnabled: Bool = false
    var previusSelectionStyle: UITableViewCell.SelectionStyle = .none
    var previusHiddenViews: Set<UIView> = []
    var previusAccessoryType: UITableViewCell.AccessoryType = .none
    var triggerStateChanges: Bool = true

    var animationData: MGSwipeAnimationData? = nil
    var animationCompletion: ((_ finished: Bool) -> Void)? = nil
    var displayLink: CADisplayLink? = nil
    var firstSwipeState: MGSwipeState = .expandingLeftToRight
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews(true)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
            initViews(true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if (panRecognizer == nil) {
            initViews(true)
        }
    }
    func initViews(_ cleanButtons: Bool) {
        if cleanButtons {
            leftButtons = [UIView]()
            rightButtons = [UIView]()
            leftSwipeSettings = MGSwipeSettings()
            rightSwipeSettings = MGSwipeSettings()
            leftExpansion = MGSwipeExpansionSettings()
            rightExpansion = MGSwipeExpansionSettings()
        }
        animationData = MGSwipeAnimationData()
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panHandler(_:)))
        addGestureRecognizer(panRecognizer!)
        panRecognizer!.delegate = self
        activeExpansion = nil
        previusHiddenViews = []
        swipeState = MGSwipeState.none
        triggerStateChanges = true
        allowsSwipeWhenTappingButtons = true
        preservesSelectionStatus = false
        allowsOppositeSwipe = true
        firstSwipeState = MGSwipeState.none
    }
    func cleanViews() {
        hideSwipe(animated: false)
        if (displayLink != nil) {
            displayLink!.invalidate()
            displayLink = nil
        }
        if (swipeOverlay != nil) {
            swipeOverlay!.removeFromSuperview()
            swipeOverlay = nil
        }
        rightView = nil
        leftView = rightView
        if (panRecognizer != nil) {
            panRecognizer!.delegate = nil
            removeGestureRecognizer(panRecognizer!)
            panRecognizer = nil
        }
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
    func fixRegionAndAccesoryViews() {
        //Fix right to left layout direction for arabic and hebrew languagues
        if bounds.size.width != contentView.bounds.size.width && isRTLLocale() {
            swipeOverlay?.frame = CGRect(x: -bounds.size.width + contentView.bounds.size.width, y: 0, width: swipeOverlay?.bounds.size.width ?? 0.0, height: swipeOverlay?.bounds.size.height ?? 0.0)
        }
    }
    func getSafeInsets() -> UIEdgeInsets {
        if #available(iOS 11, *) {
            return safeAreaInsets
        } else {
            return .zero
        }
    }
    func getSwipeContentView() -> UIView {
        if swipeContentView == nil {
            swipeContentView = UIView(frame: contentView.bounds)
            swipeContentView?.backgroundColor = UIColor.clear
            swipeContentView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            swipeContentView?.layer.zPosition = 9
            contentView.addSubview(swipeContentView!)
        }
        return swipeContentView!
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if (swipeContentView != nil) {
            swipeContentView!.frame = contentView.bounds
        }
        if (swipeOverlay != nil) {
            let prevSize = swipeView?.bounds.size
            swipeOverlay!.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: contentView.bounds.size.height)
            fixRegionAndAccesoryViews()
            if ((swipeView?.image) != nil) && prevSize != nil && !(prevSize!.equalTo(swipeOverlay!.bounds.size)) {
                //refresh safeInsets in situations like layout change, orientation change, table resize, etc.
                let safeInsets = getSafeInsets()
                // Refresh safe insets
                if (leftView != nil) {
                    let width = leftView!.bounds.size.width
                    leftView!.setSafeInset(safeInsets.left, extendEdgeButton: leftSwipeSettings.expandLastButtonBySafeAreaInsets, isRTL: isRTLLocale())
                    if swipeOffset > 0 && leftView!.bounds.size.width != width {
                        // Adapt offset to the view change size due to safeInsets
                        swipeOffset += leftView!.bounds.size.width - width
                    }
                }
                if (rightView != nil) {
                    let width = rightView!.bounds.size.width
                    rightView!.setSafeInset(safeInsets.right, extendEdgeButton: rightSwipeSettings.expandLastButtonBySafeAreaInsets, isRTL: isRTLLocale())
                    if swipeOffset < 0 && rightView!.bounds.size.width != width {
                        // Adapt offset to the view change size due to safeInsets
                        swipeOffset -= rightView!.bounds.size.width - width
                    }
                }
                //refresh contentView in situations like layout change, orientation chage, table resize, etc.
                refreshContentView()
        }
    }
    }
    func fetchButtonsIfNeeded() {
        if leftButtons.count == 0 && delegate != nil {
            leftButtons = delegate!.swipeTableCell(self, swipeButtonsFor: MGSwipeDirection.leftToRight, swipeSettings: leftSwipeSettings, expansionSettings: leftExpansion) ?? []
        }
        if rightButtons.count == 0 && delegate != nil {
            rightButtons = delegate!.swipeTableCell(self, swipeButtonsFor: MGSwipeDirection.rightToLeft, swipeSettings: rightSwipeSettings, expansionSettings: rightExpansion) ?? []
        }
    }
    func createSwipeViewIfNeeded() {
        let safeInsets = getSafeInsets()
        if swipeOverlay == nil {
            swipeOverlay = UIView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: contentView.bounds.size.height))
            fixRegionAndAccesoryViews()
            swipeOverlay?.isHidden = true
            swipeOverlay?.backgroundColor = backgroundColorForSwipe()
            swipeOverlay?.layer.zPosition = 10 //force render on top of the contentView;
            swipeView = UIImageView(frame: swipeOverlay!.bounds)
            swipeView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            swipeView?.contentMode = .center
            swipeView?.clipsToBounds = true
            swipeOverlay?.addSubview(swipeView!)
            contentView.addSubview(swipeOverlay!)
        }
        
        fetchButtonsIfNeeded()
        
        if leftView == nil && leftButtons.count > 0 {
            leftSwipeSettings.allowsButtonsWithDifferentWidth = leftSwipeSettings.allowsButtonsWithDifferentWidth || allowsButtonsWithDifferentWidth
            leftView = MGSwipeButtonsView(buttons: leftButtons, direction: MGSwipeDirection.leftToRight, swipeSettings: leftSwipeSettings, safeInset: safeInsets.left)
            leftView?.cell = self
            leftView?.frame = CGRect(x: -(leftView?.bounds.size.width ?? 0.0) + safeInsets.left * (isRTLLocale() ? 1 : -1), y: leftSwipeSettings.topMargin, width: leftView?.bounds.size.width ?? 0.0, height: (swipeOverlay?.bounds.size.height ?? 0.0) - leftSwipeSettings.topMargin - leftSwipeSettings.bottomMargin)
            leftView?.autoresizingMask = [.flexibleRightMargin, .flexibleHeight]
            swipeOverlay?.addSubview(leftView!)
        }
        if rightView == nil && rightButtons.count > 0 {
            rightSwipeSettings.allowsButtonsWithDifferentWidth = rightSwipeSettings.allowsButtonsWithDifferentWidth || allowsButtonsWithDifferentWidth
            rightView = MGSwipeButtonsView(buttons: rightButtons, direction: MGSwipeDirection.rightToLeft, swipeSettings: rightSwipeSettings, safeInset: safeInsets.right)
            rightView?.cell = self
            rightView?.frame = CGRect(x: (swipeOverlay?.bounds.size.width ?? 0.0) + safeInsets.right * (isRTLLocale() ? 1 : -1), y: rightSwipeSettings.topMargin, width: rightView?.bounds.size.width ?? 0.0, height: (swipeOverlay?.bounds.size.height ?? 0.0) - rightSwipeSettings.topMargin - rightSwipeSettings.bottomMargin)
            rightView?.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
            swipeOverlay?.addSubview(rightView!)
        }
        
        if (leftView != nil) {
            leftView!.setSafeInset(safeInsets.left, extendEdgeButton: leftSwipeSettings.expandLastButtonBySafeAreaInsets, isRTL: isRTLLocale())
        }

        if (rightView != nil) {
            rightView!.setSafeInset(safeInsets.right, extendEdgeButton: rightSwipeSettings.expandLastButtonBySafeAreaInsets, isRTL: isRTLLocale())
        }
    }
    
    func showSwipeOverlayIfNeeded() {
        if overlayEnabled {
            return
        }
        overlayEnabled = true

        if !preservesSelectionStatus {
            isSelected = false
        }
        if (swipeContentView != nil) {
            swipeContentView!.removeFromSuperview()
        }
        delegate?.swipeTableCellWillBeginSwiping(self)
        // snapshot cell without separator
        let cropSize = CGSize(width: bounds.size.width, height: contentView.bounds.size.height)
        swipeView?.image = image(from: self, cropSize: cropSize)

        swipeOverlay?.isHidden = false
        
        if (swipeContentView != nil) {
            swipeView?.addSubview(swipeContentView!)
        }

        if !allowsMultipleSwipe {
            //input overlay on the whole table
            let table = parentTable()
            if (tableInputOverlay != nil) {
                tableInputOverlay!.removeFromSuperview()
            }
            tableInputOverlay = MGSwipeTableInputOverlay(frame: table?.bounds ?? CGRect.zero)
            tableInputOverlay?.currentCell = self
            table?.addSubview(tableInputOverlay!)
        }

        previusSelectionStyle = selectionStyle
        selectionStyle = .none
        self.setAccesoryViewsHidden(true)

        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        tapRecognizer?.cancelsTouchesInView = true
        tapRecognizer?.delegate = self
        addGestureRecognizer(tapRecognizer!)
    }
    func hideSwipeOverlayIfNeeded(includingReselect reselectCellIfNeeded: Bool) {
        if !overlayEnabled {
            return
        }
        overlayEnabled = false
        swipeOverlay?.isHidden = true
        swipeView?.image = nil
        if (swipeContentView != nil) {
            swipeContentView?.removeFromSuperview()
            contentView.addSubview(swipeContentView!)
        }

        if (tableInputOverlay != nil) {
            tableInputOverlay?.removeFromSuperview()
            tableInputOverlay = nil
        }
        if reselectCellIfNeeded {
            selectionStyle = previusSelectionStyle
            let selectedRows =  self.parentTable()?.indexPathsForSelectedRows
            if let index = self.parentTable()?.indexPath(for: self) {
                if selectedRows?.contains(index) ?? false {
                    isSelected = false //Hack: in some iOS versions setting the selected property to YES own isn't enough to force the cell to redraw the chosen selectionStyle
                    isSelected = true
                }
            }
        }
        self.setAccesoryViewsHidden(false)

        delegate?.swipeTableCellWillEndSwiping(self)

        if (tapRecognizer != nil) {
            removeGestureRecognizer(tapRecognizer!)
            tapRecognizer = nil
        }
    }
    func refreshContentView() {
        let currentOffset = swipeOffset
        let prevValue = triggerStateChanges
        triggerStateChanges = false
        self.setSwipeOffset(0)
        self.setSwipeOffset(currentOffset)
        triggerStateChanges = prevValue
    }
    func refreshButtons(_ usingDelegate: Bool) {
        if usingDelegate {
            leftButtons = []
            rightButtons = []
        }
        if (leftView != nil) {
            leftView!.removeFromSuperview()
            leftView = nil
        }
        if (rightView != nil) {
            rightView!.removeFromSuperview()
            rightView = nil
        }
        createSwipeViewIfNeeded()
        refreshContentView()
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            //remove the table overlay when a cell is removed from the table
            hideSwipeOverlayIfNeeded(includingReselect: false)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cleanViews()
        if swipeState != MGSwipeState.none {
            triggerStateChanges = true
            self.update(MGSwipeState.none)
        }
//        let cleanButtons = delegate && delegate.responds(to: #selector(swipeTableCell(_:swipeButtonsForDirection:swipeSettings:expansionSettings:)))
//        initViews(cleanButtons)
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            //disable swipe buttons when the user sets table editing mode
            self.setSwipeOffset(0)
        }
    }

    func setEditing(_ editing: Bool) {
        super.setEditing(editing, animated: true)
        if editing {
            //disable swipe buttons when the user sets table editing mode
            self.setSwipeOffset(0)
        }
    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isHidden && (swipeOverlay != nil) && !(swipeOverlay!.isHidden ) {
            //override hitTest to give swipe buttons a higher priority (diclosure buttons can steal input)
            let targets = [leftView, rightView]
            for i in 0..<2 {
                let target = targets[i]
                if target == nil {
                    continue
                }
                let p = convert(point, to: target)
                if target?.bounds.contains(p) ?? false {
                    return target?.hitTest(p, with: event)
                }
            }
        }
        return super.hitTest(point, with: event)
    }
    func image(from view: UIView?, cropSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(cropSize, _: false, _: 0)
        view?.drawHierarchy(in: view?.bounds ?? CGRect.zero, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    func setAccesoryViewsHidden(_ hidden: Bool) {
        if #available(iOS 12, *) {
            if hidden {
                previusAccessoryType = accessoryType
                accessoryType = .none
            } else if accessoryType == .none {
                accessoryType = previusAccessoryType
                previusAccessoryType = UITableViewCell.AccessoryType.none
            }
        }

        if accessoryView != nil {
            accessoryView?.isHidden = hidden
        }
        for view in contentView.superview?.subviews ?? [] {
            if view != contentView && ((view is UIButton) || (NSStringFromClass(type(of: view).self) as NSString).range(of: "Disclosure").location != NSNotFound) {
                view.isHidden = hidden
            }
        }
        for view in contentView.subviews {
            if view == swipeOverlay || view == swipeContentView {
                continue
            }
            if hidden && !view.isHidden {
                view.isHidden = true
                previusHiddenViews.insert(view)
            } else if !hidden && previusHiddenViews.contains(view) {
                view.isHidden = false
            }
        }

        if !hidden {
            previusHiddenViews.removeAll()
        }
    }
    func backgroundColorForSwipe() -> UIColor {
        if (swipeBackgroundColor != nil) {
            return swipeBackgroundColor! //user defined color
        } else if contentView.backgroundColor != nil && !(contentView.backgroundColor?.isEqual(UIColor.clear) ?? false) {
            return contentView.backgroundColor!
        } else if backgroundColor != nil {
            return backgroundColor!
        }
        return UIColor.clear
    }
    func parentTable() -> UITableView? {
        var view = superview
        while view != nil {
            if (view is UITableView) {
                return view as? UITableView
            }
            view = view?.superview
        }
        return nil
    }
    func update(_ newState: MGSwipeState) {
        if !triggerStateChanges || swipeState == newState {
            return
        }
        swipeState = newState
        delegate?.swipeTableCell(self, didChange: swipeState!, gestureIsActive: isSwipeGestureActive())
    }
    // MARK: Swipe Animation
    func setSwipeOffset(_ newOffset: CGFloat) {
        let sign: CGFloat = newOffset > 0 ? 1.0 : -1.0
        let activeButtons = sign < 0 ? rightView : leftView
        let activeSettings = sign < 0 ? rightSwipeSettings : leftSwipeSettings

        if activeSettings?.enableSwipeBounces != nil {
            swipeOffset = newOffset

            let maxUnbouncedOffset = sign * (activeButtons?.bounds.size.width ?? 0.0)

            if (sign > 0 && newOffset > maxUnbouncedOffset) || (sign < 0 && newOffset < maxUnbouncedOffset) {
                swipeOffset = maxUnbouncedOffset + (newOffset - maxUnbouncedOffset) * (activeSettings?.swipeBounceRate ?? 0.0)
            }
        } else {
            let maxOffset = sign * (activeButtons?.bounds.size.width ?? 0.0)
            swipeOffset = sign > 0 ? min(newOffset, maxOffset) : max(newOffset, maxOffset)
        }
        let offset = CGFloat(abs(swipeOffset))

        if !(activeButtons != nil) || offset == 0 {
            if (leftView != nil) {
                leftView!.endExpansion(animated: false)
            }
            if (rightView != nil) {
                rightView!.endExpansion(animated: false)
            }
            hideSwipeOverlayIfNeeded(includingReselect: true)
            targetOffset = 0
            self.update(MGSwipeState.none)
            return
        } else {
            showSwipeOverlayIfNeeded()
            let swipeThreshold = activeSettings?.threshold
            let keepButtons = activeSettings?.keepButtonsSwiped
            targetOffset = ((keepButtons ?? false)  && (offset > ((activeButtons?.bounds.size.width ?? 0.0) * (swipeThreshold ?? 0.0)))) ? (activeButtons?.bounds.size.width ?? 0.0) * sign : 0.0
        }
        let onlyButtons = activeSettings?.onlySwipeButtons
        let safeInsets = getSafeInsets()
        let safeInset = isRTLLocale() ? safeInsets.right : -safeInsets.left
        swipeView?.transform = CGAffineTransform(translationX: safeInset + (onlyButtons ?? false ? 0 : swipeOffset), y: 0)

        //animate existing buttons
        let but = [leftView, rightView]
        let settings = [leftSwipeSettings, rightSwipeSettings]
        let expansions = [leftExpansion, rightExpansion]
        
        for i in 0..<2 {
            let view = but[i]
            if view == nil {
                continue
            }

            //buttons view position
            let translation: CGFloat = min(offset, view?.bounds.size.width ?? 0.0) * sign + (settings[i]?.offset ?? 0.0) * sign
            view?.transform = CGAffineTransform(translationX: translation, y: 0)

            if view != activeButtons {
                continue //only transition if active (perf. improvement)
            }
            let expand = expansions[i]!.buttonIndex >= 0 && offset > (view?.bounds.size.width ?? 0.0) * expansions[i]!.threshold
            if expand {
                view?.expand(toOffset: offset, settings: expansions[i]!)
                targetOffset = expansions[i]!.fillOnTrigger ? bounds.size.width * sign : 0
                activeExpansion = view
                self.update(i != 0 ? MGSwipeState.expandingRightToLeft : MGSwipeState.expandingLeftToRight)
            }
            else {
                view?.endExpansion(animated: true)
                activeExpansion = nil
                let t = min(1.0, offset / (view?.bounds.size.width ?? 0.0))
                view?.transition(settings[i]!.transition ?? .border , percent: t)
                self.update(i != 0 ? MGSwipeState.swipingRightToLeft : MGSwipeState.swipingLeftToRight)
            }
        }
    }
    func hideSwipe(animated: Bool, completion: @escaping (_ finished: Bool) -> Void) {
        let animation = animated ? (swipeOffset > 0 ? leftSwipeSettings.hideAnimation : rightSwipeSettings.hideAnimation) : nil
        setSwipeOffset(0, animation: animation, completion: completion)
    }

    func hideSwipe(animated: Bool) {
        hideSwipe(animated: animated) { _ in }
    }

    func showSwipe(_ direction: MGSwipeDirection, animated: Bool) {
        showSwipe(direction, animated: animated, completion: {_ in})
    }
    func showSwipe(_ direction: MGSwipeDirection, animated: Bool, completion: @escaping (_ finished: Bool) -> Void) {
        createSwipeViewIfNeeded()
        allowSwipeLeftToRight = leftButtons.count > 0
        allowSwipeRightToLeft = rightButtons.count > 0
        let buttonsView = direction == MGSwipeDirection.leftToRight ? leftView : rightView

        if buttonsView != nil {
            let s: CGFloat = direction == MGSwipeDirection.leftToRight ? 1.0 : -1.0
            let animation = animated ? (direction == MGSwipeDirection.leftToRight ? leftSwipeSettings.showAnimation : rightSwipeSettings.showAnimation) : nil
            setSwipeOffset((buttonsView?.bounds.size.width ?? 0.0) * s, animation: animation, completion: completion)
        }
    }
    func expandSwipe(_ direction: MGSwipeDirection, animated: Bool) {
        let s: CGFloat = direction == MGSwipeDirection.leftToRight ? 1.0 : -1.0
        let expSetting = direction == MGSwipeDirection.leftToRight ? leftExpansion : rightExpansion
        if activeExpansion == nil && expSetting!.fillOnTrigger {
            createSwipeViewIfNeeded()
            allowSwipeLeftToRight = leftButtons.count > 0
            allowSwipeRightToLeft = rightButtons.count > 0
            let buttonsView = direction == MGSwipeDirection.leftToRight ? leftView : rightView

            if buttonsView != nil {
                weak var expansionView = direction == MGSwipeDirection.leftToRight ? leftView : rightView
                weak var weakself = self
                setSwipeOffset((buttonsView?.bounds.size.width ?? 0.0) * s * expSetting!.threshold * 2.0, animation: expSetting!.triggerAnimation) { finished in
                    expansionView?.endExpansion(animated: true)
                    weakself?.setSwipeOffset(0, animated: false, completion: {_ in})
                }
            }
        }
    }
    @objc func animationTick(_ timer: CADisplayLink?) {
        if animationData?.start == nil {
            animationData?.start = timer?.timestamp ?? 0
        }
        let elapsed = (timer?.timestamp ?? 0) - (animationData?.start ?? 0)
        let completed = elapsed >= animationData?.duration ?? 0
        if completed {
            triggerStateChanges = true
        }
        let calculatedOffset = animationData?.animation?.value(CGFloat(elapsed), duration: CGFloat(animationData?.duration ?? 0), from: animationData?.from ?? 0.0, to: animationData?.to ?? 0.0) ?? 0.0
        self.setSwipeOffset(calculatedOffset)
        //call animation completion and invalidate timer
        if completed {
            timer?.invalidate()
            invalidateDisplayLink()
        }
    }
    func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
        if (animationCompletion != nil) {
            let callbackCopy: ((_ finished: Bool) -> Void)? = animationCompletion //copy to avoid duplicated callbacks
            animationCompletion = nil
            callbackCopy?(true)
        }
    }

    func setSwipeOffset(_ offset: CGFloat, animated: Bool, completion: @escaping (_ finished: Bool) -> Void) {
        let animation = animated ? MGSwipeAnimation() : nil
        setSwipeOffset(offset, animation: animation, completion: completion)
    }
    func setSwipeOffset(_ offset: CGFloat, animation: MGSwipeAnimation?, completion: @escaping (_ finished: Bool) -> Void) {
        if (displayLink != nil) {
            displayLink?.invalidate()
            displayLink = nil
        }
        if (animationCompletion != nil) {
            //notify previous animation cancelled
            let callbackCopy: ((_ finished: Bool) -> Void)? = animationCompletion //copy to avoid duplicated callbacks
            animationCompletion = nil
            callbackCopy?(false)
        }
        if offset != 0 {
            createSwipeViewIfNeeded()
        }
        if animation == nil {
            self.setSwipeOffset(offset)
            completion(true)
            return
        }

        animationCompletion = completion
        triggerStateChanges = false
        animationData?.from = swipeOffset
        animationData?.to = offset
        animationData?.duration = TimeInterval(animation?.duration ?? 0.0)
        animationData?.start = 0
        animationData?.animation = animation
        displayLink = CADisplayLink(target: self, selector: #selector(animationTick(_:)))
        displayLink?.add(to: RunLoop.main, forMode: .common)
    }
    func cancelPanGesture() {
        if panRecognizer?.state != .ended && panRecognizer?.state != .possible {
            panRecognizer?.isEnabled = false
            panRecognizer?.isEnabled = true
            if swipeOffset != 0.0 {
                hideSwipe(animated: true)
            }
        }
    }

    @objc func tapHandler(_ recognizer: UITapGestureRecognizer?) {
//        var hide = true
//        if delegate && delegate.responds(to: #selector(swipeTableCell(_:shouldHideSwipeOnTap:))) {
//            hide = delegate.swipeTableCell(self, shouldHideSwipeOnTap: recognizer?.location(in: self) ?? 0.0)
//        }
        if delegate != nil {
        let hide = delegate!.swipeTableCell(self, shouldHideSwipeOnTap: recognizer?.location(in: self) ?? CGPoint.zero)
            if hide {
                hideSwipe(animated: true)
            }
        }
    }
    func filterSwipe(_ offset: CGFloat) -> CGFloat {
        var offset = offset
        let allowed = offset > 0 ? allowSwipeLeftToRight : allowSwipeRightToLeft
        let buttons = offset > 0 ? leftView : rightView
        if buttons == nil || !allowed {
            offset = 0
        } else if !allowsOppositeSwipe && firstSwipeState == MGSwipeState.swipingLeftToRight && offset < 0 {
            offset = 0
        } else if !allowsOppositeSwipe && firstSwipeState == MGSwipeState.swipingRightToLeft && offset > 0 {
            offset = 0
        }
        return offset
    }
    @objc func panHandler(_ gesture: UIPanGestureRecognizer?) {
        let current = gesture?.translation(in: self)

        if gesture?.state == .began {
            invalidateDisplayLink()

            if !preservesSelectionStatus {
                isHighlighted = false
            }
            createSwipeViewIfNeeded()
            panStartPoint = current ?? CGPoint.zero
            panStartOffset = swipeOffset
            if swipeOffset != 0 {
                firstSwipeState = swipeOffset > 0 ? MGSwipeState.swipingLeftToRight : MGSwipeState.swipingRightToLeft
            }

            if !allowsMultipleSwipe {
                let cells = parentTable()?.visibleCells ?? []
                for cell in cells {
                    guard let cell = cell as? MGSwipeTableCell else {
                        continue
                    }
                    if cell != self {
                        cell.cancelPanGesture()
                    }
                }
            }
        }
        else if gesture?.state == .changed {
            let offset: CGFloat = panStartOffset + (current?.x ?? 0.0) - panStartPoint.x
            if firstSwipeState == MGSwipeState.none {
                firstSwipeState = offset > 0 ? MGSwipeState.swipingLeftToRight : MGSwipeState.swipingRightToLeft
            }
            self.setSwipeOffset(filterSwipe(offset))
        }
        else {
            weak var expansion = activeExpansion
            if expansion != nil {
                weak var expandedButton = expansion?.getExpandedButton()
                let expSettings = swipeOffset > 0 ? leftExpansion : rightExpansion
                var backgroundColor: UIColor? = nil
                if expSettings?.fillOnTrigger == nil && expSettings?.expansionColor != nil {
                    backgroundColor = expansion?.backgroundColorCopy //keep expansion background color
                    expansion?.backgroundColorCopy = expSettings?.expansionColor
                }
                setSwipeOffset(targetOffset, animation: expSettings?.triggerAnimation) { finished in
                    if !finished || self.isHidden || expansion == nil {
                        return //cell might be hidden after a delete row animation without being deallocated (to be reused later)
                    }
                    let autoHide = expansion?.handleClick(expandedButton, fromExpansion: true)
                    if autoHide ?? false {
                        expansion?.endExpansion(animated: false)
                    }
                    if (backgroundColor != nil) && (expandedButton != nil) {
                        expandedButton?.backgroundColor = backgroundColor
                    }
                }
            }
            else {
                let velocity = panRecognizer?.velocity(in: self).x ?? 0.0
                let inertiaThreshold: CGFloat = 100.0 //points per second

                if velocity > inertiaThreshold {
                    targetOffset = swipeOffset < 0 ? 0 : ((leftView != nil) && leftSwipeSettings.keepButtonsSwiped ? leftView?.bounds.size.width ?? 0.0 : targetOffset)
                } else if velocity < -inertiaThreshold {
                    targetOffset = swipeOffset > 0 ? 0 : ((rightView != nil) && rightSwipeSettings.keepButtonsSwiped ? -(rightView?.bounds.size.width ?? 0.0) : targetOffset)
                }
                targetOffset = filterSwipe(targetOffset)
                let settings = swipeOffset > 0 ? leftSwipeSettings : rightSwipeSettings
                var animation: MGSwipeAnimation? = nil
                if targetOffset == 0 {
                    animation = settings?.hideAnimation
                } else if abs(swipeOffset) > abs(targetOffset) {
                    animation = settings?.stretchAnimation
                } else {
                    animation = settings?.showAnimation
                }
                setSwipeOffset(targetOffset, animation: animation, completion: {_ in })
            }
            firstSwipeState = MGSwipeState.none
        }
    }
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer == panRecognizer {

            if isEditing {
                return false //do not swipe while editing table
            }

            let translation = panRecognizer?.translation(in: self) ?? CGPoint.zero
            if abs(Float(translation.y )) > abs(Float(translation.x )) {
                return false // user is scrolling vertically
            }
            if (swipeView != nil) {
                let point = tapRecognizer?.location(in: swipeView) ?? CGPoint.zero
                if !swipeView!.bounds.contains(point) {
                    return allowsSwipeWhenTappingButtons //user clicked outside the cell or in the buttons area
                }
            }

            if swipeOffset != 0.0 {
                return true //already swiped, don't need to check buttons or canSwipe delegate
            }
//            if delegate != nil {
//                let point = panRecognizer?.location(in: self) ?? CGPoint.zero
//                allowSwipeLeftToRight = delegate!.swipeTableCell(self, canSwipe: MGSwipeDirection.leftToRight, from: point)
//                allowSwipeRightToLeft = delegate!.swipeTableCell(self, canSwipe: MGSwipeDirection.rightToLeft, from: point)
//            }
//            else if delegate && delegate.responds(to: #selector(swipeTableCell(_:canSwipe:))) {
//            //#pragma clang diagnostic push
//            //#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//                allowSwipeLeftToRight = delegate.swipeTableCell(self, canSwipe: MGSwipeDirectionLeftToRight)
//                allowSwipeRightToLeft = delegate.swipeTableCell(self, canSwipe: MGSwipeDirectionRightToLeft)
//            //#pragma clang diagnostic pop
//            }
//            else {
                fetchButtonsIfNeeded()
                allowSwipeLeftToRight = leftButtons.count > 0
                allowSwipeRightToLeft = rightButtons.count > 0
//            }
            return (allowSwipeLeftToRight && translation.x > 0.0) || (allowSwipeRightToLeft && translation.x < 0.0)
        }
        else if (gestureRecognizer == tapRecognizer) {
            let point = tapRecognizer?.location(in: swipeView) ?? CGPoint.zero
            return swipeView?.bounds.contains(point) ?? false
        }
        return true;
    }
    func isSwipeGestureActive() -> Bool {
        return panRecognizer?.state == .began || panRecognizer?.state == .changed
    }

    func setSwipeBackgroundColor(_ swipeBackgroundColor: UIColor?) {
        self.swipeBackgroundColor = swipeBackgroundColor
        if (swipeOverlay != nil) {
            swipeOverlay?.backgroundColor = swipeBackgroundColor
        }
    }
    // MARK: Accessibility
    override func accessibilityElementCount() -> Int {
        return swipeOffset == 0 ? super.accessibilityElementCount() : 1
    }

    override func accessibilityElement(at index: Int) -> Any? {
        return swipeOffset == 0 ? (super.accessibilityElement(at: index) as? UIView) : contentView
    }

    override func index(ofAccessibilityElement element: Any) -> Int {
        return swipeOffset == 0 ? super.index(ofAccessibilityElement: element) : 0
    }
}
