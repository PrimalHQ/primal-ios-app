//
//  Publisher+Extra.swift
//  Primal
//
//  Created by Pavle D Stevanović on 12.6.23..
//

import Combine
import Foundation

struct TimeoutError: Error { }

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
extension Publisher where Self.Failure == Never {
    func sinkAsync(receiveValue: @escaping (Self.Output) async -> Void) -> AnyCancellable {
        sink { value in
            Task {
                await receiveValue(value)
            }
        }
    }
    
    func timeoutDefaultValue(duration: Int, _ defaultValue: Output) -> AnyPublisher<Output, Never> {
        self
            .mapError({ _ in TimeoutError() })
            .timeout(.seconds(duration), scheduler: DispatchQueue.main, customError: { TimeoutError() })
            .catch({ _ in  Just(defaultValue) })
            .eraseToAnyPublisher()
    }
}

extension Publisher where Self.Output == PostRequestResult {
    func mapEventsOfKind<T: Codable>(_ kind: NostrKind) -> AnyPublisher<T, Self.Failure> {
        compactMap {
            guard let event = $0.events.first(where: { Int($0["kind"]?.doubleValue ?? 0) == kind.rawValue }) else { return nil }
            return event["content"]?.stringValue?.decode()
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func withPrevious() -> AnyPublisher<(Output, Output), Failure> {
        Publishers.Zip(self, self.dropFirst()).eraseToAnyPublisher()
    }
    
    func waitForConnection(_ connection: Connection) -> AnyPublisher<Output, Failure> {
        return connection.isConnectedPublisher
            .filter { $0 }
            .first()
            .flatMap { _ in self }
            .eraseToAnyPublisher()
    }
}
