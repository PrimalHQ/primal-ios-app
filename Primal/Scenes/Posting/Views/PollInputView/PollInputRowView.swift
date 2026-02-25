//
//  PollInputRowView.swift
//  Primal
//
//  Created by Pavle Stevanović on 25. 2. 2026..
//

import UIKit

class PollInputRowView: UIView {
    private let nameLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 16, weight: .regular))
    let valueLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .regular))
    
    lazy var valueStack = UIStackView([nameLabel, UIView(), valueLabel]).constrainToSize(height: 48)
    lazy var mainStack = UIStackView(axis: .vertical, [valueStack])
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(title: String) {
        nameLabel.text = title
        super.init(frame: .zero)
        
        valueStack.alignment = .center
        
        mainStack.isUserInteractionEnabled = false
        addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 4).pinToSuperview(edges: .vertical)
        
        let border = SpacerView(height: 1, color: .foreground6)
        addSubview(border)
        border.pinToSuperview(edges: [.top, .horizontal])
    }
}
