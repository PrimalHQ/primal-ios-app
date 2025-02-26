//
//  ZappingViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.10.24..
//

import UIKit
import StoreKit

protocol AnimatingZappingView {
    var zapIconToPin: UIView? { get }
    var animatingZappingButton: FeedZapButton? { get }
}

protocol ZappableReferenceObject: PostingReferenceObject {
    var currentSatsZapped: Int { get }
    var userToZap: ParsedUser { get }
    var description: String { get }
    var referenceTime: Double? { get }
}

extension ZappableReferenceObject {
    var referencePubkey: String { userToZap.data.pubkey }
}

protocol ZappingViewController: UIViewController {
    func reloadViewAfterZap()
}

extension ParsedContent: ZappableReferenceObject {
    var reference: (tagLetter: String, universalID: String)? { post.reference }
    
    var currentSatsZapped: Int { post.satszapped }
    
    var userToZap: ParsedUser { user }
    
    var description: String { post.content }
    
    var referenceTime: Double? { post.created_at }
}

extension Article: ZappableReferenceObject {
    var currentSatsZapped: Int { stats.satszapped ?? 0 }
    
    var userToZap: ParsedUser { user }
    
    var description: String { summary ?? event.content }
    
    var referenceTime: Double? { event.created_at }
}

extension ParsedUser: ZappableReferenceObject {
    var currentSatsZapped: Int { 0 }
    var userToZap: ParsedUser { self }
    var description: String { data.about }
    
    var reference: (tagLetter: String, universalID: String)? { nil }
    var referenceTime: Double? { nil }
}

extension ZappingViewController {
    func zapFromView(_ zapView: AnimatingZappingView, reference: ZappableReferenceObject, showPopup: Bool) {
        let postUser = reference.userToZap.data
        if postUser.address == nil {
            showErrorMessage(title: "Can’t Zap", "The user you're trying to zap didn't set up their lightning wallet")
            return
        }
        
        guard let hasWallet = WalletManager.instance.userHasWallet else { return } // Unknown
        guard hasWallet else {
            let popup = PopupMenuViewController(message: "To zap people on Nostr, you need to activate your wallet and get some sats.", actions: [
                .init(title: "Go to wallet", image: .init(named: "selectedTabIcon-wallet"), handler: { [weak self] _ in
                    self?.mainTabBarController?.switchToTab(.wallet)
                })
            ])
            present(popup, animated: true)
            return
        }
        
        if showPopup {
            let popup = PopupZapSelectionViewController(entityToZap: postUser) { [weak self] in self?.doZapFromView(zapView, reference: reference, amount: $0, message: $1) }
            present(popup, animated: true)
            return
        }
        
        let zapAmount = IdentityManager.instance.userSettings?.zapDefault?.amount ?? 20
        let zapMessage = IdentityManager.instance.userSettings?.zapDefault?.message ?? ""
        doZapFromView(zapView, reference: reference, amount: zapAmount, message: zapMessage)
    }
    
    private func doZapFromView(_ zapView: AnimatingZappingView, reference: ZappableReferenceObject,  amount: Int, message: String) {
        let newZapAmount = reference.currentSatsZapped + amount
        
        if WalletManager.instance.balance < amount {
            let popup = PopupMenuViewController(message: "Insufficient funds to perform this zap", actions: [
                .init(title: "Go to wallet", image: .init(named: "selectedTabIcon-wallet"), handler: { [weak self] _ in
                    self?.mainTabBarController?.switchToTab(.wallet)
                })
            ])
            present(popup, animated: true)
            return
        }

        animateZap(zapView, amount: newZapAmount)

        Task { @MainActor [weak self] in
            do {
                try await WalletManager.instance.zap(object: reference, sats: amount, note: message)
                
                UserDefaults.standard.howManyZaps += 1
                if UserDefaults.standard.howManyZaps >= 3 {
                    guard let scene = self?.view.window?.windowScene else { return }
                    #if !DEBUG
                    SKStoreReviewController.requestReview(in: scene)
                    #endif
                }
            } catch {
                if let e = error as? WalletError {
                    self?.showErrorMessage(e.message)
                } else {
                    self?.showErrorMessage("Insufficient funds for this zap. Check your wallet.")
                }
                self?.reloadViewAfterZap()
            }
        }
    }
    
    func animateZap(_ zapView: AnimatingZappingView, amount: Int) {
        zapView.animatingZappingButton?.animateTo(amount, filled: true)
        
        guard let iconToPin = zapView.zapIconToPin else { return }
        
        let animView = NoteViewController.bigZapAnimView
            
        view.addSubview(animView)
        animView
            .centerToView(iconToPin, axis: .vertical, offset: 2)
            .centerToView(iconToPin, axis: .horizontal, offset: 62)
        
        view.layoutIfNeeded()
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        animView.alpha = 1
        animView.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            UIView.animate(withDuration: 0.2) {
                animView.alpha = 0
            } completion: { _ in
                animView.removeFromSuperview()
            }
        }
    }
}
