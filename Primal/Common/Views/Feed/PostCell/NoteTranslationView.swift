//
//  NoteTranslationView.swift
//  Primal
//
//  Inline translation controls rendered directly below a note's content.
//

import UIKit

/// Inline translation controls for a note, mirroring the web implementation
/// (PrimalHQ/primal-web-app PR #240) and the Android implementation.
///
/// The view stays hidden unless the feature is enabled in Settings and the
/// note is eligible (long enough, has prose, and does not already appear to
/// be in the user's target language). Translation runs only on an explicit
/// tap — never automatically — and the result is shown under the original
/// text with a toggle to hide it again.
final class NoteTranslationView: UIView {

    private let translateButton = UIButton(type: .system)
    private let loadingStack = UIStackView()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let loadingLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let metaLabel = UILabel()
    private let resultLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private let stack = UIStackView()

    private var postID: String?
    private var content: String = ""
    private var task: Task<Void, Never>?
    private var result: TranslationResult?
    private var showingTranslation = true
    /// Fingerprint of the settings the shown result was produced with; a
    /// settings change invalidates the displayed translation.
    private var settingsFingerprint: String?
    /// Translation engine used by this view. Internal (not private) as a
    /// test seam; production code never replaces the shared manager.
    var translator: NoteTranslating = NoteTranslationManager.instance
    /// Monotonic counter identifying the latest translation request, so a
    /// superseded request can never overwrite newer view state.
    private var requestGeneration = 0
    /// Re-configures this view whenever translation settings change, so a
    /// result (or spinner) produced under old settings never lingers.
    private var settingsObserver: NSObjectProtocol?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        settingsObserver = NotificationCenter.default.addObserver(
            forName: .noteTranslationSettingsChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, let postID = self.postID else { return }
            self.configure(postID: postID, content: self.content)
        }
    }

    deinit {
        if let settingsObserver {
            NotificationCenter.default.removeObserver(settingsObserver)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Called from PostCell.update(_:) with the note's identity and raw content.
    func configure(postID: String, content: String) {
        let settings = NoteTranslationPreferences.current
        let fingerprint = Self.currentSettingsFingerprint()
        // Cell updates fire often (stats, likes): keep a shown translation —
        // or an in-flight request — when neither the note nor the settings
        // changed.
        if self.postID == postID, self.content == content,
           settingsFingerprint == fingerprint, result != nil || task != nil {
            return
        }
        reset()
        self.postID = postID
        self.content = content
        settingsFingerprint = fingerprint

        guard settings.enabled, TranslationSanitizer.shouldOfferTranslation(content) else {
            isHidden = true
            return
        }
        if let target = LanguageDetector.primaryLanguageCode(settings.targetLanguage) {
            let detected = LanguageDetector.detectLanguage(TranslationSanitizer.extractTranslatableProse(content))
            if detected == target {
                isHidden = true
                return
            }
        }
        isHidden = false
        showIdle()
    }

    func reset() {
        task?.cancel()
        task = nil
        requestGeneration += 1
        result = nil
        showingTranslation = true
        postID = nil
        content = ""
        settingsFingerprint = nil
    }

    /// Starts a translation for the currently configured note. Internal
    /// (not private) as a test seam; production callers are the view's own
    /// buttons.
    func startTranslation() {
        let requestedPostID = postID
        let requestedContent = content
        let requestedFingerprint = settingsFingerprint
        let translator = self.translator
        requestGeneration += 1
        let generation = requestGeneration
        task?.cancel()
        showLoading()
        // `self` is only touched after the await, so the task does not keep
        // the view alive while the request is in flight. A result is applied
        // only if the note, the request generation AND the current settings
        // fingerprint all still match — so changing or disabling translation
        // in Settings mid-flight invalidates the pending result.
        task = Task { @MainActor [weak self] in
            do {
                let result = try await translator.translateNote(requestedContent)
                guard let self, self.postID == requestedPostID,
                      self.requestGeneration == generation,
                      Self.currentSettingsFingerprint() == requestedFingerprint else { return }
                self.result = result
                self.showingTranslation = true
                self.showResult()
            } catch is CancellationError {
                guard let self, self.postID == requestedPostID,
                      self.requestGeneration == generation else { return }
                self.showIdle()
            } catch let error as TranslationError {
                guard let self, self.postID == requestedPostID,
                      self.requestGeneration == generation,
                      Self.currentSettingsFingerprint() == requestedFingerprint else { return }
                self.showError(error.code)
            } catch {
                guard let self, self.postID == requestedPostID,
                      self.requestGeneration == generation,
                      Self.currentSettingsFingerprint() == requestedFingerprint else { return }
                self.showError(.providerError)
            }
        }
    }

    /// Toggles between the translation and the original text. Internal
    /// (not private) as a test seam; the production caller is the toggle
    /// button.
    func toggleOriginal() {
        showingTranslation.toggle()
        showResult()
    }
}

private extension NoteTranslationView {

    func setup() {
        translateButton.setTitle("Translate", for: .normal)
        translateButton.titleLabel?.font = .appFont(withSize: 14, weight: .medium)
        translateButton.setTitleColor(.accent2, for: .normal)
        translateButton.contentHorizontalAlignment = .leading
        translateButton.addAction(.init(handler: { [weak self] _ in self?.startTranslation() }), for: .touchUpInside)

        loadingLabel.text = "Translating…"
        loadingLabel.font = .appFont(withSize: 14, weight: .regular)
        loadingLabel.textColor = .foreground3

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .appFont(withSize: 14, weight: .medium)
        cancelButton.setTitleColor(.accent2, for: .normal)
        cancelButton.addAction(.init(handler: { [weak self] _ in
            // Bump the generation so a provider response that lands despite
            // cancellation can no longer be applied.
            self?.requestGeneration += 1
            self?.task?.cancel()
            self?.task = nil
            self?.showIdle()
        }), for: .touchUpInside)

        loadingStack.axis = .horizontal
        loadingStack.spacing = 8
        loadingStack.alignment = .center
        [spinner, loadingLabel, cancelButton].forEach { loadingStack.addArrangedSubview($0) }

        metaLabel.font = .appFont(withSize: 13, weight: .regular)
        metaLabel.textColor = .foreground3
        metaLabel.numberOfLines = 0

        resultLabel.font = .appFont(withSize: FontSizeSelection.current.contentFontSize, weight: .regular)
        resultLabel.textColor = .foreground
        resultLabel.numberOfLines = 0

        toggleButton.setTitle("Hide translation", for: .normal)
        toggleButton.titleLabel?.font = .appFont(withSize: 14, weight: .medium)
        toggleButton.setTitleColor(.accent2, for: .normal)
        toggleButton.contentHorizontalAlignment = .leading
        toggleButton.addAction(.init(handler: { [weak self] _ in self?.toggleOriginal() }), for: .touchUpInside)

        errorLabel.font = .appFont(withSize: 14, weight: .regular)
        errorLabel.textColor = .foreground3
        errorLabel.numberOfLines = 0

        retryButton.setTitle("Retry", for: .normal)
        retryButton.titleLabel?.font = .appFont(withSize: 14, weight: .medium)
        retryButton.setTitleColor(.accent2, for: .normal)
        retryButton.contentHorizontalAlignment = .leading
        retryButton.addAction(.init(handler: { [weak self] _ in self?.startTranslation() }), for: .touchUpInside)

        stack.axis = .vertical
        stack.spacing = 4
        [translateButton, loadingStack, metaLabel, resultLabel, toggleButton, errorLabel, retryButton]
            .forEach { stack.addArrangedSubview($0) }
        addSubview(stack)
        stack.pinToSuperview()
    }

    func showOnly(_ visible: [UIView]) {
        [translateButton, loadingStack, metaLabel, resultLabel, toggleButton, errorLabel, retryButton]
            .forEach { $0.isHidden = !visible.contains($0) }
    }

    func showIdle() {
        spinner.stopAnimating()
        showOnly([translateButton])
    }

    func showLoading() {
        spinner.startAnimating()
        showOnly([loadingStack])
    }

    func showResult() {
        spinner.stopAnimating()
        guard let result else { showIdle(); return }
        if let source = result.detectedLanguage ?? result.localDetectedLanguage {
            metaLabel.text = "Translated from \(Self.languageDisplayName(source))"
        } else {
            metaLabel.text = "Translated"
        }
        showOnly(showingTranslation ? [metaLabel, resultLabel, toggleButton] : [metaLabel, toggleButton])
        resultLabel.text = result.translatedText
        toggleButton.setTitle(showingTranslation ? "Hide translation" : "Show translation", for: .normal)
    }

    func showError(_ code: TranslationErrorCode) {
        spinner.stopAnimating()
        errorLabel.text = Self.errorMessage(code)
        showOnly([errorLabel, retryButton])
    }

    static func languageDisplayName(_ code: String) -> String {
        Locale.current.localizedString(forLanguageCode: code) ?? code
    }

    /// Fingerprint of everything that determines a translation result; a
    /// mismatch invalidates displayed or in-flight results. The API key
    /// itself is never retained — only its (non-cryptographic) hash, which
    /// is all change detection needs.
    static func currentSettingsFingerprint() -> String {
        let settings = NoteTranslationPreferences.current
        return "\(settings.enabled)|\(settings.endpoint)|\(settings.targetLanguage)|\(TranslationCache.cyrb53(settings.apiKey))"
    }

    static func errorMessage(_ code: TranslationErrorCode) -> String {
        switch code {
        case .disabled:
            return "Note translation is turned off. Enable it in Settings → Translation."
        case .emptyContent:
            return "This note has nothing to translate."
        case .notConfigured:
            return "Set up note translation in Settings → Translation first."
        case .unreachable:
            return "Couldn't reach the translation service. Check the endpoint in Settings → Translation."
        case .providerError:
            return "The translation service returned an error. Please try again."
        }
    }
}
