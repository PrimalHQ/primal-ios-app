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

final class WalletInfoCell: UITableViewCell, Themeable{
    let balanceConversionView = LargeBalanceConversionView()
    let extraSizeView = UIView()
        
    weak var delegate: WalletInfoCellDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        updateTheme()
        
        let balanceParent = UIView()
        balanceParent.addSubview(balanceConversionView)
        balanceConversionView.pinToSuperview(edges: .bottom).pinToSuperview(edges: .top, padding: -10)
        balanceConversionView.largeAmountLabel.centerToView(balanceParent, axis: .horizontal)
        
        let send = LargeWalletButton(.send)
        let receive = LargeWalletButton(.receive)
        let scan = LargeWalletButton(.scan)
               
        let hstack = UIStackView([send, scan, receive])
        hstack.spacing = 24
        let centerHStack = UIStackView(axis: .vertical, [hstack])
        centerHStack.alignment = .center
        
        let stack = UIStackView(axis: .vertical, [balanceParent, SpacerView(height: 40), centerHStack, SpacerView(height: 18)])
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical)
        
        send.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.sendButtonPressed()
        }), for: .touchUpInside)
        
        receive.addAction(.init(handler: { [weak self] _ in
            self?.delegate?.receiveButtonPressed()
        }), for: .touchUpInside)
        
        scan.addAction(.init(handler: { [weak self] _ in
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
    }
}
