//
//  ThreadReplyViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.4.26..
//

import Combine
import UIKit

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
    private let sendButton = UIButton(configuration: .liveSendButton(enabled: true))

    private let mentionTable = UITableView()
    private let mentionContainer = UIView()

    private let previewEmbedsView = PostingPreviewEmbedsView()

    private lazy var pillRow = UIStackView(axis: .horizontal, spacing: 8, [pillStack, sendButton])
    private let pillStack = UIStackView()

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
        Publishers.CombineLatest3(manager.$isEmpty, manager.$media, manager.$isEditing)
            .map { isEmpty, media, isEditing in
                !isEmpty || !media.isEmpty || isEditing
            }
            .removeDuplicates()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldShow in
                guard let self else { return }
                UIView.animate(withDuration: 0.2) {
                    self.sendButton.isHidden = !shouldShow
                }
            }
            .store(in: &cancellables)
        
        manager.$isEditing.sink { [weak self] editing in
            self?.pillRow.layoutMargins = editing ? .init(top: 0, left: 12, bottom: 12, right: 12) : .init(top: 0, left: 20, bottom: 20, right: 12)
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

        manager.$users
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                guard let self else { return }
                let count = min(users.count, 4)
                manager.usersHeightConstraint.constant = CGFloat(count) * 60
                let shouldHide = users.isEmpty
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
    }

    func setupViews() {
        configureTextView()
        configurePlaceholder()
        configurePlusButton()
        configureSendButton()
        configurePillStack()
        configureMentionContainer()

        pillRow.alignment = .bottom
        pillRow.isLayoutMarginsRelativeArrangement = true
        pillRow.layoutMargins = .init(top: 0, left: 12, bottom: 12, right: 12)

        let keyboardSpacer = KeyboardSizingView()
        let bottomStack = UIStackView(axis: .vertical, spacing: 8, [mentionContainer, previewEmbedsView, pillRow, keyboardSpacer])
        bottomStack.alignment = .fill

        view.addSubview(bottomStack)
        bottomStack.pinToSuperview()

        plusButton.addAction(.init(handler: { [weak self] _ in
            self?.presentMediaActionSheet()
        }), for: .touchUpInside)

        sendButton.addAction(.init(handler: { [weak self] _ in
            self?.sendPressed()
        }), for: .touchUpInside)
        
        keyboardSpacer.updateHeightCancellable().store(in: &cancellables)
    }

    func configureTextView() {
        textView.font = .appFont(withSize: 16, weight: .regular)
        textView.textColor = .foreground
        textView.backgroundColor = .clear
        textView.tintColor = .accent
        textView.textContainerInset = .init(top: 9, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0

        let minH = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        minH.priority = .defaultHigh
        minH.isActive = true
        textView.heightAnchor.constraint(lessThanOrEqualToConstant: 140).isActive = true
    }

    func configurePlaceholder() {
        placeholderLabel.font = .appFont(withSize: 16, weight: .regular)
        placeholderLabel.textColor = .foreground4
        placeholderLabel.isUserInteractionEnabled = false
        updatePlaceholder()
    }

    func configurePlusButton() {
        plusButton.setImage(UIImage(named: "addPostPlus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        plusButton.tintColor = .foreground4
        plusButton.constrainToSize(32)
    }

    func configureSendButton() {
        sendButton.isEnabled = false
        sendButton.isHidden = true
        sendButton.constrainToSize(40)
    }

    func configurePillStack() {
        pillStack.axis = .horizontal
        pillStack.alignment = .bottom
        pillStack.spacing = 4
        pillStack.isLayoutMarginsRelativeArrangement = true
        pillStack.layoutMargins = .init(top: 0, left: 16, bottom: 4, right: 4)
        pillStack.backgroundColor = .background3
        pillStack.layer.cornerRadius = 20

        pillStack.addArrangedSubview(textView)
        pillStack.addArrangedSubview(plusButton)

        pillStack.addSubview(placeholderLabel)
        placeholderLabel
            .pinToSuperview(edges: .bottom, padding: 10)
            .pin(to: textView, edges: .leading)
    }

    func configureMentionContainer() {
        mentionContainer.clipsToBounds = true
        mentionContainer.isHidden = true
        
        let blurView:UIVisualEffectView
        if #available(iOS 26.0, *) {
            blurView = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
        } else {
            blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        }
        mentionContainer.addSubview(blurView)
        blurView.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 20)
        blurView.layer.cornerRadius = 24

        mentionTable.backgroundColor = .clear
        mentionTable.bounces = false
        mentionContainer.addSubview(mentionTable)
        mentionTable.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 12)
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

    func presentMediaActionSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(.init(title: "Add Image", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            ImagePickerManager(self, mode: .gallery, allowVideo: true, selectionLimit: 0) { [weak self] result in
                self?.manager?.processSelectedAsset(result)
            }
        }))
        alert.addAction(.init(title: "Add GIF", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            present(KlipyGifController { [weak self] res in
                guard let url = res.gifURL ?? res.mediumgifURL ?? res.tinygifURL else { return }
                self?.manager?.processSelectedAsset(RemoteGifMediaPickerResult(url: url))
            }, animated: true)
        }))
        alert.addAction(.init(title: "Take Photo", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            ImagePickerManager(self, mode: .camera) { [weak self] result in
                self?.manager?.processSelectedAsset(result)
            }
        }))
        alert.addAction(.init(title: "Take Video", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            ImagePickerManager(self, mode: .cameraVideo) { [weak self] result in
                self?.manager?.processSelectedAsset(result)
            }
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.popoverPresentationController?.sourceView = plusButton
        present(alert, animated: true)
    }
}
