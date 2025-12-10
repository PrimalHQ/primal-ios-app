//
//  RemoteSignerConnectionTrustCell.swift
//  Primal
//
//  Created by [Your Name] on [Today’s Date].
//

import UIKit
import PrimalShared

protocol RemoteSignerConnectionTrustCellDelegate: AnyObject {
    func trustSelected(_ trustLevel: TrustLevel)
}

final class RemoteSignerConnectionTrustCell: UITableViewCell {
    
    static let reuseID = "RemoteSignerConnectionTrustCell"
    
    private var trustButton: TrustSelectionButton?
    
    weak var delegate: RemoteSignerConnectionTrustCellDelegate?
    
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
        separatorInset = .init(top: 0, left: 800, bottom: 0, right: 0)
        backgroundColor = .clear
    }
    
    func configure(trustLevel: AppSignTrustLevel, connection: AppConnection, delegate: RemoteSignerConnectionTrustCellDelegate?) {
        self.delegate = delegate
        trustButton?.removeFromSuperview()
        
        let newButton = TrustSelectionButton(trustLevel: trustLevel)
        contentView.addSubview(newButton)
        newButton.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical, padding: 6)
        
        newButton.isSelected = connection.trustLevel == trustLevel.trustLevel
        
        newButton.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.trustSelected(trustLevel.trustLevel)
        }), for: .touchUpInside)
    }
}

extension TrustLevel {
    var appLevel: AppSignTrustLevel {
        switch self {
        case .full:     return .full
        case .medium:   return .medium
        case .low:      return .low
        }
    }
}
