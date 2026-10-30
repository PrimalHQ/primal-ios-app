






import Foundation

import Combine
final class HighlightManager {
    private init() {}
    
    static let instance = HighlightManager()
    
    var cancellables: Set<AnyCancellable> = []
    
}
