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
    
    var _buttons: [AnyHashable]? = nil
    var _container: UIView? = nil
    var _fromLeft: Bool? = false
    var _expandedButton: UIView? = nil
    var _expandedButtonAnimated: UIView? = nil
    var _expansionBackground: UIView? = nil
    var _expansionBackgroundAnimated: UIView? = nil
    var _expandedButtonBoundsCopy: CGRect = CGRect.init()
    var _direction: MGSwipeDirection?
    var _expansionLayout: MGSwipeExpansionLayout?
    var _expansionOffset: CGFloat = 0.0
    var _buttonsDistance: CGFloat = 0.0
    var _safeInset: CGFloat = 0.0
    var _autoHideExpansion: Bool = false
}


