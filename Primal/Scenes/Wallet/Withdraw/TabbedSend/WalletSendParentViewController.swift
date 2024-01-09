//
//  WalletSendParentViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.12.23..
//

import Combine
import UIKit

final class WalletSendParentViewController: UIViewController {
    enum Tab {
        case nostr
        case scan
        case keyboard
    }
    
    private let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    private let nostrButton = WalletSendTabButton(icon: UIImage(named: "walletTabNostr"))
    private let scanButton = WalletSendTabButton(icon: UIImage(named: "walletTabScan"))
    private let keyboardButton = WalletSendTabButton(icon: UIImage(named: "walletTabKeyboard"))
    
    lazy var pickVC = WalletPickUserController()
    lazy var scanVC = WalletQRCodeViewController()
    lazy var keyboardVC = WalletKeyboardTabController()
    
    private var activeButton: WalletSendTabButton? {
        didSet {
            oldValue?.isActive = false
            activeButton?.isActive = true
        }
    }
    
    private var oldTab: Tab?
    private var textSearch: String?
    private var cancellables: Set<AnyCancellable> = []
    
    init(startingTab tab: Tab) {
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
        set(tab, animated: false)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.viewControllers.remove(object: self)
    }
    
    func set(_ tab: Tab, animated: Bool = true) {
        guard oldTab != tab else { return }
        
        switch tab {
        case .nostr:
            title = "Nostr Recipient"
            pageController.setViewControllers([pickVC], direction: .reverse, animated: animated)
            activeButton = nostrButton
        case .scan:
            title = "Scan"
            pageController.setViewControllers([scanVC], direction: oldTab == .nostr ? .forward : .reverse, animated: animated)
            activeButton = scanButton
        case .keyboard:
            title = "Keyboard"
            pageController.setViewControllers([keyboardVC], direction: .forward, animated: animated)
            activeButton = keyboardButton
        }
        oldTab = tab
    }
    
    func search(_ text: String) {
        guard textSearch == nil else { return }
        
        // Remove "nostr:"
        let text = text.components(separatedBy: ":").last ?? text
        
        if text.isEmail {
            navigationController?.pushViewController(WalletSendAmountController(.address(text, nil, nil)), animated: true)
            return
        }
        
        if text.hasPrefix("npub") {
            if let decoded = try? bech32_decode(text) {
                self.searchForPubkey(hex_encode(decoded.data)) { [weak self] user in
                    guard let user else { return }
                    self?.navigationController?.pushViewController(WalletSendAmountController(.user(user)), animated: true)
                }
            }
            return
        }
        
        textSearch = text
        
        PrimalWalletRequest(type: .parseLNURL(text)).publisher().receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                if result.message != nil {
                    self.searchForPubkey(text) { [weak self] user in
                        self?.textSearch = nil
                        guard let user else { return }
                        self?.navigationController?.pushViewController(WalletSendAmountController(.user(user)), animated: true)
                    }
                    return
                }
                
                guard let pubkey: String = result.parsedLNURL?.target_pubkey ?? result.parsedLNInvoice?.pubkey else {
                    if let invoice = result.parsedLNInvoice {
                        navigationController?.pushViewController(WalletSendViewController(.address(text, invoice, nil)), animated: true)
                    } else {
                        navigationController?.pushViewController(WalletSendAmountController(.address(text, nil, nil)), animated: true)
                    }
                    return
                }
            
                searchForPubkey(pubkey) { [weak self] user in
                    if let invoice = result.parsedLNInvoice {
                        self?.navigationController?.pushViewController(WalletSendViewController(.address(text, invoice, user)), animated: true)
                    } else {
                        self?.navigationController?.pushViewController(WalletSendAmountController(.address(text, nil, user)), animated: true)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func searchForPubkey(_ pubkey: String, callback: @escaping (ParsedUser?) -> Void) {
        SocketRequest(name: "user_infos", payload: .object(["pubkeys": [.string(pubkey)]])).publisher()
            .receive(on: DispatchQueue.main)
            .sink { userRes in
                guard let simpUser = userRes.users[pubkey] else {
                    callback(nil)
                    return
                }
                
                callback(userRes.createParsedUser(simpUser))
                
            }
            .store(in: &cancellables)
    }
    
    func searchForPubkeyAndSendUser(_ pubkey: String) {
        
    }
}

private extension WalletSendParentViewController {
    func setup() {
        let tabBackground = UIView()
        tabBackground.backgroundColor = .background
        let buttonStack = UIStackView([nostrButton, scanButton, keyboardButton])
        buttonStack.distribution = .equalSpacing
        
        tabBackground.addSubview(buttonStack)
        buttonStack.pinToSuperview(edges: .top, padding: 16).centerToSuperview(axis: .horizontal)
        buttonStack.widthAnchor.constraint(equalTo: tabBackground.widthAnchor, multiplier: 0.25, constant: 56 * 3).isActive = true
        
        let stack = UIStackView(axis: .vertical, [pageController.view, tabBackground])
        
        addChild(pageController)
        view.addSubview(stack)
        stack.pinToSuperview()
        pageController.didMove(toParent: self)
        
        tabBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -88).isActive = true
        
        let tabBorder = SpacerView(height: 1, color: .background3)
        tabBackground.addSubview(tabBorder)
        tabBorder.pinToSuperview(edges: [.top, .horizontal])
        
        navigationItem.leftBarButtonItem = customBackButton
        
        nostrButton.addAction(.init(handler: { [weak self] _ in
            self?.set(.nostr)
        }), for: .touchUpInside)
        scanButton.addAction(.init(handler: { [weak self] _ in
            self?.set(.scan)
        }), for: .touchUpInside)
        keyboardButton.addAction(.init(handler: { [weak self] _ in
            self?.set(.keyboard)
        }), for: .touchUpInside)
    }
    
    func callback(text: String, amount: ParsedLNInvoice, user: ParsedUser?) {
    }
}

final class WalletSendTabButton: MyButton {
    var isActive: Bool = false {
        didSet {
            setColor()
        }
    }
    
    override var isPressed: Bool {
        didSet {
            setColor()
        }
    }
    
    private let iconView = UIImageView()
    init(icon: UIImage?) {
        super.init(frame: .zero)
        iconView.image = icon
        
        addSubview(iconView)
        iconView.centerToSuperview()
        
        constrainToSize(56)
        layer.cornerRadius = 28
        
        setColor()
    }
    
    func setColor() {
        guard isActive || isPressed else {
            iconView.tintColor = .foreground3
            backgroundColor = .background3
            return
        }
        iconView.tintColor = .background
        backgroundColor = .foreground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
