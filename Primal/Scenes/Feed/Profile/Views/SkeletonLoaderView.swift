//
//  SkeletonLoaderView.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.9.24..
//

import UIKit
import Lottie

class SkeletonLoaderCell: UITableViewCell {
    let loaderView = SkeletonLoaderView(aspect: 343 / 128)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(loaderView)
        loaderView
            .pinToSuperview(edges: .horizontal)
            .pinToSuperview(edges: .top, padding: 10)
        
        let botC = loaderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        
        [botC].forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }
        
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class SkeletonLoaderView: UIView, Themeable {
    var repeatCount: Int { didSet { updateViewCount() } }
    let aspect: CGFloat
    
    private let vStack = UIStackView(axis: .vertical, [])
    private var animationViews: [GenericLoadingView] = []
    
    init(aspect: CGFloat, repeatCount: Int = 5) {
        self.repeatCount = repeatCount
        self.aspect = aspect
        super.init(frame: .zero)
        
        addSubview(vStack)
        vStack.pinToSuperview(padding: 16)
        vStack.spacing = 32
        updateViewCount()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func play() {
        animationViews.forEach { $0.play() }
    }
    
    func pause() {
        animationViews.forEach { $0.pause() }
    }
    
    func updateViewCount() {
        while animationViews.count > repeatCount {
            animationViews.popLast()?.removeFromSuperview()
        }
        
        guard animationViews.count < repeatCount else { return }
        
        for _ in animationViews.count..<repeatCount {
            let animView = GenericLoadingView().constrainToAspect(aspect)
            animationViews.append(animView)
            vStack.addArrangedSubview(animView)
        }
    }
    
    func updateTheme() {
//        animationViews.forEach { $0.updateTheme() }
    }
}

