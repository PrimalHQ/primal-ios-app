//
//  SettingsTranslationViewController.swift
//  Primal
//
//  Settings for inline note translation (LibreTranslate endpoint, API key, target language).
//

import UIKit

final class SettingsTranslationViewController: UIViewController, Themeable {
    private let enabledSwitch = SettingsSwitchView("Enable note translation")
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
        endpointField.textColor = .foreground
        apiKeyField.textColor = .foreground
        languageField.textColor = .foreground
    }
}

private extension SettingsTranslationViewController {
    func setup() {
        title = "Note Translation"

        let endpointTitle = SettingsTitleViewVibrant(title: "TRANSLATION ENDPOINT")
        let endpointFieldContainer = createFieldContainer(endpointField)
        endpointField.placeholder = "https://libretranslate.com"
        endpointField.text = NoteTranslationSettings.endpointURL.absoluteString
        endpointField.autocapitalizationType = .none
        endpointField.autocorrectionType = .no
        endpointField.keyboardType = .URL
        endpointField.returnKeyType = .done
        endpointField.addAction(.init(handler: { [weak self] _ in
            self?.persistEndpoint()
        }), for: .editingDidEnd)

        let endpointDesc = descLabel(
            "LibreTranslate base URL or full /translate path. Defaults to libretranslate.com. Self-hosted instances are recommended for privacy."
        )

        let apiKeyTitle = SettingsTitleViewVibrant(title: "API KEY (OPTIONAL)")
        let apiKeyContainer = createFieldContainer(apiKeyField)
        apiKeyField.placeholder = "Optional API key"
        apiKeyField.text = NoteTranslationSettings.apiKey.isEmpty ? nil : NoteTranslationSettings.apiKey
        apiKeyField.autocapitalizationType = .none
        apiKeyField.autocorrectionType = .no
        apiKeyField.isSecureTextEntry = true
        apiKeyField.returnKeyType = .done
        apiKeyField.addAction(.init(handler: { [weak self] _ in
            NoteTranslationSettings.apiKey = self?.apiKeyField.text ?? ""
        }), for: .editingDidEnd)

        let apiKeyDesc = descLabel(
            "Required if your endpoint requires authentication. Leave empty for public instances."
        )

        let langTitle = SettingsTitleViewVibrant(title: "TARGET LANGUAGE")
        let langContainer = createFieldContainer(languageField)
        languageField.placeholder = "e.g. en, zh, es, fr, de"
        languageField.text = NoteTranslationSettings.targetLanguage
        languageField.autocapitalizationType = .none
        languageField.autocorrectionType = .no
        languageField.returnKeyType = .done
        languageField.addAction(.init(handler: { [weak self] _ in
            guard let text = self?.languageField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { return }
            // Normalize BCP-47 to ISO 639-1 when possible (en-US -> en).
            let code = NoteTranslationSettings.primaryLanguageCode(text)
            NoteTranslationSettings.targetLanguage = code
            self?.languageField.text = code
        }), for: .editingDidEnd)

        let langDesc = descLabel(
            "ISO 639-1 language code (e.g. en, zh, es). Defaults to your device language."
        )

        enabledSwitch.switchView.isOn = NoteTranslationSettings.isEnabled
        enabledSwitch.switchView.addAction(.init(handler: { [weak self] _ in
            guard let value = self?.enabledSwitch.switchView.isOn else { return }
            NoteTranslationSettings.isEnabled = value
        }), for: .valueChanged)

        let stack = UIStackView(axis: .vertical, [
            enabledSwitch, SpacerView(height: 10),
            descLabel("Show a Translate control under notes and translate via LibreTranslate while protecting nostr identifiers, invoices, and addresses."), SpacerView(height: 24),
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
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func createFieldContainer(_ field: UITextField) -> UIView {
        let container = ThemeableView().constrainToSize(height: 48)
        container.setTheme { $0.backgroundColor = .background3 }
        container.layer.cornerRadius = 12
        container.addSubview(field)
        field.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()
        field.font = .appFont(withSize: 16, weight: .regular)
        field.textColor = .foreground
        return container
    }

    func descLabel(_ text: String) -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
        label.text = text
        label.font = .appFont(withSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }

    func persistEndpoint() {
        guard let text = endpointField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty,
              let url = URL(string: text),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http" else {
            endpointField.text = NoteTranslationSettings.endpointURL.absoluteString
            return
        }
        NoteTranslationSettings.endpointURL = url
        endpointField.text = url.absoluteString
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
