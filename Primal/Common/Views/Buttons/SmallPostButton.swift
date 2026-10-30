






import UIKit

final class SmallPostButton: UIButton, Themeable {

    
    init(title: String) {
        super.init(frame: .zero)
        


        



        
        setTitle(title, for: .normal)
        titleLabel?.font = .appFont(withSize: 14, weight: .medium)

        // Stable handle for UI automation. The title changes with posting state
        // ("Post" / "Reply" / "Posting..." / "Uploading..."), so it is not one.
        accessibilityIdentifier = "composerPostButton"
        
        constrainToSize(height: 28)
        layer.cornerRadius = 14
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isEnabled: Bool {
        didSet {
            updateTheme()
        }
    }
    
    func updateTheme() {
        backgroundColor = isEnabled ? .accent : .background3
        setTitleColor(isEnabled ? .white : .foreground5, for: .normal)
    }
}
