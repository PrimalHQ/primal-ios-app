//
//  RemoteSignerConnectionSimpleAccentCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9. 12. 2025..
//

import UIKit

final class RemoteSignerConnectionSimpleAccentCell: UITableViewCell {
    static let reuseID = "RemoteSignerConnectionSimpleAccentCell"
    
    let label = UILabel("", color: .accent2, font: .appFont(withSize: 16, weight: .regular))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Setup your cell UI here
        selectionStyle = .none
        
        contentView.addSubview(label)
        label.pinToSuperview(edges: .vertical, padding: 15).pinToSuperview(edges: .horizontal)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configureWithText(_ text: String) {
        label.text = text
        label.textColor = .accent2
        backgroundColor = .clear
    }
}
