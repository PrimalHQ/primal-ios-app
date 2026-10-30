






import Combine
import UIKit

enum KeyboardState {
    case shown(height: CGFloat)
    case hidden
    
    var isShown: Bool {
        if case .hidden = self {
            return false
        }
        return true
    }
}


extension Publishers {
    static var keyboardState: AnyPublisher<KeyboardState, Never> {
        KeyboardManager.instance.$keyboardHeight
            .map { $0 < 1 ? .hidden : .shown(height: $0) }
            .eraseToAnyPublisher()
    }
}
