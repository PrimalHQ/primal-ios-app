//
//  LargeZapGalleryView.swift
//  Primal
//
//  Created by Pavle Stevanović on 21.6.24..
//

import UIKit
import Lottie

protocol LargeZapGalleryDelegate: AnyObject {
    func menuConfigurationForZap(_ zap: ParsedZap) -> UIContextMenuConfiguration?
    func mainActionForZap(_ zap: ParsedZap)
}

extension UIButton.Configuration {
    static func zapPillButton() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .foreground
        config.attributedTitle = .init("Zap", attributes: .init([
            .font: UIFont.appFont(withSize: 14, weight: .bold),
            .foregroundColor: UIColor.background2
        ]))
        config.image = UIImage(named: "topZapGalleryIcon")?.withTintColor(.background2, renderingMode: .alwaysOriginal)
        config.imagePadding = 4
        return config
    }
}

class LargeZapGalleryView: UIView, ZapGallery {
    let stack = UIStackView()
    let animationStack = UIStackView()
    
    let zapPillButton = UIButton(configuration: .zapPillButton()).constrainToSize(height: 28)
    
    weak var delegate: ZapGalleryViewDelegate?
    
    var singleLine: Bool = false
    
    init() {
        super.init(frame: .zero)
        [animationStack, stack].forEach {
            $0.axis = .vertical
            $0.alignment = .leading
            $0.spacing = 8
            
            addSubview($0)
        }
        stack.pinToSuperview()
        animationStack.pinToSuperview(edges: [.horizontal, .top])
        
        animationStack.isUserInteractionEnabled = false
        
        clipsToBounds = true
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var zaps: [ParsedZap] = [] {
        didSet {
            update()
        }
    }
    
    var animatingChanges: Bool {
        guard let id = WalletManager.instance.animatingZap.value?.receiptId else { return false }
        return zaps.contains(where: { $0.receiptId == id })
    }
        
    func update() {
        animationStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.arrangedSubviews.forEach {
            $0.removeFromSuperview()
            if animatingChanges {
                animationStack.addArrangedSubview($0)
            }
        }
        defer {
            if animatingChanges {
                // Start animating
                animateStacks()
            }
        }
        
        if let first = zaps.first {
            let hStack = UIStackView(arrangedSubviews: [zapView(first, text: true)])
            stack.addArrangedSubview(hStack)
            
            if zaps.count == 1 {
                hStack.spacing = 6
                hStack.addArrangedSubview(zapPillButton)
                
                return
            }
        } else {
            stack.addArrangedSubview(zapPillButton)
            return
        }
        
        let hStack = UIStackView()
        hStack.spacing = 6
        var currentWidth: CGFloat = 0
        for zap in zaps.dropFirst() {
            let view = zapView(zap, text: false)
//            view.layoutIfNeeded()
            
            currentWidth += view.width() + 6
            
            if currentWidth + 110 > frame.width {
                let image = UIImageView(image: UIImage(named: "zapGalleryExtra")).constrainToSize(28)
                hStack.addArrangedSubview(image)
                hStack.addArrangedSubview(zapPillButton)
                stack.addArrangedSubview(hStack)
                return
            }
            
            hStack.addArrangedSubview(view)
        }
        
        if !hStack.arrangedSubviews.isEmpty {
            hStack.addArrangedSubview(zapPillButton)
            stack.addArrangedSubview(hStack)
        }
    }
    
    func zapView(_ zap: ParsedZap, text: Bool) -> LargeZapPillView {
        let view = text ? LargeZapPillTextView(zap: zap) : LargeZapPillView(zap: zap)
//        view.addInteraction(GalleryZapPillMenuInteraction(galleryView: self, zap: zap))
        return view
    }
    
    func findPillInStack(receiptId: String) -> LargeZapGalleryChildView? {
        stack.findAllSubviews().first(where: { $0.zap.receiptId == receiptId })
    }
    
    func animateStacks() {
        (animationStack.arrangedSubviews.last as? UIStackView)?.addArrangedSubview(UIButton(configuration: .zapPillButton()))
        
        layoutIfNeeded()
        animationStack.layoutIfNeeded()
        
        print("ANIMATING")
        
        var zapAnimations: [String: () -> ()] = [:]

        for view in animationStack.arrangedSubviews {
            guard let stack = view as? UIStackView else { continue }

            for view in stack.arrangedSubviews {
                guard let zapView = view as? LargeZapGalleryChildView else {
                    if let animatingButton = view as? UIButton, let realButton = (self.stack.arrangedSubviews.last as? UIStackView)?.arrangedSubviews.last {
                        let newOrigin = realButton.convert(CGPoint.zero, to: self)
                        let oldOrigin = animatingButton.convert(CGPoint.zero, to: self)
                        
                        var deltaY = newOrigin.y - oldOrigin.y
                        if deltaY > 5 { // Hardcode Y translation because for some reason it is not correct
                            deltaY = 36
                        }

                        realButton.alpha = 0.01

                        UIView.animate(withDuration: 12 / 30) {
                            animatingButton.transform = .init(translationX: newOrigin.x - oldOrigin.x, y: deltaY)
                        } completion: { _ in
                            realButton.alpha = 1
                        }

                        continue
                    }
                    
                    UIView.animate(withDuration: 6 / 30) {
                        view.alpha = 0.01
                    }
                    continue
                }

                let receiptId = zapView.zap.receiptId
                guard let newPill = findPillInStack(receiptId: receiptId) else {
                    // Fade out animation
                    zapAnimations[receiptId] = {
                        UIView.animate(withDuration: 6 / 30) {
                            zapView.alpha = 0.01
                        }
                    }
                    continue
                }
                
                if let textPill = zapView as? LargeZapPillTextView, newPill as? LargeZapPillTextView == nil {
                    // Transform and translate text pill into regular pill
                    
                    let animatingPill = LargeZapPillTextView(zap: textPill.zap)
                    addSubview(animatingPill)
                    animatingPill.pin(to: textPill, edges: [.leading, .top])
                    layoutIfNeeded()
                    
                    let label = UILabel()
                    label.font = animatingPill.label.font
                    label.textColor = animatingPill.label.textColor
                    label.text = animatingPill.label.text
                    
                    animatingPill.addSubview(label)
                    label.pinToSuperview(edges: .trailing, padding: 10).centerToSuperview(axis: .vertical)
                    
                    animatingPill.layoutIfNeeded()
                    
                    // Translate animation
                    zapAnimations[receiptId] = {
                        newPill.alpha = 0.01
                        textPill.alpha = 0.01
                        
                        let newOrigin = newPill.convert(CGPoint.zero, to: self)
                        let oldOrigin = textPill.convert(CGPoint.zero, to: self)
                        
                        var deltaY = newOrigin.y - oldOrigin.y
                        if deltaY > 5 { // Hardcode Y translation because for some reason it is not correct
                            deltaY = 32
                        }

                        UIView.animate(withDuration: 3 / 30) {
                            label.alpha = 0
                            
                            animatingPill.zapIcon.alpha = 0
                            animatingPill.zapIcon.isHidden = true
                        }
                        
                        UIView.animate(withDuration: 12 / 30) {
                            animatingPill.label.isHidden = true
                            animatingPill.transform = .init(translationX: newOrigin.x - oldOrigin.x, y: deltaY)
                        } completion: { _ in
                            newPill.alpha = 1
                            animatingPill.removeFromSuperview()
                        }
                    }
                    continue
                }

                // Translate animation
                zapAnimations[receiptId] = {
                    let newOrigin = newPill.convert(CGPoint.zero, to: self)
                    let oldOrigin = zapView.convert(CGPoint.zero, to: self)
                    
                    var deltaY = newOrigin.y - oldOrigin.y
                    if deltaY > 5 { // Hardcode Y translation because for some reason it is not correct
                        deltaY = 32
                    }

                    newPill.alpha = 0.01

                    UIView.animate(withDuration: 12 / 30) {
                        zapView.transform = .init(translationX: newOrigin.x - oldOrigin.x, y: deltaY)
                    } completion: { _ in
                        newPill.alpha = 1
                    }
                }
            }
        }
        
        for view in stack.arrangedSubviews {
            guard let hStack = view as? UIStackView else { continue }
            
            for view in hStack.arrangedSubviews {
                guard let pill = view as? LargeZapPillView else {
                    view.alpha = 0.01
                    UIView.animate(withDuration: 6 / 30, delay: 3 / 30) {
                        view.alpha = 1
                    }
                    continue
                }
                
                guard zapAnimations[pill.zap.receiptId] == nil else { continue }
                    
                zapAnimations[pill.zap.receiptId] = {
                    pill.alpha = 0.01
                    pill.transform = .init(translationX: 300, y: 0)
                    
                    var background: UIView?
                    if pill.zap.user.isCurrentUser {
                        let view = UIView()
                        pill.insertSubview(view, at: 0)
                        view.pinToSuperview()
                        view.backgroundColor = .init(rgb: 0xFFA02F)
                        background = view
                    }
                    
                    UIView.animate(withDuration: 6 / 30, delay: 3 / 30) {
                        pill.alpha = 1
                    }
                    
                    UIView.animate(withDuration: 12 / 30, delay: 3 / 30, options: [.curveEaseInOut]) {
                        pill.transform = .identity
                    } completion: { _ in
                        if let background {
                            UIView.animate(withDuration: 12 / 30, delay: 0, options: [.curveEaseOut]) {
                                background.alpha = 0
                            } completion: { _ in
                                background.removeFromSuperview()
                            }
                        }
                    }
                }
            }
        }
        
        for (_, anim) in zapAnimations {
            anim()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900)) {
            self.animationStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
    }
}
