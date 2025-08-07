//
//  ZapGallery.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.4.24..
//

import UIKit
import Lottie

protocol ZapGalleryViewDelegate: AnyObject {
    func menuConfigurationForZap(_ zap: ParsedZap) -> UIContextMenuConfiguration?
    func mainActionForZap(_ zap: ParsedZap)
    func zapTapped(_ zap: ParsedZap)
}

protocol ZapGallery: UIView {
    var delegate: ZapGalleryViewDelegate? { get set }
//    var zaps: [ParsedZap] { get set }
    var singleLine: Bool { get set }
    func setZaps(_ zaps: [ParsedZap])
}

class GalleryZapPillMenuInteraction: UIContextMenuInteraction {
    class Delegate: NSObject, UIContextMenuInteractionDelegate {
        weak var interaction: GalleryZapPillMenuInteraction?
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            guard let zapInteraction = self.interaction else { return nil }
            return zapInteraction.galleryView?.delegate?.menuConfigurationForZap(zapInteraction.zap)
        }
        
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            guard let interaction = self.interaction else { return }
            animator.addCompletion {
                interaction.galleryView?.delegate?.mainActionForZap(interaction.zap)
            }
        }
    }
    weak var galleryView: ZapGallery?
    let zap: ParsedZap
    let interactionDelegate = Delegate()
    init(galleryView: ZapGallery, zap: ParsedZap) {
        self.galleryView = galleryView
        self.zap = zap
        
        super.init(delegate: interactionDelegate)
        
        interactionDelegate.interaction = self
    }
}

class SmallZapGalleryView: UIView, ZapGallery {
    let skeletonLoader = GenericLoadingView()
    let stack = UIStackView()
    let animationStack = UIStackView()
    
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
        stack.pinToSuperview(edges: [.horizontal, .top])
        let botC = stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        botC.priority = .defaultHigh
        botC.isActive = true
        
        animationStack.pinToSuperview(edges: [.horizontal, .top])
        
        animationStack.isUserInteractionEnabled = false
        
        addSubview(skeletonLoader)
        skeletonLoader
            .constrainToSize(width: 30, height: 24)
            .pinToSuperview(edges: [.leading, .top])
        skeletonLoader.layer.cornerRadius = 12
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setZaps(_ zaps: [ParsedZap]) {
        self.zaps = zaps
        update(stack: stack, zaps: zaps)
        playSkeleton()
        
        guard
            let animatingId = WalletManager.instance.animatingZap.value?.receiptId,
            zaps.contains(where: { $0.receiptId == animatingId })
        else { return }
        
        var oldZaps = zaps
        oldZaps.removeAll(where: { $0.receiptId == animatingId })
        
        update(stack: animationStack, zaps: oldZaps)
        animateStacks()
    }
    
    private var zaps: [ParsedZap] = []
    
    var animatingChanges: Bool {
        guard let id = WalletManager.instance.animatingZap.value?.receiptId else { return false }
        return zaps.contains(where: { $0.receiptId == id })
    }
    
    func playSkeleton() {
        skeletonLoader.isHidden = !zaps.isEmpty
        if zaps.isEmpty {
            skeletonLoader.play()
        }
    }
        
    func update(stack: UIStackView, zaps: [ParsedZap]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if singleLine {
            let hStack = UIStackView()
            hStack.spacing = 0
            
            if let first = zaps.first {
                hStack.addArrangedSubview(zapView(first, text: true))
                let spacer = SpacerView(width: 375, priority: .init(1))
                hStack.addArrangedSubview(spacer)
                hStack.setCustomSpacing(8, after: spacer)
                stack.addArrangedSubview(hStack)
                hStack.pinToSuperview(edges: .horizontal)
            }
            
            zaps.dropFirst().prefix(3).enumerated().forEach { (index, zap) in
                let view = zapView(zap, text: false, amount: false)
                view.layer.zPosition = CGFloat(999 - index)
                hStack.addArrangedSubview(view)
            }
            return
        }
        
        if zaps.count < 4 {
            let hStack = UIStackView()
            hStack.spacing = 6
            
            if let first = zaps.first {
                hStack.addArrangedSubview(zapView(first, text: true))
                stack.addArrangedSubview(hStack)
            }
            
            zaps.dropFirst().forEach { hStack.addArrangedSubview(zapView($0, text: false)) }
            return
        }
        
        if let first = zaps.first {
            let hStack = UIStackView(arrangedSubviews: [zapView(first, text: true)])
            stack.addArrangedSubview(hStack)
        }
        
        let hStack = UIStackView()
        hStack.spacing = 6
        var currentWidth: CGFloat = 0
        for zap in zaps.dropFirst() {
            let view = zapView(zap, text: false)
            
            currentWidth += view.width() + 6
            
            if currentWidth + 24 > (frame.width < 10 ? 300 : frame.width) {
                let image = UIImageView(image: UIImage(named: "zapGalleryExtra")).constrainToSize(24)
                hStack.addArrangedSubview(image)
                break
            }
            
            hStack.addArrangedSubview(view)
        }
        
        if !hStack.arrangedSubviews.isEmpty {
            stack.addArrangedSubview(hStack)
        }
    }
    
    func zapView(_ zap: ParsedZap, text: Bool, amount: Bool = true) -> ZapGalleryChildView {
        let view = text ? ZapPillTextView(zap: zap) : (amount ? ZapPillView(zap: zap) : ZapAvatarView(zap: zap))
        view.addInteraction(GalleryZapPillMenuInteraction(galleryView: self, zap: zap))
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.delegate?.zapTapped(zap)
        }))
        return view
    }
    
    func findPillInStack(receiptId: String) -> ZapGalleryChildView? {
        stack.findAllSubviews().first(where: { $0.zap.receiptId == receiptId })
    }
    
    func animateStacks() {
        layoutIfNeeded()
        
        var zapAnimations: [String: () -> ()] = [:]
        
        let animationZapViews: [ZapGalleryChildView] = animationStack.findAllSubviews()
        for zapView in animationZapViews {
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
                
            if let textPill = zapView as? ZapPillTextView, newPill as? ZapPillTextView == nil {
                // Transform and translate text pill into regular pill
                
                let animatingPill = ZapPillTextView(zap: textPill.zap)
                addSubview(animatingPill)
                animatingPill.pin(to: textPill, edges: [.leading, .top])
                
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
                        
                        if newPill as? ZapAvatarView != nil {
                            animatingPill.amountLabel.alpha = 0
                            animatingPill.amountLabel.isHidden = true
                        }
                    }
                    
                    UIView.animate(withDuration: 12 / 30) {
                        animatingPill.label.isHidden = true
                        if newPill as? ZapAvatarView != nil {
                            animatingPill.endSpacer.isHidden = true
                            animatingPill.transform = .init(translationX: newOrigin.x - oldOrigin.x - 6, y: deltaY)
                        } else {
                            animatingPill.transform = .init(translationX: newOrigin.x - oldOrigin.x, y: deltaY)
                        }
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
        
        
        let regularZapViews: [ZapPillView] = stack.findAllSubviews()
        for pill in regularZapViews where zapAnimations[pill.zap.receiptId] == nil {
            zapAnimations[pill.zap.receiptId] = {
                pill.alpha = 0.01
                pill.transform = .init(translationX: 300, y: 0)
                
                var background: UIView?
                if pill.zap.user.isCurrentUser {
                    let view = UIView()
                    pill.insertSubview(view, at: 0)
                    view.pinToSuperview()
                    view.backgroundColor = .gold
                    view.layer.cornerRadius = 11
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
        
        for (_, anim) in zapAnimations {
            anim()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(900)) {
            self.animationStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
    }
}
