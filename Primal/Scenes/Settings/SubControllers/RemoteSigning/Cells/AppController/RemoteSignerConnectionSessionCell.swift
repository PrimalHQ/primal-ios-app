//
//  RemoteSignerConnectionSessionCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 9. 12. 2025..
//

import UIKit
import PrimalShared
import Kingfisher

final class RemoteSignerConnectionSessionCell: UITableViewCell {

    static let reuseID = "RemoteSignerConnectionSessionCell"

    private let iconView = UIImageView().constrainToSize(20)
    private let titleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 16, weight: .regular))
    
    private let formatter = DateFormatter()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        separatorInset = .zero
        accessoryType = .disclosureIndicator

        iconView.contentMode = .scaleAspectFit
        
        let stack = UIStackView([iconView, titleLabel])
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .vertical, padding: 14).pinToSuperview(edges: .leading, padding: 16).pinToSuperview(edges: .trailing, padding: 20)
        stack.alignment = .center
        stack.setCustomSpacing(6, after: iconView)
        
        formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy h:mm a")
    }

    func configure(session: RemoteAppSession) {
        iconView.kf.setImage(
            with: URL(string: session.image ?? ""),
            placeholder: session.defaultImage(size: 20),
            options: [.processor(RoundCornerImageProcessor(radius: .heightFraction(0.5)))]
        )
        
        titleLabel.text = formatter.string(from: .init(timeIntervalSince1970: TimeInterval(session.sessionStartedAt)))
        
        titleLabel.textColor = .foreground
        backgroundColor = .background5
    }
}
