//
//  NoteInlineTranslateView.swift
//  Primal
//
//  Inline Translate / Show original control for kind-1 notes (issue #206).
//

import UIKit

final class NoteInlineTranslateView: UIStackView, Themeable {
    private let actionButton = UIButton(type: .system)
    private let translatedLabel = UILabel()
    private let attributionLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)

    private var noteText = ""
    private var noteID = ""
    private var generation = 0
    private var inflightTask: URLSessionDataTask?
    private var showingTranslation = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func prepareForReuse() {
        cancelInflight()
        noteText = ""
        noteID = ""
        showingTranslation = false
        isHidden = true
        presentIdle()
    }

    func update(with content: ParsedContent) {
        cancelInflight()
        noteText = content.post.content
        noteID = content.post.id
        showingTranslation = false

        let shouldOffer = NoteTranslationClient.shouldOfferTranslation(
            text: noteText,
            kind: content.post.kind
        )
        isHidden = !shouldOffer
        guard shouldOffer else { return }

        if let cached = NoteTranslationClient.instance.cachedTranslation(for: noteText) {
            presentTranslation(cached, providerTitle: NoteTranslationPreferences.provider.title)
            return
        }

        presentIdle()
        if NoteTranslationPreferences.autoTranslate {
            startTranslation()
        }
    }

    func updateTheme() {
        actionButton.setTitleColor(.accent2, for: .normal)
        actionButton.titleLabel?.font = .appFont(withSize: 14, weight: .regular)
        translatedLabel.textColor = .foreground
        translatedLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        attributionLabel.textColor = .foreground4
        attributionLabel.font = .appFont(withSize: 12, weight: .regular)
        spinner.color = .foreground3
    }

    private func setup() {
        axis = .vertical
        alignment = .leading
        spacing = 6

        actionButton.contentHorizontalAlignment = .leading
        actionButton.addAction(.init(handler: { [weak self] _ in
            self?.handleAction()
        }), for: .touchUpInside)
        actionButton.accessibilityIdentifier = "noteTranslateButton"

        translatedLabel.numberOfLines = 0
        translatedLabel.isHidden = true

        attributionLabel.numberOfLines = 1
        attributionLabel.isHidden = true

        spinner.hidesWhenStopped = true

        let actionRow = UIStackView(arrangedSubviews: [actionButton, spinner])
        actionRow.alignment = .center
        actionRow.spacing = 8

        [actionRow, translatedLabel, attributionLabel].forEach { addArrangedSubview($0) }
        isHidden = true
        updateTheme()
    }

    private func handleAction() {
        if showingTranslation {
            presentIdle()
            return
        }
        startTranslation()
    }

    private func startTranslation() {
        cancelInflight()
        generation += 1
        let token = generation
        let expectedID = noteID

        presentLoading()

        inflightTask = NoteTranslationClient.instance.translate(text: noteText) { [weak self] result in
            guard let self, self.generation == token, self.noteID == expectedID else { return }
            switch result {
            case .success(let outcome):
                self.presentTranslation(outcome.text, providerTitle: outcome.providerTitle)
            case .failure(let error):
                self.presentIdle()
                if error != .cancelled, let message = error.errorDescription {
                    RootViewController.instance.view.showToast(message, icon: nil, durationSeconds: 2)
                }
            }
        }
    }

    private func presentIdle() {
        showingTranslation = false
        spinner.stopAnimating()
        translatedLabel.isHidden = true
        attributionLabel.isHidden = true
        actionButton.isEnabled = true
        actionButton.setTitle("Translate", for: .normal)
        actionButton.accessibilityIdentifier = "noteTranslateButton"
        actionButton.accessibilityLabel = "Translate note"
    }

    private func presentLoading() {
        showingTranslation = false
        spinner.startAnimating()
        translatedLabel.isHidden = true
        attributionLabel.isHidden = true
        actionButton.isEnabled = false
        actionButton.setTitle("Translating…", for: .normal)
    }

    private func presentTranslation(_ text: String, providerTitle: String) {
        showingTranslation = true
        spinner.stopAnimating()
        translatedLabel.isHidden = false
        attributionLabel.isHidden = false
        translatedLabel.text = text
        attributionLabel.text = "Translated with \(providerTitle)"
        actionButton.isEnabled = true
        actionButton.setTitle("Show original", for: .normal)
        actionButton.accessibilityIdentifier = "noteShowOriginalButton"
        actionButton.accessibilityLabel = "Show original note"
    }

    private func cancelInflight() {
        generation += 1
        inflightTask?.cancel()
        inflightTask = nil
        spinner.stopAnimating()
    }
}
