






import UIKit

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis = .horizontal, spacing: CGFloat? = nil, _ subviews: [UIView]) {
        self.init(arrangedSubviews: subviews)
        self.axis = axis
        if let spacing {
            self.spacing = spacing
        }
    }
}
