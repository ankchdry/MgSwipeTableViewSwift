//
//  MGSwipeAnimationData.swift
//  MgSwipeTableViewSwift
//
//  Created by Lokesh Kumar on 31/07/20.
//  Copyright © 2020 Lokesh Kumar. All rights reserved.
//
import UIKit
import Foundation
class MGSwipeAnimationData: NSObject {
    var from: CGFloat = 0.0
    var to: CGFloat = 0.0
    var duration: CFTimeInterval = 0
    var start: CFTimeInterval = 0
    var animation: MGSwipeAnimation?
}
