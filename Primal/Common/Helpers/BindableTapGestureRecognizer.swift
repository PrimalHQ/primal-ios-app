//
//  BindableTapGestureRecognizer.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.10.23..
//

import UIKit


final class BindableTapGestureRecognizer: UITapGestureRecognizer {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute() {
        action()
    }
}

final class BindablePanGestureRecognizer: UIPanGestureRecognizer {
    private let action: (UIPanGestureRecognizer) -> Void

    init(action: @escaping (UIPanGestureRecognizer) -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute() {
        action(self)
    }
}

final class BindableSwipeGestureRecognizer: UISwipeGestureRecognizer {
    private let action: () -> Void

    init(direction: UISwipeGestureRecognizer.Direction, action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.direction = direction
        self.addTarget(self, action: #selector(execute))
    }
    
    @objc private func execute() {
        action()
    }
}

final class BindableLongTapGestureRecognizer: UILongPressGestureRecognizer {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute() {
        action()
    }
}
