//
//  NoteTranslationView.swift
//  Primal
//
//  Created by Primal on 15.9.26..
//

import UIKit

/// Displays the translated version of a note underneath its original text,
/// with a caption showing the source language and a "Show original" button.
final class NoteTranslationView: UIView, Themeable {
    let captionLabel = UILabel()
    let translatedLabel = UILabel()
    let showOriginalButton = UIButton()

    private lazy var captionStack = UIStackView([captionLabel, UIView(), showOriginalButton])
    private lazy var stack = UIStackView(axis: .vertical, [captionStack, translatedLabel])

    /// Called when the user taps "Show original" — owners route this to the
    /// `.translate` PostCellEvent, which toggles the translation off.
    var onShowOriginal: (() -> Void)?

    init() {
        super.init(frame: .zero)
        setup()
        updateTheme()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(_ content: ParsedContent) {
        if let languageName = TranslationManager.languageName(content.translationSourceLanguage) {
            captionLabel.text = "Translated from \(languageName)"
        } else {
            captionLabel.text = "Translated with \(TranslationSettings.provider.shortTitle)"
        }
        translatedLabel.text = content.translatedText
        isHidden = (content.translatedText ?? "").isEmpty
    }

    func updateTheme() {
        backgroundColor = .background3
        layer.cornerRadius = 12

        captionLabel.textColor = .foreground3
        captionLabel.font = .appFont(withSize: 13, weight: .medium)

        translatedLabel.textColor = .foreground
        translatedLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)

        showOriginalButton.setTitleColor(.accent2, for: .normal)
        showOriginalButton.titleLabel?.font = .appFont(withSize: 13, weight: .semibold)
    }
}

private extension NoteTranslationView {
    func setup() {
        showOriginalButton.setTitle("Show original", for: .normal)
        showOriginalButton.addAction(.init(handler: { [weak self] _ in
            self?.onShowOriginal?()
        }), for: .touchUpInside)

        captionStack.alignment = .center
        captionStack.spacing = 8

        translatedLabel.numberOfLines = 0

        addSubview(stack)
        stack.pinToSuperview(padding: 12)

        isHidden = true
    }
}
