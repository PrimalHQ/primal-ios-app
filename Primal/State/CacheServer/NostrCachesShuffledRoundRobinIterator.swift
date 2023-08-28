//
// Created by Nikola Lukovic on 28.8.23..
//

import Foundation

struct NostrCacheURLShuffledRoundRobinIterator: IteratorProtocol {
    private let urls: [String]
    var currentIndex = 0

    init(_ urls: [String]) {
        self.urls = urls.shuffled()
    }

    mutating func next() -> String? {
        defer { moveIndex() }
        return urls[currentIndex]
    }

    private mutating func moveIndex() {
        var assumedNextIndex = currentIndex + 1
        if assumedNextIndex >= urls.count {
            assumedNextIndex = 0
        }

        currentIndex = assumedNextIndex
    }
}
