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
        
    weak var delegate: WalletInfoCellDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        updateTheme()
        
        let balanceParent = UIView()
        balanceParent.addSubview(balanceConversionView)
        balanceConversionView.centerToSuperview(axis: .horizontal).pinToSuperview(edges: .bottom).pinToSuperview(edges: .top, padding: -10)
        
        let send = LargeWalletButton(.send)
        let receive = LargeWalletButton(.receive)
        let scan = LargeWalletButton(.scan)
        let hstack = UIStackView([send, scan, receive])
        hstack.spacing = 8
        
        let stack = UIStackView(axis: .vertical, [balanceParent, SpacerView(height: 40), hstack, SpacerView(height: 18)])
        contentView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical)
        
        WalletManager.instance.$balance.receive(on: DispatchQueue.main).sink { [weak self] balance in
            self?.balanceConversionView.balance = balance
        }
        .store(in: &cancellables)
        
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
