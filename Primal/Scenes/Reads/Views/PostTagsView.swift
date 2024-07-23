//
//  PostTagsView.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.6.24..
//

import UIKit

class PostTagsView: UIView {
    let mainStack = UIStackView(axis: .vertical, [])
    
    var tags: [String] = [] {
        didSet {
            updateView()
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        addSubview(mainStack)
        mainStack.pinToSuperview()
        mainStack.spacing = 4
        mainStack.alignment = .leading
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateView() {
        mainStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var currentRow = newRow()
        var currentWidth: CGFloat = 0
        if let first = tags.first {
            currentRow.addArrangedSubview(PostTagView(first))
            currentWidth += widthForTag(first)
        }
        
        tags.dropFirst().forEach { tag in
            let width = widthForTag(tag)
            currentWidth += width
            
            if currentWidth > 300 {
                mainStack.addArrangedSubview(currentRow)
                currentRow = newRow()
                currentWidth = width
            } 

            currentRow.addArrangedSubview(PostTagView(tag))
        }
        
        if currentWidth > 0 {
            mainStack.addArrangedSubview(currentRow)
        }
    }
    
    func newRow() -> UIStackView {
        let stack = UIStackView()
        stack.spacing = 4
        return stack
    }
    
    func widthForTag(_ tag: String) -> CGFloat {
        20 + (tag as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 100),
            options: .usesLineFragmentOrigin,
            attributes: [
                NSAttributedString.Key.font: UIFont.appFont(withSize: 14, weight: .regular)
            ],
            context: nil
        ).width
    }
}

class PostTagView: UIView {
    private let titleLabel = UILabel()
    
    init(_ title: String) {
        super.init(frame: .zero)
        
        titleLabel.font = .appFont(withSize: 14, weight: .regular)
        
        constrainToSize(height: 26)
        layer.cornerRadius = 13
        
        addSubview(titleLabel)
        titleLabel.pinToSuperview(edges: .horizontal, padding: 10).centerToSuperview()
        
        update(title)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func update(_ title: String) {
        titleLabel.text = title
        titleLabel.textColor = .foreground3
        backgroundColor = .background3
    }
}
