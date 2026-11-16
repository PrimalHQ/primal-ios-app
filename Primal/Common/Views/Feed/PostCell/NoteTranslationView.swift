//
//  NoteTranslationView.swift
//  Primal
//
//  Inline block shown inside a note cell after the note has been
//  translated: a "Translated from {language}" header above the
//  translated text.
//

import UIKit

final class NoteTranslationView: UIView {
    let headerLabel = UILabel()
    let bodyLabel = UILabel()

    private lazy var stack = UIStackView(arrangedSubviews: [headerLabel, bodyLabel])

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTranslation(_ translation: NoteTranslation) {
        headerLabel.text = "Translated from \(TranslationService.languageName(for: translation.detectedLanguage))"
        bodyLabel.text = translation.text
    }
}

private extension NoteTranslationView {
    func setup() {
        headerLabel.font = .appFont(withSize: 13, weight: .semibold)
        headerLabel.textColor = .foreground3
        headerLabel.numberOfLines = 1

        bodyLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        bodyLabel.textColor = .foreground
        bodyLabel.numberOfLines = 0

        stack.axis = .vertical
        stack.spacing = 4

        addSubview(stack)
        stack.pinToSuperview()
    }
}
