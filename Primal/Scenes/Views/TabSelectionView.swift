//
//  TabSelectionView.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.11.23..
//

import Combine
import UIKit

final class TabSelectionView: UIView, Themeable {
    private var buttons: [TabSelectionButton] = []
    private let selectionIndicator = ThemeableView().constrainToSize(height: 4).setTheme { $0.backgroundColor = .accent }
    
    @Published private(set) var selectedTab = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(tabs: [String] = []) {
        super.init(frame: .zero)
        
        buttons = tabs.map { TabSelectionButton(text: $0) }
        for (index, button) in buttons.enumerated() {
            button.addAction(.init(handler: { [weak self] _ in
                self?.selectedTab = index
            }), for: .touchUpInside)
        }
            
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        updateButtons(selectedTab)
    }
}

private extension TabSelectionView {
    func setup() {
        let stack = UIStackView(arrangedSubviews: buttons)
        addSubview(stack)
        stack.pinToSuperview(edges: [.horizontal, .top], padding: 8).pinToSuperview(edges: .bottom)
        stack.distribution = .equalSpacing
        
        selectionIndicator.layer.cornerRadius = 2
        
        $selectedTab.dropFirst().sink { [weak self] newTab in
            self?.setTab(newTab, animated: true)
        }
        .store(in: &cancellables)
        
        setTab(0)
    }
    
    func updateButtons(_ selectedTab: Int) {
        for (index, button) in buttons.enumerated() {
            button.label.font = index == selectedTab ? .appFont(withSize: 14, weight: .semibold) : .appFont(withSize: 14, weight: .regular)
            button.label.textColor = .foreground
        }
    }
    
    func setTab(_ index: Int, animated: Bool = false) {
        updateButtons(index)
        guard let button = buttons[safe: index] else { return }
        selectionIndicator.removeFromSuperview()
        addSubview(selectionIndicator)
        selectionIndicator.pin(to: button.label, edges: .horizontal).pinToSuperview(edges: .bottom, padding: 4)
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.layoutSubviews()
            }
        }
    }
}

final class TabSelectionButton: MyButton {
    var label = UILabel()
    
    init(text: String) {
        super.init(frame: .zero)
        
        label.text = text
        label.textAlignment = .center
        
        addSubview(label)
        label
            .pinToSuperview(edges: .top, padding: 14)
            .pinToSuperview(edges: .bottom, padding: 20)
            .pinToSuperview(edges: .horizontal, padding: 16)
        
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 48).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
