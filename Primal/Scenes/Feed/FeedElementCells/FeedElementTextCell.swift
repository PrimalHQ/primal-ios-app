//
//  FeedElementTextCell.swift
//  Primal
//
//  Created by Pavle DStevanović on 16.5.23..
//

import UIKit
import SwiftUI
#if canImport(Translation)
import Translation
#endif

final class FeedElementTextCell: UITableViewCell {
    let mainLabel = ChatSelectionTextView()
    private let translateButton = UIButton(type: .system)
    private var originalAttributedText: NSAttributedString?
    private var rawText: String = ""
    private var translationHostController: UIViewController?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(_ content: ParsedContent) {
        originalAttributedText = content.attributedText
        rawText = content.attributedText.string

        if NoteTranslationStore.shared.isShowingTranslation(for: rawText),
           let translated = NoteTranslationStore.shared.cachedTranslation(for: rawText) {
            applyTranslatedText(translated)
            translateButton.setTitle("Show original", for: .normal)
        } else {
            mainLabel.attributedText = content.attributedText
            translateButton.setTitle("Translate note", for: .normal)
        }
        translateButton.isHidden = rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func applyTranslatedText(_ text: String) {
        guard let base = originalAttributedText else {
            mainLabel.text = text
            return
        }
        let mutable = NSMutableAttributedString(string: text)
        if base.length > 0 {
            let attrs = base.attributes(at: 0, effectiveRange: nil)
            mutable.addAttributes(attrs, range: NSRange(location: 0, length: mutable.length))
        }
        mainLabel.attributedText = mutable
    }

    @objc private func handleTranslateTap() {
        guard !rawText.isEmpty else { return }

        if NoteTranslationStore.shared.cachedTranslation(for: rawText) != nil {
            let showing = NoteTranslationStore.shared.toggle(for: rawText)
            if showing, let translated = NoteTranslationStore.shared.cachedTranslation(for: rawText) {
                applyTranslatedText(translated)
                translateButton.setTitle("Show original", for: .normal)
            } else {
                mainLabel.attributedText = originalAttributedText
                translateButton.setTitle("Translate note", for: .normal)
            }
            return
        }

        #if canImport(Translation)
        if #available(iOS 17.4, *) {
            runNativeTranslation()
            return
        }
        #endif
    }

    #if canImport(Translation)
    @available(iOS 17.4, *)
    private func runNativeTranslation() {
        let (shielded, tokenMap) = NoteTokenShield.shield(rawText)
        translateButton.setTitle("Translating…", for: .normal)
        translateButton.isEnabled = false

        let bridgeView = TranslationBridgeView(sourceText: shielded) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.translateButton.isEnabled = true
                self.translationHostController?.view.removeFromSuperview()
                self.translationHostController = nil

                switch result {
                case .success(let translatedShielded):
                    let restored = NoteTokenShield.unshield(translatedShielded, tokens: tokenMap)
                    NoteTranslationStore.shared.storeTranslation(restored, for: self.rawText)
                    self.applyTranslatedText(restored)
                    self.translateButton.setTitle("Show original", for: .normal)
                case .failure:
                    self.translateButton.setTitle("Translate note", for: .normal)
                }
            }
        }

        let host = UIHostingController(rootView: bridgeView)
        host.view.frame = .zero
        host.view.isHidden = true
        contentView.addSubview(host.view)
        translationHostController = host
    }
    #endif

    func setup() {
        selectionStyle = .none
        backgroundColor = .background
        contentView.backgroundColor = .background

        translateButton.setTitle("Translate note", for: .normal)
        translateButton.titleLabel?.font = .appFont(withSize: 13, weight: .regular)
        translateButton.setTitleColor(.accent, for: .normal)
        translateButton.contentHorizontalAlignment = .leading
        translateButton.addTarget(self, action: #selector(handleTranslateTap), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [mainLabel, translateButton])
        stack.axis = .vertical
        stack.spacing = 6

        contentView.addSubview(stack)
        stack.pinToSuperview(edges: [.leading, .trailing], insets: .init(top: 0, left: 16, bottom: 0, right: 16))
        stack.pinToSuperview(edges: [.top, .bottom], insets: .init(top: 0, left: 0, bottom: 12, right: 0))
    }
}

#if canImport(Translation)
@available(iOS 17.4, *)
private struct TranslationBridgeView: View {
    let sourceText: String
    let onComplete: (Result<String, Error>) -> Void
    @State private var configuration: TranslationSession.Configuration? = .init()

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .translationTask(configuration) { session in
                do {
                    let response = try await session.translate(sourceText)
                    onComplete(.success(response.targetText))
                } catch {
                    onComplete(.failure(error))
                }
            }
    }
}
#endif
