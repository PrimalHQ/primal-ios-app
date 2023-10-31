//
//  SettingsNetworkViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30.10.23..
//

import Combine
import UIKit

final class SettingsNetworkViewController: UIViewController, Themeable {
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
    }
}

private extension SettingsNetworkViewController {
    func setup() {
        title = "Network"
        updateTheme()
        
        var relayStack = UIStackView(axis: .vertical, [])
        
        let relays = RelaysPostbox.instance.pool.connections.sorted(by: { $0.identity > $1.identity })
        
        RelaysPostbox.instance.pool.$connections
            .map { c in c.sorted(by: { $0.identity > $1.identity }) }
            .receive(on: DispatchQueue.main).sink { [weak self] relays in
                guard let self else { return }
                relayStack.subviews.forEach { $0.removeFromSuperview() }
                
                let relayViews: [UIView] = relays.map { connection in
                    let view = SettingsNetworkStatusListView(title: connection.identity)
                    connection.state.receive(on: DispatchQueue.main).sink(receiveCompletion: { _ in }, receiveValue: { state in
                        view.status = state == .connected
                    })
                    .store(in: &self.cancellables)
                    return view
                }
                
                relayViews.forEach { relayStack.addArrangedSubview($0) }
            }
            .store(in: &cancellables)
        
        let connection = SettingsNetworkStatusView(title: Connection.instance.socketURL.absoluteString)
        Connection.instance.$isConnected.receive(on: DispatchQueue.main).sink { isConnected in
            connection.status = isConnected
        }
        .store(in: &cancellables)
        
        let stack = UIStackView(axis: .vertical, [
            SettingsTitleView(title: "MY RELAYS"),
            relayStack, SpacerView(height: 40),
            SettingsTitleView(title: "CACHING SERVICE"),
            connection
        ])
        
        
        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.pinToSuperview(edges: [.horizontal, .bottom]).pinToSuperview(edges: .top, safeArea: true)
        scroll.addSubview(stack)
        stack.pinToSuperview(padding: 24)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48).isActive = true
    }
}

final class SettingsNetworkStatusListView: SettingsNetworkStatusView {
    override init(title: String) {
        super.init(title: title)
        
        let border = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom]).constrainToSize(height: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SettingsNetworkStatusView: UIView, Themeable {
    private let statusView = UIView().constrainToSize(10)
    private let nameLabel = UILabel()
    
    var status = true {
        didSet {
            statusView.backgroundColor = status ? UIColor(rgb: 0x66E205) : UIColor(rgb: 0xE20505)
        }
    }
    
    var title: String {
        get { nameLabel.text ?? "" }
        set { nameLabel.text = newValue }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        let stack = UIStackView([statusView, nameLabel])
        stack.alignment = .center
        stack.spacing = 14
        
        addSubview(stack)
        stack.pinToSuperview()
        
        statusView.backgroundColor = UIColor(rgb: 0x66E205)
        statusView.layer.cornerRadius = 5
        
        nameLabel.text = title
        nameLabel.font = .appFont(withSize: 16, weight: .regular)
        
        updateTheme()
        constrainToSize(height: 44)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        nameLabel.textColor = .foreground
    }
}
