//
//  Enums.swift
//  MgSwipeTableViewSwift
//
//  Created by Lokesh Kumar on 31/07/20.
//  Copyright © 2020 Lokesh Kumar. All rights reserved.
//

import Foundation
import UIKit
/// Transition types
enum MGSwipeTransition : Int {
    case border = 0
    case `static`
    case drag
    case clipCenter
    case rotate3D
}

/// Swipe directions
enum MGSwipeDirection : Int {
    case leftToRight = 0
    case rightToLeft
}

/// Swipe state
enum MGSwipeState : Int {
    case none = 0
    case swipingLeftToRight
    case swipingRightToLeft
    case expandingLeftToRight
    case expandingRightToLeft
}

/// Swipe Expansion Layout
enum MGSwipeExpansionLayout : Int {
    case border = 0
    case center
    case none
}

/// Swipe Easing Function
enum MGSwipeEasingFunction : Int {
    case linear = 0
    case quadIn
    case quadOut
    case quadInOut
    case cubicIn
    case cubicOut
    case cubicInOut
    case bounceIn
    case bounceOut
    case bounceInOut
}
