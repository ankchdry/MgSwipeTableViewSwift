//
//  MGSwipeTableCell.swift
//  MgSwipeTableViewSwift
//
//  Created by Ankit Chaudhary on 31/07/20.
//  Copyright © 2020 Ankit Chaudhary. All rights reserved.
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
        print("canSwipe");
        return true;
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        print("canSwipe");
        return true;
    } //backwards compatibility

    func swipeTableCell(_ cell: MGSwipeTableCell, didChange state: MGSwipeState, gestureIsActive: Bool) {
        print("didChange");
        
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        print("tappedButtonAt");
        return true;
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, swipeButtonsFor direction: MGSwipeDirection, swipeSettings: MGSwipeSettings, expansionSettings: MGSwipeExpansionSettings) -> [UIView]? {
        print("swipeButtonsFor");
        return [];
    }

    func swipeTableCell(_ cell: MGSwipeTableCell, shouldHideSwipeOnTap point: CGPoint) -> Bool {
        print("shouldHideSwipeOnTap");
        return true;
    }

    func swipeTableCellWillBeginSwiping(_ cell: MGSwipeTableCell) {
        print("swipeTableCellWillBeginSwiping");
    }

    func swipeTableCellWillEndSwiping(_ cell: MGSwipeTableCell) {
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
    private(set) var isSwipeGestureActive = false
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
    let panStartPoint: CGPoint
    let panStartOffset: CGFloat = 0.0
    let targetOffset: CGFloat = 0.0

    var swipeOverlay: UIView? = nil
    var swipeView: UIImageView? = nil
    var swipeContentView: UIView? = nil
    var leftView: MGSwipeButtonsView? = nil
    var rightView: MGSwipeButtonsView? = nil
    let allowSwipeRightToLeft = false
    let allowSwipeLeftToRight = false
    weak var activeExpansion: MGSwipeButtonsView?
    
    var tableInputOverlay: MGSwipeTableInputOverlay? = nil
    var overlayEnabled: Bool
    var previusSelectionStyle: UITableViewCell.SelectionStyle
    var previusHiddenViews: Set<UIView> = []
    var previusAccessoryType: UITableViewCell.AccessoryType
    var triggerStateChanges: Bool

    var animationData: MGSwipeAnimationData? = nil
    let animationCompletion: ((_ finished: Bool) -> Void)? = nil
    var displayLink: CADisplayLink? = nil
    var firstSwipeState: MGSwipeState
    
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
        if !(swipeContentView != nil) {
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
            rightButtons = delegate!.swipeTableCell(self, swipeButtonsFor: MGSwipeDirection.leftToRight, swipeSettings: rightSwipeSettings, expansionSettings: rightExpansion) ?? []
        }
    }
    func createSwipeViewIfNeeded() {
        let safeInsets = getSafeInsets()
        if !(swipeOverlay != nil) {
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
        swipeView?.image = image(fromView: self, cropSize: cropSize)

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
        swipeOffset = 0
        swipeOffset = currentOffset
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
            swipeOffset = 0
        }
    }

    func setEditing(_ editing: Bool) {
        super.setEditing(editing, animated: true)
        if editing {
            //disable swipe buttons when the user sets table editing mode
            swipeOffset = 0
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
        delegate?.swipeTableCell(self, didChange: swipeState!, gestureIsActive: isSwipeGestureActive)
    }
    
    func setAccesoryViewsHidden(_ hidden: Bool) {
    }
}
