//
//  MGSwipeTableInputOverlay.swift
//  MgSwipeTableViewSwift
//
//  Created by Ankit Chaudhary on 31/07/20.
//  Copyright © 2020 Ankit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
class MGSwipeTableInputOverlay: UIView {
    var currentCell: MGSwipeTableCell?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if event == nil {
            return nil
        }
        if currentCell == nil {
            removeFromSuperview()
            return nil
        }
        let p = convert(point, to: currentCell)
        if (currentCell != nil) && (currentCell!.isHidden || currentCell!.bounds.contains(p)) {
            return nil
        }
        var hide = true
        currentCell
        currentCell?.delegate?.swipeTableCell(currentCell, shouldHideSwipeOnTap: p)
        if hide {
            currentCell?.hideSwipe(animated: true)
        }
        return currentCell?.touchOnDismissSwipe ?? false ? nil : self
    }
}
