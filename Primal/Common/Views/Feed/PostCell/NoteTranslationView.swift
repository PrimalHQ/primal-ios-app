//
//  NoteTranslationView.swift
//  Primal
//

import UIKit

final class NoteTranslationView: UIStackView {
    private let translateButton = UIButton(type: .system)
    private let translatedLabel = UILabel()
    private let sourceLabel = UILabel()

    private var currentText = ""
    private var currentRequestID = UUID()
    private var currentTask: URLSessionDataTask?
    private var translationResult: NoteTranslationService.TranslationResult?
    private var isShowingTranslation = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        currentTask?.cancel()
    }

    func configure(with text: String) {
        currentTask?.cancel()
        currentTask = nil
        currentText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        currentRequestID = UUID()
        translationResult = nil
        isShowingTranslation = false

        translatedLabel.text = nil
        sourceLabel.text = nil
        translatedLabel.isHidden = true
        sourceLabel.isHidden = true

        isHidden = !NoteTranslationService.shared.shouldOfferTranslation(for: currentText)
        translateButton.isEnabled = true
        translateButton.setTitle("Translate", for: .normal)
        translateButton.accessibilityLabel = "Translate note"
    }
}

private extension NoteTranslationView {
    func setup() {
        axis = .vertical
        alignment = .fill
        spacing = 5
        isHidden = true

        translateButton.contentHorizontalAlignment = .leading
        translateButton.titleLabel?.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        translateButton.tintColor = .accent2
        translateButton.setContentCompressionResistancePriority(.required, for: .vertical)
        translateButton.addTarget(self, action: #selector(translateTapped), for: .touchUpInside)

        translatedLabel.numberOfLines = 0
        translatedLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        translatedLabel.textColor = .foreground
        translatedLabel.isHidden = true
        translatedLabel.accessibilityLabel = "Translated note"

        sourceLabel.numberOfLines = 1
        sourceLabel.font = .appFont(withSize: 12, weight: .regular)
        sourceLabel.textColor = .foreground3
        sourceLabel.isHidden = true

        addArrangedSubview(translateButton)
        addArrangedSubview(translatedLabel)
        addArrangedSubview(sourceLabel)
    }

    @objc func translateTapped() {
        if translationResult != nil {
            isShowingTranslation.toggle()
            updateVisibleTranslation()
            return
        }

        currentTask?.cancel()
        let requestID = UUID()
        currentRequestID = requestID
        translateButton.isEnabled = false
        translateButton.setTitle("Translating…", for: .normal)
        translateButton.accessibilityLabel = "Translating note"

        currentTask = NoteTranslationService.shared.translate(currentText) { [weak self] result in
            guard let self, self.currentRequestID == requestID else { return }
            self.currentTask = nil
            self.translateButton.isEnabled = true

            switch result {
            case .success(let translation):
                self.translationResult = translation
                self.isShowingTranslation = true
                self.updateVisibleTranslation()
            case .failure(let error):
                if (error as? URLError)?.code == .cancelled {
                    return
                }
                self.translationResult = nil
                self.isShowingTranslation = false
                self.translatedLabel.text = error.localizedDescription
                self.translatedLabel.isHidden = false
                self.sourceLabel.isHidden = true
                self.translateButton.setTitle("Retry Translate", for: .normal)
                self.translateButton.accessibilityLabel = "Retry note translation"
            }
        }
    }

    func updateVisibleTranslation() {
        guard let translationResult else { return }

        translatedLabel.text = isShowingTranslation ? translationResult.translatedText : nil
        translatedLabel.isHidden = !isShowingTranslation

        if isShowingTranslation, let detectedLanguage = translationResult.detectedLanguage, !detectedLanguage.isEmpty {
            sourceLabel.text = "Translated from \(detectedLanguage.uppercased())"
            sourceLabel.isHidden = false
        } else {
            sourceLabel.text = nil
            sourceLabel.isHidden = true
        }

        translateButton.setTitle(isShowingTranslation ? "Hide translation" : "Show translation", for: .normal)
        translateButton.accessibilityLabel = isShowingTranslation ? "Hide note translation" : "Show note translation"
    }
}
