






import Foundation

public extension LosslessStringConvertible {
    var string: String { .init(self) }
}

public extension String {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}
