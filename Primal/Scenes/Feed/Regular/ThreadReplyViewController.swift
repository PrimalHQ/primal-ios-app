//
//  ThreadReplyViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.4.26..
//

import Combine
import Photos
import UIKit

extension UIButton.Configuration {
    static var threadReplyButton: UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        if #available(iOS 26.0, *) {
            config = UIButton.Configuration.glass()
            config.baseForegroundColor = .foreground
        } else {
            config.baseForegroundColor = .white
            config.baseBackgroundColor = .accent
        }
        
        config.image = .sendMessage
        config.cornerStyle = .capsule
        return config
    }
}

final class ThreadReplyViewController: UIViewController {
    var replyingToName: String? {
        didSet { updatePlaceholder() }
    }

    var replyId: String? {
        didSet { buildManagerIfReady() }
    }

    var replyingTo: PrimalFeedPost? {
        didSet { buildManagerIfReady() }
    }

    var onPost: (() -> Void)?

    private let textView = SelfSizingTextView()
    private let placeholderLabel = UILabel()
    private let plusButton = UIButton()
    private let sendButton = UIButton(configuration: .threadReplyButton)

    private let mentionTable = UITableView()
    private let mentionContainer = UIView()
    private let mentionHorizontalSpacer = SpacerView(width: 70)
    private let mentionVerticalSpacer = SpacerView(height: PostingPreviewEmbedsView.viewHeight - 8)
    
    private var embedsTopC: NSLayoutConstraint?

    let previewEmbedsView = PostingPreviewEmbedsView()
    
    private lazy var pillRow = UIStackView(axis: .horizontal, spacing: 8, [pillStackBackgroundBackground, sendButton])
    
    private let pillStackBackground = UIVisualEffectView()
    // We need this background behind glass to force it to stay the same base color as our background
    private let pillStackBackgroundBackground = UIView()

    private lazy var attachmentInputView: ReplyAttachmentInputView = {
        let view = ReplyAttachmentInputView()
        view.onMedia = { [weak self] in self?.openGallery() }
        view.onCamera = { [weak self] in self?.openCamera() }
        view.onGif = { [weak self] in self?.openGifPicker() }
        view.onPoll = { [weak self] in self?.openPollInput() }
        view.onAssetSelected = { [weak self] result in
            self?.manager?.processSelectedAsset(result)
            self?.isAttachmentInputShowing = false
        }
        view.onRequestPresentingViewController = { [weak self] in self }
        return view
    }()
    private var isAttachmentInputShowing = false {
        didSet {
            UIView.animate(withDuration: 0.1) { [self] in
                plusButton.transform = isAttachmentInputShowing ? .init(rotationAngle: .pi / 4) : .identity
            }
            
            textView.inputView = isAttachmentInputShowing ? attachmentInputView : nil
            textView.reloadInputViews()
            
            if isAttachmentInputShowing {
                attachmentInputView.photoPreview.refreshAuthState()
                if !textView.isFirstResponder {
                    textView.becomeFirstResponder()
                }
            }
        }
    }

    private var manager: PostingTextViewManager?
    private var cancellables: Set<AnyCancellable> = []

    func focus() {
        textView.becomeFirstResponder()
    }

    func saveDraftIfNeeded() {
        guard let manager, !manager.isPosting else { return }
        let draft = manager.currentDraft
        let isEmpty = draft.text.isEmpty
            && draft.uploadedAssets.isEmpty
            && draft.taggedUsers.isEmpty
            && draft.customTags.isEmpty
        if isEmpty {
            DatabaseManager.instance.deleteDraft(replyingTo: replyId)
        } else {
            DatabaseManager.instance.saveDraft(draft)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupViews()
    }
}

private extension ThreadReplyViewController {
    func updatePlaceholder() {
        let name = replyingToName ?? ""
        placeholderLabel.text = name.isEmpty ? "Reply" : "Reply to \(name)"
    }

    func buildManagerIfReady() {
        if let manager {
            if manager.replyingTo?.universalID != replyingTo?.universalID {
                manager.replyingTo = replyingTo
            }
            return
        }
        guard replyId != nil else { return }
        let m = PostingTextViewManager(
            textView: textView,
            usersTable: mentionTable,
            replyId: replyId,
            replyingTo: replyingTo,
            defaultPostTitle: "Reply"
        )
        self.manager = m
        textView.font = .appFont(withSize: 16, weight: .regular)
        textView.backgroundColor = .clear
        textView.tintColor = .accent
        bindManager(m)
    }

    func bindManager(_ manager: PostingTextViewManager) {
        manager.$isEditing
            .removeDuplicates()
            .dropFirst()
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink { [weak self] shouldShow in
                guard let self else { return }
                self.sendButton.isHidden = !shouldShow
                self.pillRow.layoutMargins = shouldShow ? .init(top: 0, left: 12, bottom: 12, right: 12) : .init(top: 0, left: 20, bottom: 28, right: 12)
                if !shouldShow {
                    self.isAttachmentInputShowing = false
                }
            }
            .store(in: &cancellables)

        manager.$postButtonEnabledState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.sendButton.isEnabled = enabled
            }
            .store(in: &cancellables)

        manager.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                self?.placeholderLabel.isHidden = !isEmpty
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(manager.$isEditing, manager.$users)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEditing, users in
                guard let self else { return }
                let count = min(users.count, 5)
                manager.usersHeightConstraint.constant = CGFloat(count) * 60
                let shouldHide = !isEditing || users.isEmpty
                if mentionContainer.isHidden != shouldHide {
                    UIView.animate(withDuration: 0.2) {
                        self.mentionContainer.isHidden = shouldHide
                        self.view.layoutIfNeeded()
                    }
                }
                mentionTable.reloadData()
            }
            .store(in: &cancellables)

        previewEmbedsView.bind(to: manager)
        
        Publishers.CombineLatest(previewEmbedsView.isShowingPublisher, previewEmbedsView.$isExpanded)
            .sink { [weak self] isShowing, isExpanded in
                guard isShowing else {
                    UIView.animate(withDuration: 0.2) {
                        self?.mentionHorizontalSpacer.isHidden = true
                        self?.mentionVerticalSpacer.isHidden = true
                        self?.embedsTopC?.isActive = false
                        self?.view.superview?.layoutIfNeeded()
                    }
                    return
                }
                
                UIView.animate(withDuration: 0.2) {
                    self?.embedsTopC?.isActive = isExpanded
                    self?.mentionHorizontalSpacer.isHidden = isExpanded
                    self?.mentionVerticalSpacer.isHidden = !isExpanded
                    self?.view.superview?.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
        
    }

    func setupViews() {
        configurePlaceholder()
        configurePlusButton()
        configureSendButton()
        configureInputPill()
        configureMentionContainer()
        configureTextView()

        pillRow.alignment = .bottom
        pillRow.isLayoutMarginsRelativeArrangement = true
        pillRow.insetsLayoutMarginsFromSafeArea = false
        pillRow.layoutMargins = .init(top: 0, left: 12, bottom: 28, right: 12)

        let bottomStack = UIStackView(axis: .vertical, spacing: 8, [mentionContainer, pillRow])
        bottomStack.alignment = .fill

        view.addSubview(bottomStack)
        bottomStack.pinToSuperview(edges: [.horizontal, .bottom])

        view.addSubview(previewEmbedsView)
        previewEmbedsView.pinToSuperview(edges: .trailing).pin(to: pillRow, edges: .top, padding: -PostingPreviewEmbedsView.viewHeight)

        let topC = view.topAnchor.constraint(equalTo: bottomStack.topAnchor)
        topC.priority = .defaultHigh
        topC.isActive = true

        embedsTopC = view.topAnchor.constraint(lessThanOrEqualTo: previewEmbedsView.topAnchor)

        plusButton.addAction(.init(handler: { [weak self] _ in
            self?.isAttachmentInputShowing.toggle()
        }), for: .touchUpInside)

        sendButton.addAction(.init(handler: { [weak self] _ in
            self?.sendPressed()
        }), for: .touchUpInside)
    }

    func configureTextView() {
        textView.font = .appFont(withSize: 15, weight: .regular)
        textView.textColor = .foreground.withAlphaComponent(0.9)
        textView.backgroundColor = .clear
        textView.tintColor = .accent
        textView.textContainerInset = .init(top: 12, left: 0, bottom: 10, right: 0)
        textView.textContainer.lineFragmentPadding = 0
    }

    func configurePlaceholder() {
        placeholderLabel.font = .appFont(withSize: 15, weight: .regular)
        placeholderLabel.textColor = .foreground.withAlphaComponent(0.7)
        placeholderLabel.isUserInteractionEnabled = false
        updatePlaceholder()
    }

    func configurePlusButton() {
        plusButton.setImage(.addPostPlus.withRenderingMode(.alwaysTemplate), for: .normal)
        plusButton.tintColor = .foreground.withAlphaComponent(0.6)
        plusButton.constrainToSize(32)
    }

    func configureSendButton() {
        sendButton.isEnabled = false
        sendButton.isHidden = true
        sendButton.constrainToSize(46)
    }
    
    func configureInputPill() {
        if #available(iOS 26.0, *) {
            pillStackBackground.effect = UIGlassEffect(style: .regular)
        } else {
            pillStackBackground.effect = UIBlurEffect(style: .regular)
        }
        
        pillStackBackground.tintColor = .background
        pillStackBackground.overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
        pillStackBackground.layer.cornerRadius = 23
        pillStackBackground.clipsToBounds = true
        
        // We need this behind glass to make it darker/lighter
        pillStackBackgroundBackground.backgroundColor = .background.withAlphaComponent(0.3)
        pillStackBackgroundBackground.layer.cornerRadius = 23
        
        pillStackBackgroundBackground.addSubview(pillStackBackground)
        pillStackBackground.contentView.addSubview(textView)
        pillStackBackground.contentView.addSubview(plusButton)
        pillStackBackground.contentView.addSubview(placeholderLabel)
        
        pillStackBackground.pinToSuperview()
        placeholderLabel.centerToSuperview(axis: .vertical).pin(to: textView, edges: .leading)
        plusButton.pinToSuperview(edges: .trailing, padding: 8).pinToSuperview(edges: .bottom, padding: 7)
        
        let minH = pillStackBackgroundBackground.heightAnchor.constraint(greaterThanOrEqualToConstant: 46)
        minH.priority = .defaultHigh
        minH.isActive = true
        pillStackBackgroundBackground.heightAnchor.constraint(lessThanOrEqualToConstant: 140).isActive = true
        
        textView
            .pinToSuperview(edges: .bottom)
            .pinToSuperview(edges: .top)
            .pinToSuperview(edges: .leading, padding: 16)
            .pinToSuperview(edges: .trailing, padding: 40)
    }

    func configureMentionContainer() {
        mentionContainer.isHidden = true
        
        let blurView:UIVisualEffectView
        if #available(iOS 26.0, *) {
            blurView = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
        } else {
            blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        }
        mentionContainer.addSubview(blurView)

        mentionTable.backgroundColor = .clear
        mentionTable.bounces = false
        mentionTable.layer.cornerRadius = 24
        mentionTable.clipsToBounds  = true
        
        let vStack = UIStackView(axis: .vertical, [
            UIStackView(axis: .horizontal, [mentionTable, mentionHorizontalSpacer]),
            mentionVerticalSpacer
        ])
        
        [mentionHorizontalSpacer, mentionVerticalSpacer].forEach { view in
            view.addGestureRecognizer(BindableTapGestureRecognizer { [weak self] in
                self?.textView.resignFirstResponder()
            })
        }
        
        mentionContainer.addSubview(vStack)
        vStack.pinToSuperview(edges: .vertical, padding: 4).pinToSuperview(edges: .horizontal, padding: 12)
        
        blurView.pin(to: mentionTable, edges: .vertical, padding: -4).pin(to: mentionTable, edges: .horizontal, padding: 8)
        blurView.layer.cornerRadius = 24
        blurView.clipsToBounds = true
    }

    func sendPressed() {
        guard let manager else { return }
        if manager.isUploadingImages { return }
        let text = manager.postingText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || !manager.media.isEmpty else { return }

        let onPost = self.onPost
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard await manager.post() != nil else { return }
            manager.reset()
            self.textView.resignFirstResponder()
            self.textView.invalidateIntrinsicContentSize()
            onPost?()
        }
    }

    func openGallery() {
        isAttachmentInputShowing = false
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] _ in
                DispatchQueue.main.async { self?.presentGalleryPicker() }
            }
        } else {
            presentGalleryPicker()
        }
    }

    func presentGalleryPicker() {
        ImagePickerManager(self, mode: .gallery, allowVideo: true, selectionLimit: 0) { [weak self] result in
            self?.manager?.processSelectedAsset(result)
        }
    }

    func openCamera() {
        isAttachmentInputShowing = false
        ImagePickerManager(self, mode: .camera) { [weak self] result in
            self?.manager?.processSelectedAsset(result)
        }
    }

    func openGifPicker() {
        isAttachmentInputShowing = false
        present(KlipyGifController { [weak self] res in
            guard let url = res.gifURL ?? res.mediumgifURL ?? res.tinygifURL else { return }
            self?.manager?.processSelectedAsset(RemoteGifMediaPickerResult(url: url))
        }, animated: true)
    }

    func openPollInput() {
        guard let manager else { return }
        isAttachmentInputShowing = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.present(PollInputViewController(manager: manager), animated: true)
        }
    }
}
