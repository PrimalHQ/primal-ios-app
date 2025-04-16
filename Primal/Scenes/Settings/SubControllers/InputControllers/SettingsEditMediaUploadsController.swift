//
//  SettingsEditMediaUploadsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.4.25..
//

import Combine
import UIKit

final class SettingsEditMediaUploadsController: UIViewController, SettingsController, Themeable {
    private let blossomServerInput = WebConnectInputView()
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
        textField.resignFirstResponder()
        return false
    }
}

private extension SettingsEditMediaUploadsController {
    func sendCompletion() {
        let text = blossomServerInput.input.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.containsEmoji, let url = URL(string: text) else { return }
        
        let alert = UIAlertController(title: "Are you sure?", message: "Do you want to switch to this blossom server?\n\(text)", preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default) { [weak self] _ in
            guard let self else { return }
            navigationController?.popViewController(animated: true)
            completion(text)
        })
        alert.addAction(.init(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func setup() {
        title = "Media Uploads"
        updateTheme()
        
        blossomServerInput.input.placeholder = "enter blossom server url"
        blossomServerInput.input.delegate = self
        blossomServerInput.action.addAction(.init(handler: { [weak self] _ in
            self?.sendCompletion()
        }), for: .touchUpInside)

        let regularConnection = SettingsNetworkStatusView(title: MediaUploadSettings.blossomServer ?? "")
        regularConnection.status = true
        
        let regularConnectionParent = ThemeableView().constrainToSize(height: 44).setTheme { $0.backgroundColor = .background3 }
        regularConnectionParent.addSubview(regularConnection)
        regularConnection.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview()
        regularConnectionParent.layer.cornerRadius = 12
        
        let mirrorConnection = SettingsNetworkStatusView(title: MediaUploadSettings.blossomServer ?? "")
        mirrorConnection.status = true
        
        let mirrorConnectionParent = ThemeableView().constrainToSize(height: 44).setTheme { $0.backgroundColor = .background3 }
        mirrorConnectionParent.addSubview(mirrorConnection)
        mirrorConnection.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview()
        mirrorConnectionParent.layer.cornerRadius = 12
        
        relayStackParent.addSubview(relayStack)
        relayStack.pinToSuperview()
        relayStackParent.layer.cornerRadius = 12
        
        let stack = UIStackView(axis: .vertical, [
            titleView, SpacerView(height: 8),
            blossomServerInput, SpacerView(height: 30),
            titleLabel("Suggested blossom servers"), SpacerView(height: 8),
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
        
        [blossomServerInput].forEach { view in
            view.input.delegate = self
            view.action.addAction(.init(handler: { [weak self] _ in
                guard let self else { return }
                _ = textFieldShouldReturn(view.input.input)
            }), for: .touchUpInside)
        }
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.blossomServerInput.input.resignFirstResponder()
        }))
        
        SocketRequest(name: "get_recommended_blossom_servers", payload: nil).publisher()
            .sink { res in
                print(res.message)
                print(res.events)
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
