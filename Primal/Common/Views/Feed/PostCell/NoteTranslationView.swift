//
//  NoteTranslationView.swift
//  Primal
//
//  Created for Primal iOS app — inline note translation toggle UI
//

import UIKit

/// Displays a "Translate" button below note content. After translation, toggles
/// between the original text and the translated text with a source-language label.
final class NoteTranslationView: UIStackView {
    private let translateButton = UIButton(type: .system)
    private let translatedLabel = UILabel()
    private let sourceLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var currentText = ""
    private var currentTask: Task<Void, Never>?
    private var translationResult: NoteTranslationService.TranslationResult?
    private var isShowingTranslation = false
    private var hasError = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Called when a note's content is set. Resets the translation state for the new text.
    func configure(with text: String) {
        currentText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        currentTask?.cancel()
        currentTask = nil
        translationResult = nil
        isShowingTranslation = false
        hasError = false

        translatedLabel.text = nil
        sourceLabel.text = nil
        translatedLabel.isHidden = true
        sourceLabel.isHidden = true
        activityIndicator.stopAnimating()

        let shouldShow = NoteTranslationService.shared.shouldOfferTranslation(for: currentText)
        isHidden = !shouldShow
        translateButton.isEnabled = true
        translateButton.setTitle(NSLocalizedString("Translate", comment: "Button: translate note"), for: .normal)
    }
}

// MARK: - UI Setup

private extension NoteTranslationView {
    func setup() {
        axis = .vertical
        alignment = .fill
        spacing = 4
        isHidden = true

        // Translate / Show original / Hide translation button
        translateButton.contentHorizontalAlignment = .leading
        translateButton.titleLabel?.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        translateButton.tintColor = .accent
        translateButton.setContentCompressionResistancePriority(.required, for: .vertical)
        translateButton.addAction(.init(handler: { [weak self] _ in
            self?.translateTapped()
        }), for: .touchUpInside)

        // Translated text label
        translatedLabel.numberOfLines = 0
        translatedLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        translatedLabel.textColor = .foreground
        translatedLabel.isHidden = true

        // Source language attribution
        sourceLabel.numberOfLines = 1
        sourceLabel.font = .appFont(withSize: 12, weight: .regular)
        sourceLabel.textColor = .foreground3
        sourceLabel.isHidden = true
        sourceLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        // Loading indicator
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .foreground3

        addArrangedSubview(translateButton)
        addArrangedSubview(translatedLabel)
        addArrangedSubview(sourceLabel)
        addArrangedSubview(activityIndicator)
    }

    func translateTapped() {
        // If we already have a result, toggle display
        if let result = translationResult {
            isShowingTranslation.toggle()
            updateVisibleTranslation(result: result)
            return
        }

        // If we had an error, clear it and retry
        if hasError {
            hasError = false
            translateButton.isEnabled = true
            translateButton.setTitle(NSLocalizedString("Translate", comment: "Button: translate note"), for: .normal)
        }

        // Guard: don't start duplicate requests
        guard currentTask == nil else { return }

        translateButton.isEnabled = false
        translateButton.setTitle(NSLocalizedString("Translating…", comment: "Button: translation in progress"), for: .normal)
        activityIndicator.startAnimating()

        let textToTranslate = currentText
        currentTask = Task { [weak self] in
            do {
                let result = try await NoteTranslationService.shared.translate(textToTranslate)
                guard !Task.isCancelled, let self else { return }

                self.translationResult = result
                self.isShowingTranslation = true
                self.hasError = false
                self.currentTask = nil

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.updateVisibleTranslation(result: result)
                }
            } catch {
                guard !Task.isCancelled, let self else { return }

                self.hasError = true
                self.currentTask = nil

                await MainActor.run {
                    self.activityIndicator.stopAnimating()
                    self.translateButton.isEnabled = true

                    let errorMessage: String
                    if let translationError = error as? NoteTranslationService.TranslationError {
                        errorMessage = translationError.localizedDescription
                    } else {
                        errorMessage = NSLocalizedString("Translation failed", comment: "Error: translation failed")
                    }

                    self.translatedLabel.text = errorMessage
                    self.translatedLabel.isHidden = false
                    self.sourceLabel.isHidden = true
                    self.translateButton.setTitle(
                        NSLocalizedString("Retry Translate", comment: "Button: retry note translation"),
                        for: .normal
                    )
                }
            }
        }
    }

    func updateVisibleTranslation(result: NoteTranslationService.TranslationResult) {
        translatedLabel.text = isShowingTranslation ? result.translatedText : nil
        translatedLabel.isHidden = !isShowingTranslation
        activityIndicator.stopAnimating()

        if isShowingTranslation {
            if let detectedLang = result.detectedLanguage, !detectedLang.isEmpty {
                let format = NSLocalizedString("Translated from %@", comment: "Translation source attribution, e.g. Translated from ZH")
                sourceLabel.text = String(format: format, detectedLang.uppercased())
                sourceLabel.isHidden = false
            } else {
                sourceLabel.text = nil
                sourceLabel.isHidden = true
            }

            translateButton.setTitle(
                NSLocalizedString("Show original", comment: "Button: show original note text"),
                for: .normal
            )
        } else {
            sourceLabel.isHidden = true
            translateButton.isEnabled = true
            translateButton.setTitle(
                NSLocalizedString("Show translation", comment: "Button: show translated note text"),
                for: .normal
            )
        }
    }
}
