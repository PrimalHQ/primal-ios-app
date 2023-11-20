//
//  FormHeaderView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 6.7.23..
//

import UIKit

final class FormHeaderView: UIStackView {
    convenience init(title: String, required: Bool) {
        let label = UILabel()
        label.font = .appFont(withSize: 16, weight: .regular)
        label.textColor = .init(rgb: 0xAAAAAA)
        label.text = title
        
        let requiredLabel = UILabel()
        let requiredText = NSMutableAttributedString(string: "* ", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.init(rgb: 0xE20505)
        ])
        requiredText.append(.init(string: "required", attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.init(rgb: 0x666666)
        ]))
        requiredLabel.attributedText = requiredText
        requiredLabel.isHidden = !required
        
        self.init(arrangedSubviews: [label, UIView(), requiredLabel, SpacerView(width: 8)])
    }
}
