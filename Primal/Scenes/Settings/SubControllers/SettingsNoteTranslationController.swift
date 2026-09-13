//
//  SettingsNoteTranslationController.swift
//  Primal
//
//  Configure client-side note translation. Users bring their own provider.
//

import UIKit

final class SettingsNoteTranslationController: UIViewController, SettingsController, Themeable {
    private let enabledSwitch = SettingsSwitchView("Enable note translation")
    private let autoSwitch = SettingsSwitchView("Auto-translate foreign notes")
    private let providerRow = SettingsInfoView(name: "Provider", desc: "", showArrow: true)
    private let languageRow = SettingsInfoView(name: "Translate into", desc: "", showArrow: true)
    private let endpointField = RoundedInputField(placeholder: "https://your-libretranslate.example")
    private let apiKeyField = RoundedInputField(placeholder: "API key (optional)")
    private let statusLabel = UILabel()
    private let endpointTitle = SettingsTitleView(title: "SERVER URL")
    private let apiKeyTitle = SettingsTitleView(title: "API KEY")

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        reloadFromPreferences()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadFromPreferences()
    }

    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        statusLabel.textColor = .foreground3
        endpointField.updateTheme()
        apiKeyField.updateTheme()
    }
}

private extension SettingsNoteTranslationController {
    func setup() {
        title = "Note Translation"
        view.accessibilityIdentifier = "noteTranslationSettingsScreen"

        statusLabel.font = .appFont(withSize: 14, weight: .regular)
        statusLabel.numberOfLines = 0

        endpointField.input.autocapitalizationType = .none
        endpointField.input.autocorrectionType = .no
        endpointField.input.keyboardType = .URL
        endpointField.input.returnKeyType = .done
        endpointField.input.addAction(.init(handler: { [weak self] _ in
            self?.persistFields()
        }), for: .editingChanged)
        endpointField.input.addAction(.init(handler: { [weak self] _ in
            self?.persistFields()
            self?.endpointField.resignFirstResponder()
        }), for: .editingDidEndOnExit)

        apiKeyField.input.autocapitalizationType = .none
        apiKeyField.input.autocorrectionType = .no
        apiKeyField.input.isSecureTextEntry = true
        apiKeyField.input.returnKeyType = .done
        apiKeyField.input.addAction(.init(handler: { [weak self] _ in
            self?.persistFields()
        }), for: .editingChanged)
        apiKeyField.input.addAction(.init(handler: { [weak self] _ in
            self?.persistFields()
            self?.apiKeyField.resignFirstResponder()
        }), for: .editingDidEndOnExit)

        enabledSwitch.switchView.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            NoteTranslationPreferences.isEnabled = self.enabledSwitch.switchView.isOn
            self.refreshStatus()
        }), for: .valueChanged)

        autoSwitch.switchView.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            NoteTranslationPreferences.autoTranslate = self.autoSwitch.switchView.isOn
        }), for: .valueChanged)

        providerRow.addAction(.init(handler: { [weak self] _ in
            self?.presentProviderPicker()
        }), for: .touchUpInside)

        languageRow.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsNoteTranslationLanguageController(), sender: nil)
        }), for: .touchUpInside)

        let stack = UIStackView(axis: .vertical, [
            enabledSwitch, SpacerView(height: 10),
            descLabel("Translate kind-1 notes into your preferred language. Primal does not pay for a translation API — you point at your own LibreTranslate instance or supply your own DeepL / Google Cloud key."),
            SpacerView(height: 24),
            autoSwitch, SpacerView(height: 10),
            descLabel("When enabled, foreign-language notes start translating as they appear. Uses your configured provider."),
            SpacerView(height: 24),
            SettingsTitleView(title: "PROVIDER"), SpacerView(height: 8),
            providerRow, SpacerView(height: 16),
            SettingsTitleView(title: "LANGUAGE"), SpacerView(height: 8),
            languageRow, SpacerView(height: 24),
            endpointTitle, SpacerView(height: 8),
            endpointField, SpacerView(height: 16),
            apiKeyTitle, SpacerView(height: 8),
            apiKeyField, SpacerView(height: 16),
            statusLabel
        ])

        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .onDrag
        view.addSubview(scroll)
        scroll
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 56, safeArea: true)

        scroll.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 24)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40).isActive = true

        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.view.endEditing(true)
        }))

        updateTheme()
    }

    func reloadFromPreferences() {
        enabledSwitch.switchView.isOn = NoteTranslationPreferences.isEnabled
        autoSwitch.switchView.isOn = NoteTranslationPreferences.autoTranslate
        providerRow.descLabel.text = NoteTranslationPreferences.provider.title
        languageRow.descLabel.text = NoteTranslationPreferences.targetLanguageDisplayName
        endpointField.text = NoteTranslationPreferences.endpointText
        apiKeyField.text = NoteTranslationPreferences.apiKey
        applyProviderChrome()
        refreshStatus()
    }

    func persistFields() {
        NoteTranslationPreferences.endpointText = endpointField.text
        NoteTranslationPreferences.apiKey = apiKeyField.text
        refreshStatus()
    }

    func applyProviderChrome() {
        let provider = NoteTranslationPreferences.provider
        switch provider {
        case .libreTranslate:
            endpointTitle.isHidden = false
            endpointField.isHidden = false
            endpointField.placeholder = "https://your-libretranslate.example"
            apiKeyTitle.isHidden = false
            apiKeyField.isHidden = false
            apiKeyField.placeholder = "API key (optional)"
        case .deepL:
            endpointTitle.isHidden = false
            endpointField.isHidden = false
            endpointField.placeholder = "https://api-free.deepl.com/v2/translate"
            apiKeyTitle.isHidden = false
            apiKeyField.isHidden = false
            apiKeyField.placeholder = "DeepL API key"
        case .googleCloud:
            endpointTitle.isHidden = false
            endpointField.isHidden = false
            endpointField.placeholder = "Leave blank for Google’s default URL"
            apiKeyTitle.isHidden = false
            apiKeyField.isHidden = false
            apiKeyField.placeholder = "Google Cloud API key"
        }
    }

    func refreshStatus() {
        if !NoteTranslationPreferences.isEnabled {
            statusLabel.text = "Translation is off. Notes will not show a Translate control."
            return
        }

        switch NoteTranslationPreferences.readiness(
            provider: NoteTranslationPreferences.provider,
            endpointText: NoteTranslationPreferences.endpointText,
            apiKey: NoteTranslationPreferences.apiKey
        ) {
        case .ready:
            statusLabel.text = "Ready. Foreign-language notes will show Translate. Nothing is sent until you tap it (unless auto-translate is on)."
        case .missingEndpoint:
            statusLabel.text = "Add a LibreTranslate URL to enable translation. There is no default public server."
        case .invalidEndpoint:
            statusLabel.text = "That server URL is not allowed. Use https, or http only for localhost / private LAN addresses."
        case .missingAPIKey:
            statusLabel.text = "Add your \(NoteTranslationPreferences.provider.title) API key. Translation stays disabled until one is saved."
        case .disabled:
            statusLabel.text = "Translation is off."
        }
    }

    func presentProviderPicker() {
        let alert = UIAlertController(title: "Translation provider", message: "Primal never ships a paid default. Use your own instance or key.", preferredStyle: .actionSheet)
        for provider in NoteTranslationProvider.allCases {
            alert.addAction(.init(title: provider.title, style: .default) { [weak self] _ in
                NoteTranslationPreferences.provider = provider
                self?.reloadFromPreferences()
            })
        }
        alert.addAction(.init(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = providerRow
            popover.sourceRect = providerRow.bounds
        }
        present(alert, animated: true)
    }
}

final class SettingsNoteTranslationLanguageController: UIViewController, Themeable, UITableViewDataSource, UITableViewDelegate {
    private let table = UITableView(frame: .zero, style: .plain)
    private let languages = NoteTranslationPreferences.languages

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Translate into"
        view.accessibilityIdentifier = "noteTranslationLanguageScreen"

        table.backgroundColor = .background
        table.separatorStyle = .singleLine
        table.separatorColor = .foreground6
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        updateTheme()
    }

    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        table.backgroundColor = .background
        table.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let language = languages[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = language.name
        config.textProperties.color = .foreground
        config.textProperties.font = .appFont(withSize: 16, weight: .regular)
        cell.contentConfiguration = config
        cell.backgroundColor = .background3
        cell.selectionStyle = .none
        cell.accessoryType = language.code == NoteTranslationPreferences.targetLanguage ? .checkmark : .none
        cell.tintColor = .accent
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NoteTranslationPreferences.targetLanguage = languages[indexPath.row].code
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}
