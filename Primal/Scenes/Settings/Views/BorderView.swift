






import UIKit

final class BorderView: UIView, Themeable {
    init() {
        super.init(frame: .zero)
        
        constrainToSize(height: 1)
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background3
    }
}
