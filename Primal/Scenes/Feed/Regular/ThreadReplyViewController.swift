//
//  ThreadReplyViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.4.26..
//

import UIKit

final class ThreadReplyViewController: UIViewController {
    var replyingToName: String? {
        didSet { updateButtonTitle() }
    }

    var onTap: (() -> Void)?

    private let button = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        view.addSubview(button)
        button
            .pinToSuperview(edges: .horizontal, padding: 20)
            .pinToSuperview(edges: .top)
            .pinToSuperview(edges: .bottom, padding: 24)

        button.addAction(.init(handler: { [weak self] _ in
            self?.onTap?()
        }), for: .touchUpInside)

        configureButton()
    }

    private func configureButton() {
        var config: UIButton.Configuration
        if #available(iOS 26.0, *) {
            config = .glass()
        } else {
            config = .gray()
        }

        config.cornerStyle = .capsule
        config.image = UIImage(named: "addPostPlus")?.withRenderingMode(.alwaysTemplate)
        config.imagePlacement = .trailing
        config.contentInsets = .init(top: 16, leading: 24, bottom: 16, trailing: 20)
        config.baseForegroundColor = .foreground4

        button.configuration = config
        button.contentHorizontalAlignment = .fill

        updateButtonTitle()
    }

    private func updateButtonTitle() {
        guard var config = button.configuration else { return }
        let name = replyingToName ?? ""
        let title = name.isEmpty ? "Reply" : "Reply to \(name)"
        var attr = AttributedString(title)
        attr.font = .appFont(withSize: 16, weight: .regular)
        config.attributedTitle = attr
        button.configuration = config
    }
}
