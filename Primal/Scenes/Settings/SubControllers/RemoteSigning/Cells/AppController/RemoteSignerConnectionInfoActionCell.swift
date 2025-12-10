//
//  RemoteSignerConnectionInfoCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 8. 12. 2025..
//

import UIKit
import PrimalShared

protocol RemoteSignerConnectionInfoActionCellDelegate: AnyObject {
    func deleteConnection()
    func editName()
    func startStopSession()
}

final class RemoteSignerConnectionInfoActionCell: UITableViewCell {

    static let reuseID = "RemoteSignerConnectionInfoActionCell"

    private let iconView = UIImageView().constrainToSize(48)
    private let titleLabel = UILabel("", color: .foreground, font: .appFont(withSize: 18, weight: .bold))
    private let lastSessionLabel = UILabel("", color: .foreground3, font: .appFont(withSize: 15, weight: .bold))
    private let startSessionButton = UIButton()
    private let editNameButton = UIButton()
    private let deleteConnectionButton = UIButton()

    private let formatter = DateFormatter()
    
    weak var delegate: RemoteSignerConnectionInfoActionCellDelegate?
    
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
        
        let buttonStack = UIStackView([editNameButton, deleteConnectionButton])
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually
        
        let stack = UIStackView(axis: .vertical, [topStack, startSessionButton.constrainToSize(height: 36), buttonStack.constrainToSize(height: 36)])
        stack.spacing = 16
        contentView.addSubview(stack)
        stack.pinToSuperview(padding: 16)
        
        formatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy h:mm a")
        
        deleteConnectionButton.layer.borderColor = UIColor(rgb: 0xFA3C3C).withAlphaComponent(0.2).cgColor
        deleteConnectionButton.layer.borderWidth = 1
        deleteConnectionButton.layer.cornerRadius = 18
        
        editNameButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.editName()
        }), for: .touchUpInside)
        
        deleteConnectionButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.deleteConnection()
        }), for: .touchUpInside)
        
        startSessionButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.startStopSession()
        }), for: .touchUpInside)
    }

    func configure(connection: AppConnection, lastStart: Date?, isActive: Bool, delegate: RemoteSignerConnectionInfoActionCellDelegate?) {
        self.delegate = delegate
        
        iconView.kf.setImage(with: URL(string: connection.image ?? ""), placeholder: connection.defaultImage(size: 48))
        titleLabel.text = connection.name
        
        if let lastStart {
            let dateString = formatter.string(from: lastStart)
            lastSessionLabel.text = "Last session: \(dateString)"
        } else {
            lastSessionLabel.text = "Last session: Never"
        }
        
        titleLabel.textColor = .foreground
        lastSessionLabel.textColor = .foreground3
        
        startSessionButton.configuration = .pill(text: isActive ? "Stop Session" : "Start Session", foregroundColor: .background5, backgroundColor: .foreground, font: .appFont(withSize: 14, weight: .regular))
        editNameButton.configuration = .pill(text: "Edit Name", foregroundColor: .foreground, backgroundColor: .foreground6, font: .appFont(withSize: 14, weight: .regular))
        deleteConnectionButton.configuration = .pill(text: "Delete Connection", foregroundColor: .init(rgb: 0xFA3C3C), backgroundColor: .init(rgb: 0x1f0404), font: .appFont(withSize: 14, weight: .regular))
        
        backgroundColor = .background5
    }
}
