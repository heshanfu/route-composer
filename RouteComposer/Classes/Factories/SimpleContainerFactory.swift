//
// Created by Eugene Kazaev on 22/02/2018.
//

import Foundation
import UIKit

/// Helper protocol to `Factory` that is also a `Container`. If it supports only one type of actions to build its
/// children `UIViewControllers` - use this protocol. It contains default merge function implementation.
public protocol SimpleContainerFactory: Container {

    /// Type of supported `Action` instances
    associatedtype SupportedAction

    /// Factories that will build children view controllers when it will be needed.
    var factories: [ChildFactory<Context>] { get set }

}

public extension SimpleContainerFactory {

    public mutating func merge(_ factories: [ChildFactory<Context>]) -> [ChildFactory<Context>] {
        var otherFactories: [ChildFactory<Context>] = []
        self.factories = factories.compactMap { factory -> ChildFactory<Context>? in
            guard factory.action as? SupportedAction != nil else {
                otherFactories.append(factory)
                return nil
            }
            return factory
        }

        return otherFactories
    }

    /// This function contains default implementation how Container should create its children view controller
    /// before built them into itself.
    ///
    /// - Parameters:
    ///   - context: A `Context` instance if any
    /// - Returns: An array of build view controllers
    /// - Throws: RoutingError
    public func buildChildrenViewControllers(with context: Context) throws -> [UIViewController] {
        return try buildChildrenViewControllers(from: factories, with: context)
    }

}
