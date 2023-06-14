//
//  Publisher+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 12.6.23..
//

import Combine

extension Publisher where Failure == Never {
    func assign<Root: AnyObject>(
        to keyPath: ReferenceWritableKeyPath<Root, Output>,
        onWeak object: Root
    ) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
