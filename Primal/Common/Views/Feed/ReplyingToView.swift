//
//  ReplyingToView.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.10.23..
//

import UIKit

class ReplyingToView: UIStackView {
    let replyingToLabel = UILabel()
    let userNameLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        [replyingToLabel, userNameLabel, UIView()].forEach { addArrangedSubview($0) }
        
        userNameLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .light)
        replyingToLabel.font = .appFont(withSize: FontSizeSelection.current.nameSize, weight: .light)
        
        replyingToLabel.textColor = .foreground4
        userNameLabel.textColor = .accent2
        
        replyingToLabel.text = "replying to "
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
