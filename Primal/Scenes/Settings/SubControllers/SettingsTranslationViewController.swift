//
//  SettingsTranslationViewController.swift
//  Primal
//

import UIKit

final class SettingsTranslationViewController: UIViewController, Themeable, SettingsController {
    private var prefs = NoteTranslationPrefsStore.read()
    private let enabledSwitch = SettingsSwitchView("Show Translate on notes")
    private let targetField = UITextField()
    private let libreField = UITextField()
    private let apiKeyField = UITextField()
    private let providerStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        updateTheme()
    }

    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        [targetField, libreField, apiKeyField].forEach {
            $0.textColor = .foreground
            $0.backgroundColor = .background3
        }
    }

    private func setup() {
        title = "Translation"

        enabledSwitch.switchView.isOn = prefs.enabled
        enabledSwitch.switchView.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.prefs.enabled = self.enabledSwitch.switchView.isOn
            NoteTranslationPrefsStore.write(self.prefs)
        }), for: .valueChanged)

        NoteTranslationProvider.allCases.forEach { provider in
            let button = UIButton(type: .system)
            button.setTitle(provider.rawValue, for: .normal)
            button.tag = NoteTranslationProvider.allCases.firstIndex(of: provider) ?? 0
            button.addAction(.init(handler: { [weak self] action in
                guard let self, let button = action.sender as? UIButton else { return }
                let provider = NoteTranslationProvider.allCases[button.tag]
                self.prefs.provider = provider
                NoteTranslationPrefsStore.write(self.prefs)
                self.refreshProviderButtons()
            }), for: .touchUpInside)
            providerStack.addArrangedSubview(button)
        }
        providerStack.axis = .vertical
        providerStack.spacing = 4
        refreshProviderButtons()

        configureField(targetField, placeholder: "Target language code", text: prefs.targetLang) { [weak self] text in
            self?.prefs.targetLang = text
            if let prefs = self?.prefs { NoteTranslationPrefsStore.write(prefs) }
        }
        configureField(libreField, placeholder: "LibreTranslate base URL", text: prefs.libreBaseUrl) { [weak self] text in
            self?.prefs.libreBaseUrl = text
            if let prefs = self?.prefs { NoteTranslationPrefsStore.write(prefs) }
        }
        configureField(apiKeyField, placeholder: "API key (required for Google/DeepL)", text: prefs.apiKey) { [weak self] text in
            self?.prefs.apiKey = text
            if let prefs = self?.prefs { NoteTranslationPrefsStore.write(prefs) }
        }
        apiKeyField.isSecureTextEntry = true

        let stack = UIStackView(axis: .vertical, [
            enabledSwitch, SpacerView(height: 10),
            descLabel("Configure on-demand translation of notes. Google and DeepL require your own API key."), SpacerView(height: 20),
            SettingsTitleView(title: "PROVIDER"), SpacerView(height: 8),
            providerStack, SpacerView(height: 20),
            targetField, SpacerView(height: 12),
            libreField, SpacerView(height: 12),
            apiKeyField
        ])

        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
            .pinToSuperview(edges: .top, padding: 7, safeArea: true)
        scroll.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 24)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true
    }

    private func refreshProviderButtons() {
        for (idx, view) in providerStack.arrangedSubviews.enumerated() {
            guard let button = view as? UIButton else { continue }
            let provider = NoteTranslationProvider.allCases[idx]
            let selected = provider == prefs.provider
            button.setTitle(selected ? "✓ \(provider.rawValue)" : provider.rawValue, for: .normal)
            button.setTitleColor(selected ? .accent : .foreground3, for: .normal)
        }
    }

    private func configureField(_ field: UITextField, placeholder: String, text: String, onChange: @escaping (String) -> Void) {
        field.placeholder = placeholder
        field.text = text
        field.borderStyle = .roundedRect
        field.font = .appFont(withSize: 16, weight: .regular)
        field.addAction(.init(handler: { action in
            guard let field = action.sender as? UITextField else { return }
            onChange(field.text ?? "")
        }), for: .editingChanged)
        field.constrainToSize(height: 44)
    }
}
