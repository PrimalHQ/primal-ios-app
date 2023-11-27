//
//  SettingsNetworkViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 30.10.23..
//

import Combine
import UIKit

final class SettingsNetworkViewController: UIViewController, Themeable {
    
    private let input = RoundedInputField(placeholder: "wss://")
    private let relayStack = UIStackView(axis: .vertical, [])
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        IdentityManager.instance.requestUserContacts()
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
    }
}

extension SettingsNetworkViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !text.containsEmoji,
            let url = URL(string: text),
            url.scheme == "wss"
        else { return false }
        
        let alert = UIAlertController(title: "Are you sure?", message: "Do you want to add this relay?\n\(text)", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default) { _ in
            FollowManager.instance.addRelay(url: text)
            RelaysPostbox.instance.connect([text])
            
            textField.text = ""
        })
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
        textField.resignFirstResponder()
        return false
    }
}

private extension SettingsNetworkViewController {
    func setup() {
        title = "Network"
        updateTheme()
        
        RelaysPostbox.instance.pool.$connections
            .map { c in c.sorted(by: { $0.identity > $1.identity }) }
            .receive(on: DispatchQueue.main).sink { [weak self] relays in
                guard let self else { return }
                self.relayStack.subviews.forEach { $0.removeFromSuperview() }
                
                let relayViews: [UIView] = relays.map { self.relayConnectionView($0) }
                
                relayViews.forEach { self.relayStack.addArrangedSubview($0) }
            }
            .store(in: &cancellables)
        
        let regularConnection = SettingsNetworkStatusView(title: Connection.regular.socketURL.absoluteString)
        Connection.regular.$isConnected.receive(on: DispatchQueue.main).sink { isConnected in
            regularConnection.status = isConnected
        }
        .store(in: &cancellables)
        
        let restoreParent = UIView()
        let restoreButton = ThemeableButton().setTheme { $0.setTitleColor(.accent, for: .normal) }
        restoreButton.setTitle("restore default relays", for: .normal)
        restoreButton.titleLabel?.font = .appFont(withSize: 18, weight: .medium)
        restoreParent.addSubview(restoreButton)
        restoreButton.pinToSuperview(edges: [.vertical, .trailing])
        
        let stack = UIStackView(axis: .vertical, [
            titleLabel("RELAYS"), SpacerView(height: 20),
            SettingsTitleView(title: "CONNECT TO RELAY"), SpacerView(height: 8),
            input, SpacerView(height: 40),
            SettingsTitleView(title: "MY RELAYS"),
            relayStack, SpacerView(height: 20),
            restoreParent, SpacerView(height: 52),
            titleLabel("CACHING SERVICE"),
            regularConnection
        ])
        
        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        scroll.addSubview(stack)
        stack.pinToSuperview(padding: 24)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48).isActive = true
        
        input.delegate = self
        input.input.returnKeyType = .done
        input.input.autocapitalizationType = .none
        input.input.keyboardType = .URL
        input.input.autocorrectionType = .no
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.input.resignFirstResponder()
        }))
        
        restoreButton.addAction(.init(handler: { [weak self] _ in
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to restore default relays?", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .destructive) { _ in
                FollowManager.instance.resetDefaultRelays()
            })
            alert.addAction(.init(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        }), for: .touchUpInside)
    }
    
    func titleLabel(_ text: String) -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground }
        label.text = text
        label.font = .appFont(withSize: 18, weight: .semibold)
        return label
    }
    
    func relayConnectionView(_ connection: RelayConnection) -> UIView {
        let view = SettingsNetworkStatusListView(title: connection.identity, onDelete: { [weak self] in
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete this relay?\n\(connection.identity)", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .destructive) { _ in
                FollowManager.instance.removeRelay(url: connection.identity)
            })
            alert.addAction(.init(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        })
        connection.state.receive(on: DispatchQueue.main).sink(receiveCompletion: { _ in
            view.status = false
        }, receiveValue: { state in
            view.status = state == .connected
        })
        .store(in: &cancellables)
        return view
    }
}

final class SettingsNetworkStatusListView: SettingsNetworkStatusView {
    init(title: String, onDelete: @escaping () -> Void) {
        super.init(title: title)
        
        let border = ThemeableView().setTheme { $0.backgroundColor = .background3 }
        addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom]).constrainToSize(height: 1)
        
        let deleteButton = UIButton()
        deleteButton.setImage(UIImage(named: "deleteCell"), for: .normal)
        addSubview(deleteButton)
        deleteButton.pinToSuperview(edges: .trailing).centerToSuperview(axis: .vertical)
        
        deleteButton.addAction(.init(handler: { _ in
            onDelete()
        }), for: .touchUpInside)
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
