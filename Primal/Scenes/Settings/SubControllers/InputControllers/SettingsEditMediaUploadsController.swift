//
//  SettingsEditMediaUploadsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.4.25..
//

import Combine
import UIKit

final class SettingsEditMediaUploadsController: UIViewController, SettingsController, Themeable {
    let blossomServerInput = WebConnectInputView()
    private let relayStackParent = UIView()
    private let relayStack = UIStackView(axis: .vertical, [])
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewCancellables: Set<AnyCancellable> = []
    
    let completion: (String) -> Void
    let titleView: UIView
    init(title: String, completion: @escaping (String) -> Void) {
        self.completion = completion
        titleView = SettingsTitleView(title: title)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        blossomServerInput.input.becomeFirstResponder()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
        
        relayStackParent.backgroundColor = .background3
    }
}

extension SettingsEditMediaUploadsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCompletion()
        return false
    }
}

private extension SettingsEditMediaUploadsController {
    func sendCompletion() {
        let text = blossomServerInput.input.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.containsEmoji, text.hasPrefix("https://") else {
            showErrorMessage("Please enter a valid server URL")
            return
        }
        
        blossomServerInput.input.resignFirstResponder()
        navigationController?.popViewController(animated: true)
        completion(text)
    }
    
    func setup() {
        title = "Media Uploads"
        updateTheme()
        
        blossomServerInput.input.delegate = self
        blossomServerInput.action.addAction(.init(handler: { [weak self] _ in
            self?.sendCompletion()
        }), for: .touchUpInside)
        
        relayStackParent.addSubview(relayStack)
        relayStack.pinToSuperview()
        relayStackParent.layer.cornerRadius = 12
        
        let stack = UIStackView(axis: .vertical, [
            titleView, SpacerView(height: 8),
            blossomServerInput, SpacerView(height: 30),
            titleLabel("Suggested media servers"), SpacerView(height: 8),
        ])
        
        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .onDrag
        
        view.addSubview(scroll)
        scroll.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)
        scroll.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor).isActive = true
        let scrollBot = scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -54)
        scrollBot.priority = .defaultHigh
        scrollBot.isActive = true
        scroll.addSubview(stack)
        stack.pinToSuperview(padding: 24)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48).isActive = true
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.blossomServerInput.input.resignFirstResponder()
        }))
        
        let currentServers = BlossomServerManager.instance.serversForUser(pubkey: IdentityManager.instance.userHexPubkey) ?? []
        
        SocketRequest(name: "get_recommended_blossom_servers", payload: nil).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                guard
                    let event = res.events.first(where: { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.blossomSuggestions.rawValue }),
                    let suggested: [String] = event["content"]?.stringValue?.decode()
                else { return }
                
                for server in suggested.filter({ !currentServers.contains($0) }) {
                    let view = SuggestedServerView(title: server)
                    stack.addArrangedSubview(view)
                    view.addGestureRecognizer(BindableTapGestureRecognizer(action: {
                        self?.completion(server)
                        self?.navigationController?.popViewController(animated: true)
                    }))
                }
            }
            .store(in: &cancellables)
    }
    
    func titleLabel(_ text: String) -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground }
        label.text = text
        label.font = .appFont(withSize: 18, weight: .semibold)
        return label
    }
}

class SuggestedServerView: UIStackView {
    init(title: String) {
        super.init(frame: .zero)
        
        let greenDot = SpacerView(width: 10, height: 10, color: .init(rgb: 0x66E205))
        let copyImage = UIImageView(image: .setLink)
        
        [greenDot, UILabel(title, color: .foreground3, font: .appFont(withSize: 16, weight: .regular)), copyImage]
            .forEach { addArrangedSubview($0) }
        
        spacing = 12
        alignment = .center
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 16, left: 0, bottom: 16, right: 0)
        
        greenDot.layer.cornerRadius = 5
        copyImage.tintColor = .accent
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
