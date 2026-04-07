//
//  ThreadLayout.swift
//  Primal
//
//  Created by Pavle Stevanović on 26.3.26..
//

import UIKit

class ThreadLayout {
    let position: ThreadPosition
    let firstRow = UIView().constrainToSize(width: 32)
    let parentIndicator = UIView().constrainToSize(width: 2)
    let secondRow = UIView()

    init(position: ThreadPosition) {
        self.position = position
    }

    func install(in contentView: UIView) {
        parentIndicator.backgroundColor = .foreground6

        let mainStack = UIStackView([firstRow, secondRow])
        mainStack.spacing = 8
        contentView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .trailing, padding: 12)
            .pinToSuperview(edges: .leading, padding: 12)
            .pinToSuperview(edges: .vertical)

        switch position {
        case .parent:
            firstRow.addSubview(parentIndicator)
            parentIndicator
                .pinToSuperview(edges: .trailing, padding: 11)
                .pinToSuperview(edges: .top, padding: 0)
                .pinToSuperview(edges: .bottom, padding: 0)
            contentView.backgroundColor = .clear
        case .main:
            firstRow.isHidden = true
            contentView.backgroundColor = .clear
        case .child:
            contentView.backgroundColor = .background2
        }
    }

    func updateAppearance(contentView: UIView) {
        parentIndicator.backgroundColor = .foreground6
        contentView.backgroundColor = position == .child ? .background2 : .clear
    }
}
