//
// Created by Eugene Kazaev on 25/07/2018.
// Copyright (c) 2018 Gilt Groupe. All rights reserved.
//

import Foundation
import UIKit
@testable import RouteComposer

struct EmptyFactory: Factory {
    let action: Action

    init(action: Action = GeneralAction.NilAction()) {
        self.action = action
    }

    func build(with context: Any?) throws -> UIViewController {
        return UIViewController()
    }
}
