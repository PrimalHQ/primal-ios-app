//
//  ReplyAttachmentInputView.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.5.26..
//

import UIKit

final class ReplyAttachmentInputView: UIView {
    var onMedia: (() -> Void)?
    var onCamera: (() -> Void)?
    var onGif: (() -> Void)?
    var onPoll: (() -> Void)?
    var onAssetSelected: ((ImagePickerResult) -> Void)?
    var onRequestPresentingViewController: (() -> UIViewController?)?

    let photoPreview = ReplyPhotoPreviewView()

    private let panelHeight: CGFloat = 340

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: panelHeight)
    }

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 340))
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            photoPreview.refreshAuthState()
        }
    }
}

private extension ReplyAttachmentInputView {
    func setupViews() {
        
        if #available(iOS 26.0, *) {
            cornerConfiguration = .uniformTopRadius(24)
            
            backgroundColor = .clear
        } else {
            backgroundColor = .background
            layer.cornerRadius = 24
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }

        let mediaButton = LabeledIconButton(icon: .mediaIcon24, title: "Media") { [weak self] in
            self?.onMedia?()
        }
        let cameraButton = LabeledIconButton(icon: .cameraIcon24, title: "Camera") { [weak self] in
            self?.onCamera?()
        }
        let gifButton = LabeledIconButton(icon: .gifIcon24, title: "GIF") { [weak self] in
            self?.onGif?()
        }
        let pollButton = LabeledIconButton(icon: .pollIcon24, title: "Poll") { [weak self] in
            self?.onPoll?()
        }

        let row = UIStackView(axis: .horizontal, spacing: 8, [mediaButton, cameraButton, gifButton, pollButton])
        row.distribution = .fillEqually
        row.alignment = .center
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = .init(top: 0, left: 20, bottom: 12, right: 20)

        photoPreview.onAssetSelected = { [weak self] result in self?.onAssetSelected?(result) }
        photoPreview.onRequestPresentingViewController = { [weak self] in self?.onRequestPresentingViewController?() }

        let mainStack = UIStackView(axis: .vertical, spacing: 0, [photoPreview, UIView(), row])
        addSubview(mainStack)
        mainStack.pinToSuperview(padding: 2)
    }
}

private final class LabeledIconButton: UIControl {
    private let iconContainer = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let tapAction: () -> Void

    init(icon: UIImage?, title: String, action: @escaping () -> Void) {
        self.tapAction = action
        super.init(frame: .zero)
        setupViews(icon: icon, title: title)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isHighlighted: Bool {
        didSet { iconContainer.alpha = isHighlighted ? 0.6 : 1 }
    }

    @objc private func handleTap() {
        tapAction()
    }

    private func setupViews(icon: UIImage?, title: String) {
        iconContainer.backgroundColor = .foreground.withAlphaComponent(0.2)
        iconContainer.layer.cornerRadius = 20
        iconContainer.isUserInteractionEnabled = false
        iconContainer.constrainToSize(height: 40)

        iconView.image = icon?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = .foreground
        iconView.contentMode = .scaleAspectFit
        iconView.constrainToSize(24)
        iconContainer.addSubview(iconView)
        iconView.centerToSuperview()

        titleLabel.text = title
        titleLabel.font = .appFont(withSize: 14, weight: .regular)
        titleLabel.textColor = .foreground
        titleLabel.textAlignment = .center

        let stack = UIStackView(axis: .vertical, spacing: 8, [iconContainer, titleLabel])
        stack.isUserInteractionEnabled = false

        addSubview(stack)
        stack.pinToSuperview()
    }
}
