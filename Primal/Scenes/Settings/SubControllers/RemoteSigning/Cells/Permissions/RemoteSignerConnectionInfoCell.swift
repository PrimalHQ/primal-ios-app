//
//  RemoteSignerConnectionInfoCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 8. 12. 2025..
//

import UIKit
import PrimalShared
import Kingfisher

final class RemoteSignerConnectionInfoCell: UITableViewCell {

    static let reuseID = "RemoteSignerConnectionInfoCell"

    private let iconView = UIImageView().constrainToSize(48)
    private let titleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 18, weight: .bold))
    private let lastSessionLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 15, weight: .regular))

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

        iconView.contentMode = .scaleAspectFit
        
        let topStack = UIStackView(axis: .vertical, [iconView, titleLabel, lastSessionLabel])
        topStack.alignment = .center
        topStack.spacing = 4
        topStack.setCustomSpacing(10, after: iconView)
        
        contentView.addSubview(topStack)
        topStack.pinToSuperview(edges: [.horizontal, .bottom], padding: 16).pinToSuperview(edges: .top)
        
        formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy h:mm a")
    }

    func configure(connection: RemoteAppConnection, lastStart: Date?) {
        iconView.kf.setImage(
            with: URL(string: connection.image ?? ""),
            placeholder: connection.defaultImage(size: 48),
            options: [.processor(RoundCornerImageProcessor(radius: .heightFraction(0.5)))]
        )
        titleLabel.text = connection.name
        
        if let lastStart {
            let dateString = formatter.string(from: lastStart)
            lastSessionLabel.text = "Last session: \(dateString)"
        } else {
            lastSessionLabel.text = "Last session: Never"
        }
        
        titleLabel.textColor = .foreground
        lastSessionLabel.textColor = .foreground3
        
        backgroundColor = .background5
    }

    func configure(session: RemoteAppSession) {
        iconView.kf.setImage(
            with: URL(string: session.image ?? ""),
            placeholder: session.defaultImage(size: 48),
            options: [.processor(RoundCornerImageProcessor(radius: .heightFraction(0.5)))]
        )
        titleLabel.text = session.name
        
        let start = Date(timeIntervalSince1970: TimeInterval(session.sessionStartedAt))
        lastSessionLabel.text = "Started on: \(formatter.string(from: start))"
        
        titleLabel.textColor = .foreground
        lastSessionLabel.textColor = .foreground3
        
        backgroundColor = .background5
    }
}
