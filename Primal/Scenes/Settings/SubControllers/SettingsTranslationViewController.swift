//
//  SettingsTranslationViewController.swift
//  Primal
//
//  Settings for opt-in note translation (LibreTranslate-compatible endpoint).
//

import UIKit

final class SettingsTranslationViewController: UIViewController, Themeable {

    private let endpointField = UITextField()
    private let apiKeyField = UITextField()
    private let languageField = UITextField()
    private let testStatusLabel = UILabel()
    private let languagesStack = UIStackView()
    private let cacheCountLabel = UILabel()

    private var languages: [SupportedLanguage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsTranslationViewController {

    func setup() {
        title = "Translation"

        let enableSwitch = SettingsSwitchView("Translate notes")
        enableSwitch.switchView.isOn = NoteTranslationPreferences.enabled
        enableSwitch.switchView.addAction(.init(handler: { [weak enableSwitch] _ in
            guard let value = enableSwitch?.switchView.isOn else { return }
            NoteTranslationPreferences.enabled = value
        }), for: .valueChanged)

        configureField(endpointField, placeholder: "https://libretranslate.com", keyboard: .URL)
        endpointField.text = NoteTranslationPreferences.endpoint
        endpointField.addAction(.init(handler: { [weak self] _ in self?.saveEndpoint() }), for: .editingDidEnd)

        configureField(apiKeyField, placeholder: "Optional — only if your endpoint requires one", keyboard: .default)
        apiKeyField.isSecureTextEntry = true
        apiKeyField.autocorrectionType = .no
        apiKeyField.autocapitalizationType = .none
        apiKeyField.text = NoteTranslationPreferences.apiKey
        apiKeyField.addAction(.init(handler: { [weak self] _ in self?.saveApiKey() }), for: .editingDidEnd)

        configureField(languageField, placeholder: "en", keyboard: .default)
        languageField.text = NoteTranslationPreferences.targetLanguage
        languageField.addAction(.init(handler: { [weak self] _ in self?.saveLanguage() }), for: .editingDidEnd)

        let testButton = UIButton(type: .system)
        testButton.setTitle("Test connection", for: .normal)
        testButton.titleLabel?.font = .appFont(withSize: 16, weight: .medium)
        testButton.setTitleColor(.accent2, for: .normal)
        testButton.contentHorizontalAlignment = .leading
        testButton.addAction(.init(handler: { [weak self] _ in self?.testConnection() }), for: .touchUpInside)

        testStatusLabel.font = .appFont(withSize: 14, weight: .regular)
        testStatusLabel.textColor = .foreground3
        testStatusLabel.numberOfLines = 0
        testStatusLabel.text = "Checks the endpoint and loads the languages it supports."

        languagesStack.axis = .vertical
        languagesStack.spacing = 8

        cacheCountLabel.font = .appFont(withSize: 14, weight: .regular)
        cacheCountLabel.textColor = .foreground3
        cacheCountLabel.numberOfLines = 0

        let clearCacheButton = UIButton(type: .system)
        clearCacheButton.setTitle("Clear translation cache", for: .normal)
        clearCacheButton.titleLabel?.font = .appFont(withSize: 16, weight: .medium)
        clearCacheButton.setTitleColor(.accent2, for: .normal)
        clearCacheButton.contentHorizontalAlignment = .leading
        clearCacheButton.addAction(.init(handler: { [weak self] _ in
            NoteTranslationManager.instance.clearCache()
            self?.refreshCacheCount()
        }), for: .touchUpInside)

        let stack = UIStackView(axis: .vertical, [
            enableSwitch, SpacerView(height: 10),
            descLabel("Show a Translate action below notes written in other languages. Notes are only sent to your translation endpoint when you tap Translate."), SpacerView(height: 32),
            fieldTitle("Translation endpoint"), SpacerView(height: 8),
            endpointField, SpacerView(height: 20),
            fieldTitle("API key"), SpacerView(height: 8),
            apiKeyField, SpacerView(height: 20),
            fieldTitle("Translate to (language code)"), SpacerView(height: 8),
            languageField, SpacerView(height: 20),
            testButton, SpacerView(height: 8),
            testStatusLabel, SpacerView(height: 12),
            languagesStack, SpacerView(height: 20),
            cacheCountLabel, SpacerView(height: 8),
            clearCacheButton, SpacerView(height: 32),
            descLabel("Note text is sent to the endpoint you configure above — and nowhere else — only when you tap Translate on a note. Nostr and Lightning identifiers, links and hashtags are masked out before sending and restored in the result. The API key is stored only on this device.")
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

        refreshCacheCount()
        updateTheme()
    }

    func configureField(_ field: UITextField, placeholder: String, keyboard: UIKeyboardType) {
        field.placeholder = placeholder
        field.textColor = .foreground
        field.font = .appFont(withSize: 16, weight: .regular)
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.keyboardType = keyboard
        field.returnKeyType = .done
        field.constrainToSize(height: 44)
    }

    func fieldTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .appFont(withSize: 16, weight: .medium)
        label.textColor = .foreground
        return label
    }

    func descLabel(_ text: String) -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground3 }
        label.text = text
        label.font = .appFont(withSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }

    func saveEndpoint() {
        let normalized = TranslationEndpoints.normalizeEndpoint(endpointField.text ?? "")
        NoteTranslationPreferences.endpoint = normalized
        endpointField.text = normalized
    }

    func saveApiKey() {
        NoteTranslationPreferences.apiKey = (apiKeyField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        // Re-read the stored value: if the Keychain write failed, the field
        // shows what is actually stored instead of the unsaved text.
        apiKeyField.text = NoteTranslationPreferences.apiKey
    }

    func saveLanguage() {
        // Preserve the tag's casing ("zh-Hans", "pt-BR"): endpoints match
        // language codes case-sensitively, and the service sends the tag
        // verbatim.
        let code = (languageField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        NoteTranslationPreferences.targetLanguage = code
        languageField.text = code
        refreshLanguageRows()
    }

    func testConnection() {
        saveEndpoint()
        saveApiKey()
        testStatusLabel.text = "Checking…"
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let languages = try await NoteTranslationManager.instance.listLanguages()
                self.languages = languages
                self.testStatusLabel.text = "Connected. Enter a language code above or tap one below."
                self.refreshLanguageRows()
            } catch let error as TranslationError {
                self.testStatusLabel.text = Self.message(for: error.code)
            } catch {
                self.testStatusLabel.text = "The endpoint returned an error."
            }
        }
    }

    func refreshLanguageRows() {
        languagesStack.arrangedSubviews.forEach {
            languagesStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        let selected = NoteTranslationPreferences.targetLanguage
        for language in languages {
            let button = UIButton(type: .system)
            let isSelected = language.code == selected
            button.setTitle("\(language.name) (\(language.code))\(isSelected ? " ✓" : "")", for: .normal)
            button.titleLabel?.font = .appFont(withSize: 15, weight: isSelected ? .bold : .regular)
            button.setTitleColor(.accent2, for: .normal)
            button.contentHorizontalAlignment = .leading
            button.addAction(.init(handler: { [weak self] _ in
                NoteTranslationPreferences.targetLanguage = language.code
                self?.languageField.text = language.code
                self?.refreshLanguageRows()
            }), for: .touchUpInside)
            languagesStack.addArrangedSubview(button)
        }
    }

    func refreshCacheCount() {
        let count = NoteTranslationManager.instance.cache.count
        cacheCountLabel.text = "\(count) translations cached on this device"
    }

    static func message(for code: TranslationErrorCode) -> String {
        switch code {
        case .notConfigured, .disabled:
            return "Enter an endpoint first."
        case .unreachable:
            return "Couldn't reach the endpoint. Check the URL and your connection."
        case .providerError, .emptyContent:
            return "The endpoint returned an error."
        }
    }
}
