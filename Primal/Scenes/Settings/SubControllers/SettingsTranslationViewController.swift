//
//  SettingsTranslationViewController.swift
//  Primal
//
//  Created for Primal iOS app — translation settings screen
//

import UIKit

final class SettingsTranslationViewController: UIViewController, Themeable {
    private let enabledSwitch = SettingsSwitchView(NSLocalizedString("Enable note translation", comment: "Settings toggle: enable translation"))
    private let endpointField = UITextField()
    private let apiKeyField = UITextField()
    private let languageField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
    }
}

// MARK: - Setup

private extension SettingsTranslationViewController {
    func setup() {
        title = NSLocalizedString("Note Translation", comment: "Settings title")

        let endpointTitle = SettingsTitleViewVibrant(title: NSLocalizedString("TRANSLATION ENDPOINT", comment: "Settings section title"))
        let endpointFieldContainer = createFieldContainer(endpointField)
        endpointField.placeholder = NSLocalizedString("https://libretranslate.com/translate", comment: "Endpoint placeholder")
        endpointField.text = NoteTranslationSettings.endpointURL.absoluteString
        endpointField.autocapitalizationType = .none
        endpointField.autocorrectionType = .no
        endpointField.keyboardType = .URL
        endpointField.addAction(.init(handler: { [weak self] _ in
            if let text = self?.endpointField.text, let url = URL(string: text) {
                NoteTranslationSettings.endpointURL = url
            }
        }), for: .editingDidEnd)

        let endpointDesc = descLabel(
            NSLocalizedString("A LibreTranslate-compatible endpoint URL. Defaults to libretranslate.com. Self-hosted instances are recommended for privacy.", comment: "Settings description")
        )

        let apiKeyTitle = SettingsTitleViewVibrant(title: NSLocalizedString("API KEY (optional)", comment: "Settings section title"))
        let apiKeyContainer = createFieldContainer(apiKeyField)
        apiKeyField.placeholder = NSLocalizedString("Optional API key", comment: "API key placeholder")
        apiKeyField.text = NoteTranslationSettings.apiKey.isEmpty ? nil : NoteTranslationSettings.apiKey
        apiKeyField.autocapitalizationType = .none
        apiKeyField.autocorrectionType = .no
        apiKeyField.isSecureTextEntry = true
        apiKeyField.addAction(.init(handler: { [weak self] _ in
            NoteTranslationSettings.apiKey = self?.apiKeyField.text ?? ""
        }), for: .editingDidEnd)

        let apiKeyDesc = descLabel(
            NSLocalizedString("Required if your endpoint requires authentication. Leave empty for public instances.", comment: "Settings description")
        )

        let langTitle = SettingsTitleViewVibrant(title: NSLocalizedString("TARGET LANGUAGE", comment: "Settings section title"))
        let langContainer = createFieldContainer(languageField)
        languageField.placeholder = NSLocalizedString("e.g. en, zh, es, fr, de", comment: "Language code placeholder")
        languageField.text = NoteTranslationSettings.targetLanguage
        languageField.autocapitalizationType = .none
        languageField.autocorrectionType = .no
        languageField.addAction(.init(handler: { [weak self] _ in
            if let text = self?.languageField.text, !text.isEmpty {
                NoteTranslationSettings.targetLanguage = text
            }
        }), for: .editingDidEnd)

        let langDesc = descLabel(
            NSLocalizedString("ISO 639-1 language code (e.g. en, zh, es). Defaults to your device language.", comment: "Settings description")
        )

        // Wire up the enabled switch
        enabledSwitch.switchView.isOn = NoteTranslationSettings.isEnabled
        enabledSwitch.switchView.addAction(.init(handler: { [weak self] _ in
            guard let value = self?.enabledSwitch.switchView.isOn else { return }
            NoteTranslationSettings.isEnabled = value
        }), for: .valueChanged)

        let stack = UIStackView(axis: .vertical, [
            enabledSwitch, SpacerView(height: 10),
            endpointTitle, SpacerView(height: 12),
            endpointFieldContainer, SpacerView(height: 6),
            endpointDesc, SpacerView(height: 24),
            apiKeyTitle, SpacerView(height: 12),
            apiKeyContainer, SpacerView(height: 6),
            apiKeyDesc, SpacerView(height: 24),
            langTitle, SpacerView(height: 12),
            langContainer, SpacerView(height: 6),
            langDesc, SpacerView(height: 32)
        ])

        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
            .pinToSuperview(edges: .top, padding: 7, safeArea: true)

        scroll.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 38)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true

        updateTheme()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    func createFieldContainer(_ field: UITextField) -> UIView {
        let container = ThemeableView().constrainToSize(height: 48)
        container.setTheme { $0.backgroundColor = .background3 }
        container.layer.cornerRadius = 24
        container.addSubview(field)
        field.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()
        field.font = .appFont(withSize: 16, weight: .regular)
        field.textColor = .foreground
        return container
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
