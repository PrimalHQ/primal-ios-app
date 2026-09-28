//
//  NoteTranslationView.swift
//  Primal
//

import UIKit

final class NoteTranslationView: UIView, Themeable {
    private let actionButton = UIButton(type: .system)
    private let translatedLabel = UILabel()
    private let metaLabel = UILabel()
    private let stack = UIStackView()
    private var noteId: String?
    private var noteContent: String = ""
    private var subscription: UUID?
    private var busy = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        if let subscription {
            NoteTranslationService.shared.unsubscribe(subscription)
        }
    }

    func bind(noteId: String, content: String) {
        self.noteId = noteId
        self.noteContent = content
        let prefs = NoteTranslationPrefsStore.read()
        let offer = prefs.enabled && TranslationSanitizer.shouldOfferTranslation(content)
        isHidden = !offer
        refresh()
    }

    func updateTheme() {
        actionButton.setTitleColor(.accent, for: .normal)
        translatedLabel.textColor = .foreground3
        metaLabel.textColor = .foreground4
    }

    private func setup() {
        stack.axis = .vertical
        stack.spacing = 4
        addSubview(stack)
        stack.pinToSuperview()

        actionButton.contentHorizontalAlignment = .leading
        actionButton.titleLabel?.font = .appFont(withSize: 14, weight: .regular)
        actionButton.addAction(.init(handler: { [weak self] _ in self?.handleTap() }), for: .touchUpInside)

        translatedLabel.numberOfLines = 0
        translatedLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        metaLabel.font = .appFont(withSize: 12, weight: .regular)

        stack.addArrangedSubview(actionButton)
        stack.addArrangedSubview(translatedLabel)
        stack.addArrangedSubview(metaLabel)

        subscription = NoteTranslationService.shared.subscribe { [weak self] id in
            guard let self, self.noteId == id else { return }
            self.refresh()
        }
        updateTheme()
    }

    private func refresh() {
        guard let noteId else { return }
        let entry = NoteTranslationService.shared.cached(noteId: noteId)
        if busy {
            actionButton.setTitle("Translating…", for: .normal)
        } else if let entry, !entry.showingOriginal {
            actionButton.setTitle("Show original", for: .normal)
        } else if entry?.showingOriginal == true {
            actionButton.setTitle("Show translation", for: .normal)
        } else {
            actionButton.setTitle("Translate", for: .normal)
        }

        if let entry, !entry.showingOriginal {
            translatedLabel.isHidden = false
            translatedLabel.text = entry.translated
            if let detected = entry.detected, !detected.isEmpty {
                metaLabel.isHidden = false
                metaLabel.text = "Detected: \(detected)"
            } else {
                metaLabel.isHidden = true
            }
        } else {
            translatedLabel.isHidden = true
            metaLabel.isHidden = true
        }
    }

    private func handleTap() {
        guard let noteId, !busy else { return }
        if NoteTranslationService.shared.cached(noteId: noteId) != nil {
            NoteTranslationService.shared.toggleShowOriginal(noteId: noteId)
            return
        }
        busy = true
        refresh()
        NoteTranslationService.shared.translate(noteId: noteId, content: noteContent, prefs: NoteTranslationPrefsStore.read()) { [weak self] result in
            guard let self else { return }
            self.busy = false
            self.refresh()
            if case .failure(let error) = result {
                self.findViewController()?.view.showToast(error.localizedDescription)
            }
        }
    }
}

private extension UIView {
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let vc = current as? UIViewController { return vc }
            responder = current.next
        }
        return nil
    }
}
