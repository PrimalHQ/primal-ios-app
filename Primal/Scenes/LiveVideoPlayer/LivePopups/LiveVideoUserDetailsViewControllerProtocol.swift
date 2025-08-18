//
//  LiveVideoUserDetailsViewControllerProtocol.swift
//  Primal
//
//  Created by Pavle Stevanović on 13. 8. 2025..
//

import UIKit

protocol LiveVideoUserDetailsViewControllerProtocol: UIViewController {
    var userForDetails: ParsedUser { get }
    
    var followButton: BrightSmallButton { get }
    var unfollowButton: RoundedSmallButton { get }
}

extension LiveVideoUserDetailsViewControllerProtocol {
    var livePlayerVC: LiveVideoPlayerController? {
        parent as? LiveVideoPlayerController
    }
    
    func updateFollowButtons() {
        let isFollowing = FollowManager.instance.isFollowing(userForDetails.data.pubkey)
        followButton.isHidden = isFollowing
        unfollowButton.isHidden = !isFollowing
    }
    
    func followTapped() {
        FollowManager.instance.sendFollowEvent(userForDetails.data.pubkey)
        updateFollowButtons()
    }
    
    func unfollowTapped() {
        FollowManager.instance.sendUnfollowEvent(userForDetails.data.pubkey)
        updateFollowButtons()
    }
    
    func qrTapped() {
        guard let nav: UINavigationController = RootViewController.instance.findInChildren() else { return }
        let user = userForDetails
        livePlayerVC?.dismiss(animated: true) {
            nav.pushViewController(ProfileQRController(user: user), animated: true)
        }
    }
    
    func zapTapped() {
        guard let nav: UINavigationController = RootViewController.instance.findInChildren() else { return }
        let user = userForDetails
        livePlayerVC?.dismiss(animated: true) {
            nav.pushViewController(WalletSendViewController(.user(user, startingAmount: 0)), animated: true)
        }
    }
    
    func messageTapped() {
        guard let nav: UINavigationController = RootViewController.instance.findInChildren() else { return }
        let user = userForDetails
        livePlayerVC?.dismiss(animated: true) {
            nav.pushViewController(ChatViewController(user: user, chatManager: .init()), animated: true)
        }
    }
    
    func openUserProfile() {
        guard let nav: UINavigationController = RootViewController.instance.findInChildren() else { return }
        let user = userForDetails
        livePlayerVC?.dismiss(animated: true) {
            nav.pushViewController(ProfileViewController(profile: user), animated: true)
        }
    }
    
    func dismissAsLivePopup() {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .init(translationX: 0, y: 600)
        } completion: { _ in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}
