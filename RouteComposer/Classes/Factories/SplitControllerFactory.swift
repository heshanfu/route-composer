//
// Created by Eugene Kazaev on 16/01/2018.
// Copyright (c) 2018 HBC Tech. All rights reserved.
//

import Foundation
import UIKit

/// `Container` `Factory` that creates `UISplitViewController`
public struct SplitControllerFactory: Container {
    
    public typealias ViewController = UISplitViewController
    
    public typealias Context = Any?
    
    public let action: Action
    
    var masterFactories: [ChildFactory<Context>] = []
    
    var detailFactories: [ChildFactory<Context>] = []
    
    /// `UISplitViewControllerDelegate` delegate
    public let delegate: UISplitViewControllerDelegate?
    
    /// An animatable property that controls how the primary view controller is hidden and displayed. A value of `.automatic` specifies the default behavior split view controller, which on an iPad, corresponds to an overlay mode in portrait and a side-by-side mode in landscape.
    public let preferredDisplayMode: UISplitViewController.DisplayMode
    
    /// If 'true', hidden view can be presented and dismissed via a swipe gesture. Defaults to 'true'.
    public let presentsWithGesture: Bool
    
    /// Constructor
    ///
    /// - Parameter action: `Action` instance.
    public init(action: Action, delegate: UISplitViewControllerDelegate? = nil, presentsWithGesture: Bool = true, isCollapsed: Bool = false, preferredDisplayMode: UISplitViewController.DisplayMode = .automatic) {
        self.action = action
        self.delegate = delegate
        self.preferredDisplayMode = preferredDisplayMode
        self.presentsWithGesture = presentsWithGesture
    }
    
    mutating public func merge(_ factories: [ChildFactory<Context>]) -> [ChildFactory<Context>] {
        var rest: [ChildFactory<Context>] = []
        factories.forEach { factory in
            if let _ = factory.action as? SplitControllerMasterAction {
                masterFactories.append(factory)
            } else if let _ = factory.action as? SplitControllerDetailAction {
                detailFactories.append(factory)
            } else {
                rest.append(factory)
            }
        }
        
        return rest
    }
    
    public func build(with context: Context) throws -> ViewController {
        guard masterFactories.count > 0, detailFactories.count > 0 else {
            throw RoutingError.message("No master or derails view controllers provided")
        }
        
        let masterViewControllers = try buildChildrenViewControllers(from: masterFactories, with: context)
        let detailsViewControllers = try buildChildrenViewControllers(from: detailFactories, with: context)
        guard masterViewControllers.count > 0 else {
            throw RoutingError.message("No master or derails view controllers provided")
        }
        guard detailsViewControllers.count > 0 else {
            throw RoutingError.message("At least 1 Details View Controller is mandatory to build UISplitViewController")
        }
        
        let splitController = UISplitViewController(nibName: nil, bundle: nil)
        splitController.presentsWithGesture = presentsWithGesture
        splitController.preferredDisplayMode = preferredDisplayMode
        if let delegate = delegate {
            splitController.delegate = delegate
        }
        var childrenViewControllers = masterViewControllers
        childrenViewControllers.append(contentsOf: detailsViewControllers)
        splitController.viewControllers = childrenViewControllers
        return splitController
    }
    
}
