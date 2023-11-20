//
//  TransactionHeader.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.10.23..
//

import UIKit

final class TransactionHeader: UITableViewHeaderFooterView, Themeable {
    let leftLine = UIView()
    let rightLine = UIView()
    let title = UILabel()
    
    let expander = UIView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func set(_ text: String) {
        title.text = text
        updateTheme()
    }
    
    private func setup() {
        contentView.addSubview(expander)
        expander.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: -30).pinToSuperview(edges: .bottom)
        
        let stack = UIStackView([leftLine, title, rightLine])
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal)
        stack.alignment = .center
        stack.spacing = 12
        
        leftLine.constrainToSize(height: 1)
        rightLine.constrainToSize(height: 1)
        leftLine.widthAnchor.constraint(equalTo: rightLine.widthAnchor).isActive = true
        
        title.font = .appFont(withSize: 14, weight: .regular)
        
    }
    
    func updateTheme() {
        expander.backgroundColor = .background
        
        leftLine.backgroundColor = .background3
        rightLine.backgroundColor = .background3
        title.textColor = .foreground4
    }
}
