//
//  NoteTranslateView.swift
//  Primal
//
//  Created by indrad3v4 on 6.8.26..
//

import UIKit

// "Translate" button shown under note content. Translates the note into the
// user's preferred language (see NoteTranslation) and shows the result inline
// with attribution and a "Show original" toggle, similar to the web app.
final class NoteTranslateView: UIView {
    private let translateButton = UIButton(type: .system)
    private let translatedLabel = UILabel()
    private let attributionLabel = UILabel()
    private let showOriginalButton = UIButton(type: .system)
    private let errorLabel = UILabel()
    
    private lazy var translatedStack = UIStackView(axis: .vertical, [translatedLabel, metaStack])
    private lazy var metaStack = UIStackView([attributionLabel, showOriginalButton])
    
    private var noteID: String?
    private var noteText = ""
    private var isTranslating = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with content: ParsedContent) {
        // Keep the current state while the cell is reused for the same note.
        if noteID == content.post.id { return }
        
        noteID = content.post.id
        noteText = content.text
        
        isHidden = content.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        if let cached = NoteTranslation.cachedTranslation(for: content.post.id) {
            showTranslated(cached)
        } else {
            showButton()
        }
    }
    
    func updateTheme() {
        translateButton.setTitleColor(.accent2, for: .normal)
        showOriginalButton.setTitleColor(.accent2, for: .normal)
        translatedLabel.textColor = .foreground
        attributionLabel.textColor = .foreground3
        errorLabel.textColor = .foreground3
    }
    
    private func translate() {
        guard let noteID, !isTranslating, !noteText.isEmpty else { return }
        
        if let cached = NoteTranslation.cachedTranslation(for: noteID) {
            showTranslated(cached)
            return
        }
        
        let targetNoteID = noteID
        let text = noteText
        
        isTranslating = true
        translateButton.setTitle("Translating…", for: .normal)
        translateButton.isEnabled = false
        
        Task { @MainActor [weak self] in
            let result = await NoteTranslation.translate(text)
            
            guard let self, self.noteID == targetNoteID else { return }
            
            self.isTranslating = false
            self.translateButton.setTitle("Translate", for: .normal)
            self.translateButton.isEnabled = true
            
            if let result {
                NoteTranslation.cacheTranslation(result, for: targetNoteID)
                self.showTranslated(result)
            } else {
                self.showError()
            }
        }
    }
    
    private func showButton() {
        translatedStack.isHidden = true
        errorLabel.isHidden = true
        translateButton.isHidden = false
    }
    
    private func showTranslated(_ result: TranslationResult) {
        translatedLabel.text = result.text
        attributionLabel.text = result.engine == .google ? "Translated by Google Translate" : "Translated by LibreTranslate"
        translateButton.isHidden = true
        errorLabel.isHidden = true
        translatedStack.isHidden = false
    }
    
    private func showError() {
        translateButton.isHidden = true
        translatedStack.isHidden = true
        errorLabel.isHidden = false
    }
}

private extension NoteTranslateView {
    func setup() {
        let stack = UIStackView(axis: .vertical, [translateButton, translatedStack, errorLabel])
        stack.spacing = 6
        addSubview(stack)
        stack.pinToSuperview()
        
        translateButton.setTitle("Translate", for: .normal)
        translateButton.titleLabel?.font = .appFont(withSize: 14, weight: .regular)
        translateButton.contentHorizontalAlignment = .leading
        translateButton.addAction(.init(handler: { [weak self] _ in
            self?.translate()
        }), for: .touchUpInside)
        
        translatedLabel.numberOfLines = 0
        translatedLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        
        metaStack.spacing = 8
        attributionLabel.font = .appFont(withSize: 13, weight: .regular)
        attributionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        showOriginalButton.setTitle("Show original", for: .normal)
        showOriginalButton.titleLabel?.font = .appFont(withSize: 13, weight: .regular)
        showOriginalButton.addAction(.init(handler: { [weak self] _ in
            self?.showButton()
        }), for: .touchUpInside)
        
        errorLabel.text = "Translation is unavailable right now. Please try again later."
        errorLabel.numberOfLines = 0
        errorLabel.font = .appFont(withSize: 13, weight: .regular)
        
        translatedStack.isHidden = true
        errorLabel.isHidden = true
        
        updateTheme()
    }
}
