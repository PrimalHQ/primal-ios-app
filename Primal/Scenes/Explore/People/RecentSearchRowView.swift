//
//  RecentSearchRowView.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.4.26..
//

import UIKit

final class RecentSearchRowView: UIView, Themeable {
    let termLabel = UILabel()
    let arrowIcon = UIImageView(image: .recentSearchArrow)
    let border = UIView()

    var onTap: (() -> Void)?

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init() {
        super.init(frame: .zero)
        setup()
    }

    func setSearch(_ text: String) { termLabel.text = text }

    func updateTheme() {
        termLabel.textColor = .foreground3
        arrowIcon.tintColor = .accent
        border.backgroundColor = .background3
        backgroundColor = .background
    }
}

private extension RecentSearchRowView {
    func setup() {
        termLabel.font = .appFont(withSize: 16, weight: .regular)

        arrowIcon.contentMode = .center
        arrowIcon.constrainToSize(20)

        let stack = UIStackView(arrangedSubviews: [SpacerView(width: 8, priority: .required), termLabel, UIView(), arrowIcon, SpacerView(width: 15, priority: .required)])
        stack.axis = .horizontal
        stack.alignment = .center

        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 16).pinToSuperview(edges: .vertical, padding: 12)

        addSubview(border)
        border.pinToSuperview(edges: .bottom).constrainToSize(height: 1).pin(to: stack, edges: .horizontal)

        updateTheme()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc func handleTap() { onTap?() }
}
