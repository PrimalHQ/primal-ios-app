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

    private let panelHeight: CGFloat = 291

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: panelHeight)
    }

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 291))
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private extension ReplyAttachmentInputView {
    func setupViews() {
        backgroundColor = .background

        let mediaButton = LabeledIconButton(icon: UIImage(named: "ImageIcon"), title: "Media") { [weak self] in
            self?.onMedia?()
        }
        let cameraButton = LabeledIconButton(icon: UIImage(named: "CameraIcon"), title: "Camera") { [weak self] in
            self?.onCamera?()
        }
        let gifButton = LabeledIconButton(icon: .gifButton, title: "GIF") { [weak self] in
            self?.onGif?()
        }
        let pollButton = LabeledIconButton(icon: .pollIcon, title: "Poll") { [weak self] in
            self?.onPoll?()
        }

        let row = UIStackView(axis: .horizontal, [mediaButton, cameraButton, gifButton, pollButton])
        row.distribution = .equalSpacing
        row.alignment = .center

        addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            row.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
        ])
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
        iconContainer.backgroundColor = .background3
        iconContainer.layer.cornerRadius = 16
        iconContainer.isUserInteractionEnabled = false
        iconContainer.constrainToSize(56)

        iconView.image = icon?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = .foreground
        iconView.contentMode = .scaleAspectFit
        iconView.constrainToSize(28)
        iconContainer.addSubview(iconView)
        iconView.centerToSuperview()

        titleLabel.text = title
        titleLabel.font = .appFont(withSize: 12, weight: .regular)
        titleLabel.textColor = .foreground
        titleLabel.textAlignment = .center

        let stack = UIStackView(axis: .vertical, spacing: 6, [iconContainer, titleLabel])
        stack.alignment = .center
        stack.isUserInteractionEnabled = false

        addSubview(stack)
        stack.pinToSuperview()
    }
}
