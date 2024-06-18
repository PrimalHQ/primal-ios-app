//
//  PostCommentsTitleCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.6.24..
//

import UIKit

protocol PostCommentsTitleCellDelegate: AnyObject {
    func postCommentPressed()
}

class PostCommentsTitleCell: UITableViewCell, Themeable {
    let titleLabel = UILabel()
    let button = UIButton(configuration: .accent14("Post Comment")).constrainToSize(height: 36)
    let backgroundColorView = UIView()
    
    weak var delegate: PostCommentsTitleCellDelegate? {
        didSet {
            updateTheme()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        contentView.addSubview(backgroundColorView)
        backgroundColorView.pinToSuperview(edges: [.top, .horizontal]).pinToSuperview(edges: .bottom, padding: 10)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, UIView(), button])
        stack.alignment = .center
        
        contentView.addSubview(stack)
        stack
            .pinToSuperview(edges: .top, padding: 16)
            .pinToSuperview(edges: .bottom, padding: 26)
            .pinToSuperview(edges: .horizontal, padding: 20)
        
        titleLabel.text = "Comments"
        titleLabel.font = .appFont(withSize: 24, weight: .bold)
        
        button.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.postCommentPressed()
        }), for: .touchUpInside)
        
        updateTheme()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        titleLabel.textColor = .foreground
        button.configuration = .accent14("Post Comment")
        
        backgroundColorView.backgroundColor = .background3
    }
}
