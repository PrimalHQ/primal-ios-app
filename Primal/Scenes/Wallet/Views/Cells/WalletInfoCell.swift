//
//  WalletInfoCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 10.10.23..
//

import Combine
import UIKit

protocol WalletInfoCellDelegate: AnyObject {
    func sendButtonPressed()
    func receiveButtonPressed()
    func scanButtonPressed()
}

final class WalletInfoLargeView: UIView {
    let balanceConversionView = LargeBalanceConversionView()
    let extraSizeView = UIView()
    
    let send = LargeWalletButton(.send)
    let receive = LargeWalletButton(.receive)
    let scan = LargeWalletButton(.scan)
    
    lazy var actionStack = UIStackView([send, scan, receive])
           
    init() {
        super.init(frame: .zero)
        
        let balanceParent = UIView()
        balanceParent.addSubview(balanceConversionView)
        balanceConversionView.pinToSuperview()
        balanceConversionView.largeAmountLabel.centerToView(balanceParent, axis: .horizontal)
        balanceConversionView.roundingStyle = .twoDecimals
        
        actionStack.spacing = 24
        let centerHStack = UIStackView(axis: .vertical, [actionStack])
        centerHStack.alignment = .center
        
        let stack = UIStackView(axis: .vertical, [balanceParent, SpacerView(height: 60), centerHStack])
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 0).pinToSuperview(edges: .top, padding: 40).pinToSuperview(edges: .bottom, padding: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class WalletInfoCell: UITableViewCell, Themeable {
    let view = WalletInfoLargeView()
        
    weak var delegate: WalletInfoCellDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        updateTheme()
        
        contentView.addSubview(view)
        view.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 15)
        
        view.send.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.sendButtonPressed()
        }), for: .touchUpInside)
        
        view.receive.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.receiveButtonPressed()
        }), for: .touchUpInside)
        
        view.scan.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.scanButtonPressed()
        }), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background
        let themable: [Themeable] = view.findAllSubviews()
        themable.forEach { $0.updateTheme() }
    }
}
