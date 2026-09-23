//
//  NoteTranslateControlView.swift
//  Primal
//
//  X-style inline translate control shown under note body text.
//  Target language follows the device preferred language (no API keys required).
//

import UIKit

final class NoteTranslateControlView: UIView {
    private let actionButton = UIButton(type: .system)
    private let translatedBox = UIView()
    private let translatedLabel = UILabel()
    private let metaLabel = UILabel()
    private let showOriginalButton = UIButton(type: .system)
    private let errorLabel = UILabel()
    private lazy var metaStack = UIStackView(arrangedSubviews: [metaLabel, showOriginalButton])
    private lazy var resultStack = UIStackView(arrangedSubviews: [translatedBox, metaStack])
    private lazy var rootStack = UIStackView(arrangedSubviews: [actionButton, resultStack, errorLabel])

    private var content: String = ""
    private var settingsLocale: String?
    private var loading = false
    private var translated: String?
    private var sourceLang: String?
    private var showingTranslation = false
    private var translateTask: Task<Void, Never>?

    /// Called when the control's intrinsic height may have changed (e.g. after translate).
    var onHeightChange: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        translateTask?.cancel()
    }

    /// Configure with note plain text. Empty content hides the control.
    func configure(content: String, settingsLocale: String? = nil) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let contentChanged = trimmed != self.content
        self.content = trimmed
        self.settingsLocale = settingsLocale
        isHidden = trimmed.isEmpty

        if contentChanged {
            translateTask?.cancel()
            translateTask = nil
            loading = false
            translated = nil
            sourceLang = nil
            showingTranslation = false
            errorLabel.isHidden = true
            errorLabel.text = nil
        }

        refreshUI()
    }

    func updateTheme() {
        actionButton.setTitleColor(.accent2, for: .normal)
        actionButton.setTitleColor(.accent2.withAlphaComponent(0.7), for: .disabled)
        actionButton.titleLabel?.font = .appFont(withSize: 14, weight: .regular)

        showOriginalButton.setTitleColor(.accent2, for: .normal)
        showOriginalButton.titleLabel?.font = .appFont(withSize: 12, weight: .regular)

        translatedLabel.textColor = .foreground
        translatedLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)

        metaLabel.textColor = .foreground3
        metaLabel.font = .appFont(withSize: 12, weight: .regular)

        errorLabel.textColor = .systemRed
        errorLabel.font = .appFont(withSize: 13, weight: .regular)

        translatedBox.backgroundColor = .background3
        translatedBox.layer.borderColor = UIColor.background4.cgColor
    }

    // MARK: - Private

    private func setup() {
        addSubview(rootStack)
        rootStack
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, padding: 6)
            .pinToSuperview(edges: .bottom)
        rootStack.axis = .vertical
        rootStack.spacing = 6
        rootStack.alignment = .fill

        actionButton.contentHorizontalAlignment = .leading
        actionButton.addTarget(self, action: #selector(onTranslateTapped), for: .touchUpInside)

        translatedBox.layer.cornerRadius = 8
        translatedBox.layer.borderWidth = 1
        translatedBox.clipsToBounds = true
        translatedBox.addSubview(translatedLabel)
        translatedLabel.numberOfLines = 0
        translatedLabel.pinToSuperview(edges: .all, padding: 10)

        metaStack.axis = .horizontal
        metaStack.spacing = 8
        metaStack.alignment = .center

        metaLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        showOriginalButton.setContentHuggingPriority(.required, for: .horizontal)
        showOriginalButton.contentHorizontalAlignment = .leading
        showOriginalButton.addTarget(self, action: #selector(onShowOriginalTapped), for: .touchUpInside)
        showOriginalButton.setTitle("Show original", for: .normal)

        resultStack.axis = .vertical
        resultStack.spacing = 6
        resultStack.alignment = .fill
        resultStack.isHidden = true

        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        isHidden = true
        updateTheme()
        refreshUI()
    }

    private func refreshUI() {
        if isHidden {
            notifyHeightIfNeeded()
            return
        }

        if showingTranslation, let translated {
            resultStack.isHidden = false
            actionButton.isHidden = true
            translatedLabel.text = translated
            if let sourceLang, !sourceLang.isEmpty {
                let name = NoteTranslate.languageDisplayName(sourceLang)
                metaLabel.text = "Translated from \(name)"
                metaLabel.isHidden = false
            } else {
                metaLabel.text = nil
                metaLabel.isHidden = true
            }
        } else {
            resultStack.isHidden = true
            actionButton.isHidden = false
            actionButton.isEnabled = !loading
            actionButton.setTitle(loading ? "Translating…" : "Translate", for: .normal)
        }

        notifyHeightIfNeeded()
    }

    private func notifyHeightIfNeeded() {
        setNeedsLayout()
        layoutIfNeeded()
        onHeightChange?()
    }

    @objc private func onTranslateTapped() {
        guard !content.isEmpty, !loading else { return }

        if showingTranslation, translated != nil {
            showingTranslation = false
            refreshUI()
            return
        }

        if translated != nil {
            showingTranslation = true
            refreshUI()
            return
        }

        loading = true
        errorLabel.isHidden = true
        errorLabel.text = nil
        refreshUI()

        let target = NoteTranslate.resolveTargetLanguage(settingsLocale: settingsLocale)
        let text = content
        translateTask?.cancel()
        translateTask = Task { [weak self] in
            do {
                let result = try await NoteTranslate.translateText(text, targetLang: target)
                await MainActor.run {
                    guard let self, !Task.isCancelled else { return }
                    self.translated = result.translatedText
                    self.sourceLang = result.detectedSourceLanguage
                    self.showingTranslation = true
                    self.loading = false
                    self.refreshUI()
                }
            } catch {
                await MainActor.run {
                    guard let self, !Task.isCancelled else { return }
                    self.loading = false
                    let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    self.errorLabel.text = "Translation failed: \(message)"
                    self.errorLabel.isHidden = false
                    self.refreshUI()
                }
            }
        }
    }

    @objc private func onShowOriginalTapped() {
        showingTranslation = false
        refreshUI()
    }
}

extension UIView {
    /// Ask the enclosing table view to recompute row heights after dynamic content changes.
    func refreshEnclosingTableRowHeight() {
        guard let tableView = firstParent(ofType: UITableView.self) else { return }
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
