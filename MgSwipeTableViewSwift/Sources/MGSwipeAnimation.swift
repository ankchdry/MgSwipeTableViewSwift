//
//  MGSwipeAnimation.swift
//  MgSwipeTableViewSwift
//
//  Created by Lokesh Kumar on 31/07/20.
//  Copyright © 2020 Lokesh Kumar. All rights reserved.
//
import UIKit
import Foundation
class MGSwipeAnimation {
    var duration: CGFloat?
    var easingFunction: MGSwipeEasingFunction!
    
    init() {
        duration = 0.3
        easingFunction = .cubicOut
    }
    
    func value(_ elapsed: CGFloat, duration: CGFloat, from: CGFloat, to: CGFloat) -> CGFloat {
        let t = min(elapsed / duration, 1.0)
        if t == 1.0 {
            return to //precise last value
        }
        var easingFunction: ((_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat)? = nil
        switch self.easingFunction {
        case .linear:
            easingFunction = mgEaseLinear
        case .quadIn:
            easingFunction = mgEaseInQuad
        case .quadOut:
            easingFunction = mgEaseOutQuad
        case .quadInOut:
            easingFunction = mgEaseInOutQuad
        case .cubicIn:
            easingFunction = mgEaseInCubic
        case .cubicInOut:
            easingFunction = mgEaseInOutCubic
        case .bounceIn:
            easingFunction = mgEaseInBounce
        case .cubicOut:
            easingFunction = mgEaseOutCubic
        case .bounceOut:
            easingFunction = mgEaseOutBounce
        case .bounceInOut:
            easingFunction = mgEaseInOutBounce
        case .none:
            ()
        }
        return (easingFunction!)(t, from, to - from)
    }
}

/// Easing Functions and MGSwipeAnimation

@inline(__always) private func mgEaseLinear(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat {
    return c * t + b
}


@inline(__always) private func mgEaseInQuad(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat {
    return c * t * t + b
}

@inline(__always) private func mgEaseOutQuad(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat {
    return -c * t * (t - 2) + b
}


@inline(__always) private func mgEaseInOutQuad(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat {
    var t = t * 2
    if t < 1 {
        return c / 2 * t * t + b
    }
    t -= 1
    return -c / 2 * (t * (t - 2) - 1) + b
}


@inline(__always) private func mgEaseInCubic(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat {
    return c * t * t * t + b
}

@inline(__always) private func mgEaseOutCubic(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat {
    let t = t - 1
    return c * (t * t * t + 1) + b
}


@inline(__always) private func mgEaseInOutCubic(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat {
    var t = t * 2
    if (t < 1) {
        return c / 2 * t * t * t + b
    }
    t -= 2
    return c / 2 * (t * t * t + 2) + b
}

@inline(__always) private func mgEaseOutBounce(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat {
    var t = t
    if t < (1 / 2.75) {
        return c * (7.5625 * t * t) + b
    } else if t < (2 / 2.75) {
        t -= 1.5 / 2.75
        return c * (7.5625 * t * t + 0.75) + b
    } else if t < (2.5 / 2.75) {
        t -= 2.25 / 2.75
        return c * (7.5625 * t * t + 0.9375) + b
    } else {
        t -= 2.625 / 2.75
        return c * (7.5625 * t * t + 0.984375) + b
    }
}


@inline(__always) private func mgEaseInBounce(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat {
    return c - mgEaseOutBounce(1.0 - t, 0, c) + b
}

@inline(__always) private func mgEaseInOutBounce(_ t: CGFloat, _ b: CGFloat, _ c: CGFloat) -> CGFloat {
    if t < 0.5 {
        return mgEaseInBounce(t * 2, 0, c) * 0.5 + b
    }
    return mgEaseOutBounce(1.0 - t * 2, 0, c) * 0.5 + c * 0.5 + b
}
