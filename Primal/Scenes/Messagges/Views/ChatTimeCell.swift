//
//  ChatTimeCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 25.9.23..
//

import Combine
import UIKit

class ChatTimeCell: UITableViewCell, Themeable {
    let label = UILabel()
    lazy var stack = UIStackView(axis: .vertical, [label, SpacerView(height: 8)])
    
    var updateCancellable: AnyCancellable?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        label.font = .appFont(withSize: 12, weight: .regular)
        
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWith(date: Date, isMine: Bool) {
        label.text = date.timeAgoDisplayLong()
        
        stack.alignment = isMine ? .trailing : .leading
        
        updateTheme()
        
        updateCancellable = Timer.publish(every: 10, on: .main, in: .default).autoconnect().sink(receiveValue: { [weak self] _ in
            self?.label.text = date.timeAgoDisplayLong()
        })
    }
    
    func updateTheme() {
        label.textColor = .foreground5
    }
}
