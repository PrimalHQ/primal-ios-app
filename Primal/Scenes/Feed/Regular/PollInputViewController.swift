//
//  PollInputViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.5.26..
//

import UIKit

final class PollInputViewController: UIViewController {
    let manager: PostingTextViewManager

    private lazy var pollInputView = PollInputView(manager: manager)

    init(manager: PostingTextViewManager) {
        self.manager = manager
        super.init(nibName: nil, bundle: nil)
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var preferredStatusBarStyle: UIStatusBarStyle { Theme.current.statusBarStyle }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configurePollState()
    }
}

private extension PollInputViewController {
    func setupViews() {
        view.backgroundColor = .background

        let titleLabel = UILabel("Add poll", color: .foreground, font: .appFont(withSize: 20, weight: .bold))

        let doneButton = UIButton(configuration: .accent("Done", font: .appFont(withSize: 18, weight: .semibold)))
        doneButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)

        let topBar = UIStackView(axis: .horizontal, [titleLabel, UIView(), doneButton])
        topBar.alignment = .center
        topBar.isLayoutMarginsRelativeArrangement = true
        topBar.layoutMargins = .init(top: 12, left: 20, bottom: 12, right: 12)

        let removePollButton = UIButton(configuration: .iconTextButton(icon: .trash, text: "Remove poll", color: .delete))
        removePollButton.addAction(.init(handler: { [weak self] _ in
            self?.manager.pollOptions = nil
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        removePollButton.constrainToSize(height: 48)

        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.addSubview(pollInputView)
        pollInputView
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .vertical, padding: 16)
        pollInputView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40).isActive = true
        
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        let text = NSMutableAttributedString(attributedString: manager.textView.attributedText)
        text.addAttribute(.font, value: UIFont.appFont(withSize: 18, weight: .regular), range: .init(location: 0, length: text.length))
        textLabel.attributedText = text
        let textParent = UIView()
        textParent.addSubview(textLabel)
        textLabel.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .vertical, padding: 0)

        let mainStack = UIStackView(axis: .vertical, [topBar, textParent, scrollView, removePollButton])
        mainStack.alignment = .fill

        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .top, safeArea: true)
            .pinToSuperview(edges: .horizontal)
        mainStack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true

        pollInputView.pollTypeRow.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self else { return }
            let popup = PopupPollTypeController(currentType: self.manager.pollOptions?.type ?? .user)
            popup.delegate = self
            self.present(popup, animated: true)
        }))
    }

    func configurePollState() {
        if let existingPoll = manager.pollOptions {
            pollInputView.restore(existingPoll)
        } else {
            manager.pollOptions = .init()
            pollInputView.reset()
        }
    }
}

extension PollInputViewController: PopupPollTypeDelegate {
    func pollTypeController(_ controller: PopupPollTypeController, didSelect type: PollType) {
        switch manager.pollOptions?.type ?? .user {
        case .user:
            manager.pollOptions?.type = type
        case .zap:
            if case .user = type {
                manager.pollOptions?.type = type
            }
        }
        pollInputView.updateLabels()
    }
}
