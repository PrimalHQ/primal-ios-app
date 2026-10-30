






import UIKit

final class SettingsHeaderView: UITableViewHeaderFooterView, Themeable {
    let label = UILabel()
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 28).pinToSuperview(edges: .bottom, padding: 12)
        label.font = .appFont(withSize: 14, weight: .medium)
        label.text = "YOUR NOSTR FEEDS"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        label.textColor = .foreground
        backgroundColor = .background
        contentView.backgroundColor = .background
    }
}
