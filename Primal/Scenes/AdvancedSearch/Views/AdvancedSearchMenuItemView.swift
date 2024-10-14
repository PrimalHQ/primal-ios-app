//
//  AdvancedSearchMenuItemView.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.10.24..
//

import UIKit

class AdvancedSearchMenuItemView: MyButton {
    private let titleLabel = UILabel()
    fileprivate let valueLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(named: "chevron"))
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.8 : 1
        }
    }
    
    var value: String {
        get { valueLabel.text ?? "" }
        set { valueLabel.text = newValue }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        
        [titleLabel, valueLabel].forEach {
            $0.font = .appFont(withSize: 16, weight: .regular)
            $0.textColor = .foreground3
        }
        
        let stack = UIStackView([titleLabel, UIView(), valueLabel, SpacerView(width: 12), chevron])
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical, padding: 17)
        
        chevron.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class AdvancedSearchUsersMenuItemView: AdvancedSearchMenuItemView {
    let userView = AvatarView(size: 24, spacing: 4, maxAvatarCount: 5)
    
    override init(title: String) {
        super.init(title: title)
        
        addSubview(userView)
        userView.centerToView(valueLabel, axis: .vertical).pin(to: valueLabel, edges: .trailing)
        userView.isHidden = true
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setUsers(_ users: [ParsedUser]) {
        if users.isEmpty {
            value = "Anyone"
            userView.isHidden = true
            return
        }
        value = ""
        userView.isHidden = false
        userView.setImages(users.compactMap { $0.profileImage.url(for: .small) }, userCount: users.count)
    }
}
