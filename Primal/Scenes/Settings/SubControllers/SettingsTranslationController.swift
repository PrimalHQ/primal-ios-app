//
//  SettingsTranslationController.swift
//  Primal
//
//  Created by Primal on 15.9.26..
//

import UIKit

final class SettingsTranslationController: UIViewController, SettingsController, Themeable {
    private let providerControl = UISegmentedControl(items: TranslationProvider.allCases.map { $0.shortTitle })
    private let providerInfoLabel = UILabel()

    private let apiKeySectionTitle = SettingsTitleView(title: "API KEY")
    private let apiKeyInput = SettingsTextInputView(placeholder: "API key", secure: true)
    private let apiKeyInfoLabel = UILabel()

    private let serverURLSectionTitle = SettingsTitleView(title: "SERVER URL")
    private let serverURLInput = SettingsTextInputView(placeholder: TranslationAPI.defaultLibreTranslateServer, secure: false)
    private let serverURLInfoLabel = UILabel()

    private let languageButton = SettingsOptionButton(title: "English")

    private let autoTranslateSwitch = SettingsSwitchView("Auto translate notes")

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsTranslationController {
    func setup() {
        title = "Translation"
        updateTheme()

        let currentProvider = TranslationSettings.provider
        providerControl.selectedSegmentIndex = max(0, TranslationProvider.allCases.firstIndex(of: currentProvider) ?? 0)
        providerControl.addAction(.init(handler: { [weak self] _ in
            self?.providerChanged()
        }), for: .valueChanged)

        apiKeyInput.textField.text = TranslationSettings.apiKey(for: currentProvider)
        apiKeyInput.textField.addAction(.init(handler: { [weak self] _ in
            self?.apiKeyEditingEnded()
        }), for: .editingDidEnd)
        apiKeyInput.textField.addAction(.init(handler: { [weak self] _ in
            self?.apiKeyEditingEnded()
            self?.apiKeyInput.textField.resignFirstResponder()
        }), for: .editingDidEndOnExit)

        serverURLInput.textField.text = TranslationSettings.libreTranslateURL
        serverURLInput.textField.addAction(.init(handler: { [weak self] _ in
            self?.serverURLEditingEnded()
        }), for: .editingDidEnd)
        serverURLInput.textField.addAction(.init(handler: { [weak self] _ in
            self?.serverURLEditingEnded()
            self?.serverURLInput.textField.resignFirstResponder()
        }), for: .editingDidEndOnExit)

        autoTranslateSwitch.switchView.isOn = TranslationSettings.autoTranslateNotes
        autoTranslateSwitch.switchView.addAction(.init(handler: { [weak autoTranslateSwitch] _ in
            TranslationSettings.autoTranslateNotes = autoTranslateSwitch?.switchView.isOn ?? false
        }), for: .valueChanged)

        languageButton.addTarget(self, action: #selector(languageButtonTapped), for: .touchUpInside)

        let stack = UIStackView(axis: .vertical, [
            SettingsTitleView(title: "TRANSLATION SERVICE"), SpacerView(height: 8),
            providerControl, SpacerView(height: 12),
            providerInfoLabel, SpacerView(height: 32),

            apiKeySectionTitle, SpacerView(height: 8),
            apiKeyInput, SpacerView(height: 12),
            apiKeyInfoLabel, SpacerView(height: 32),

            serverURLSectionTitle, SpacerView(height: 8),
            serverURLInput, SpacerView(height: 12),
            serverURLInfoLabel, SpacerView(height: 32),

            SettingsTitleView(title: "TRANSLATE TO"), SpacerView(height: 8),
            languageButton, SpacerView(height: 12),
            descLabel("Notes in other languages will be translated into this language. Defaults to your device language."), SpacerView(height: 32),

            autoTranslateSwitch, SpacerView(height: 10),
            descLabel("Automatically translate notes written in a foreign language as you scroll your feeds. You can always translate a single note from its menu."), SpacerView(height: 24)
        ])

        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, padding: 7, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 56, safeArea: true)

        scroll.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical, padding: 38)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48).isActive = true

        [providerInfoLabel, apiKeyInfoLabel, serverURLInfoLabel].forEach {
            $0.font = .appFont(withSize: 14, weight: .regular)
            $0.textColor = .foreground3
            $0.numberOfLines = 0
        }

        serverURLInfoLabel.text = "Defaults to the public LibreTranslate instance. Change this to use your own self-hosted server, for example https://translate.example.com."
        apiKeyInfoLabel.text = "Your API key is stored securely on this device and is only sent to the selected translation provider."

        refreshProviderSections()
        refreshLanguageButton()

        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.apiKeyInput.textField.resignFirstResponder()
            self?.serverURLInput.textField.resignFirstResponder()
        }))
    }

    var currentProvider: TranslationProvider {
        TranslationProvider.allCases[safe: providerControl.selectedSegmentIndex] ?? .google
    }

    func refreshProviderSections() {
        let provider = currentProvider

        providerInfoLabel.text = provider.infoText

        apiKeySectionTitle.isHidden = !provider.requiresAPIKey
        apiKeyInput.isHidden = !provider.requiresAPIKey
        apiKeyInfoLabel.isHidden = !provider.requiresAPIKey

        serverURLSectionTitle.isHidden = !provider.allowsCustomServerURL
        serverURLInput.isHidden = !provider.allowsCustomServerURL
        serverURLInfoLabel.isHidden = !provider.allowsCustomServerURL
    }

    func refreshLanguageButton() {
        let target = TranslationSettings.targetLanguage
        let isDeviceLanguage = target == TranslationManager.deviceLanguageCode && UserDefaults.standard.string(forKey: .translationTargetLanguageKey) == nil
        if let name = TranslationManager.languageName(target) {
            languageButton.label.text = isDeviceLanguage ? "\(name) (Device language)" : name
        } else {
            languageButton.label.text = target.uppercased()
        }
    }

    func providerChanged() {
        let provider = currentProvider
        TranslationSettings.provider = provider
        apiKeyInput.textField.text = TranslationSettings.apiKey(for: provider)
        TranslationManager.instance.clearAutoTranslateBookkeeping()
        refreshProviderSections()
    }

    func apiKeyEditingEnded() {
        let key = (apiKeyInput.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        TranslationSettings.setAPIKey(key, for: currentProvider)
        TranslationManager.instance.clearAutoTranslateBookkeeping()
    }

    func serverURLEditingEnded() {
        let urlString = (serverURLInput.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        TranslationSettings.libreTranslateURL = urlString.isEmpty ? TranslationAPI.defaultLibreTranslateServer : urlString
        TranslationManager.instance.clearAutoTranslateBookkeeping()
    }

    @objc func languageButtonTapped() {
        let alert = UIAlertController(title: "Translate to", message: nil, preferredStyle: .actionSheet)

        let target = TranslationSettings.targetLanguage
        let deviceCode = TranslationManager.deviceLanguageCode

        if TranslationManager.languageName(deviceCode) != nil {
            let deviceAction = UIAlertAction(title: "\(TranslationManager.languageName(deviceCode) ?? deviceCode) (Device language)", style: .default) { [weak self] _ in
                UserDefaults.standard.removeObject(forKey: .translationTargetLanguageKey)
                TranslationManager.instance.clearAutoTranslateBookkeeping()
                self?.refreshLanguageButton()
            }
            if target == deviceCode {
                deviceAction.setValue(true, forKey: "checked")
            }
            alert.addAction(deviceAction)
        }

        for language in TranslationManager.supportedLanguages where language.code != deviceCode {
            let action = UIAlertAction(title: language.name, style: .default) { [weak self] _ in
                TranslationSettings.targetLanguage = language.code
                TranslationManager.instance.clearAutoTranslateBookkeeping()
                self?.refreshLanguageButton()
            }
            if language.code == target {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // Required for iPad presentation.
        if let popover = alert.popoverPresentationController {
            popover.sourceView = languageButton
            popover.sourceRect = languageButton.bounds
        }

        present(alert, animated: true)
    }
}

/// Rounded text input row used in the Translation settings screen.
final class SettingsTextInputView: UIView, Themeable {
    let textField = UITextField()

    init(placeholder: String, secure: Bool) {
        super.init(frame: .zero)

        updateTheme()

        textField.placeholder = placeholder
        textField.font = .appFont(withSize: 16, weight: .regular)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = secure
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done

        addSubview(textField)
        textField.pinToSuperview(edges: .horizontal, padding: 16).centerToSuperview()

        layer.cornerRadius = 12
        constrainToSize(height: 48)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateTheme() {
        backgroundColor = .background3
        textField.textColor = .foreground
        textField.tintColor = .accent2
    }
}
