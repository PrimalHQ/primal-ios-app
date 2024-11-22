//
//  PremiumManageNameController.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.11.24..
//

import Combine
import UIKit
import FLAnimatedImage

class PremiumManageNameController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []
    
    let pickedName: String
    init(pickedName: String) {
        self.pickedName = pickedName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

private extension PremiumManageNameController {
    func setup() {
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        title = "Change Primal name"
        
        let table = PremiumSearchTableView()
        
        let contentStack = UIStackView(axis: .vertical, [])
        contentStack.distribution = .equalSpacing
        
        let actionButton = LargeRoundedButton(title: "Change Primal Name Now")
        
        let mainStack = UIStackView(axis: .vertical, [
            table,
            UIView(),
            actionButton
        ])
        
        if let userStack = userStackView() {
            mainStack.insertArrangedSubview(userStack, at: 0)
            mainStack.setCustomSpacing(24, after: userStack)
        }
        
        view.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .horizontal, padding: 24)
            .pinToSuperview(edges: .top, padding: 70, safeArea: true)
            .pinToSuperview(edges: .bottom, padding: 20, safeArea: true)
        
        table.addressRow.infoLabel.text = pickedName + "@primal.net"
        table.lightningRow.infoLabel.text = table.addressRow.infoLabel.text
        table.profileRow.infoLabel.text = "primal.net/" + pickedName
        
        let oldPremiumState = WalletManager.instance.premiumState
        
        actionButton.addAction(.init(handler: { [weak self] _ in
            guard let self, let content = ["name": pickedName].encodeToString(), let event = NostrObject.create(content: content, kind: 30078) else { return }
            
            actionButton.isEnabled = false
            
            SocketRequest(name: "membership_change_name", payload: ["event_from_user": event.toJSON()], connection: .wallet)
                .publisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] res in
                    guard let self else { return }
                    
                    if let error = res.message {
                        print(error)
                        actionButton.isEnabled = true
                        return
                    }
                    
                    actionButton.title = "Primal Name Changed"
                    actionButton.isEnabled = false
                    title = "Primal name changed"
                    
                    if var user = IdentityManager.instance.parsedUser?.data.profileData {
                        var shouldUpdate = false
                        if user.lud16 == oldPremiumState?.lightning_address {
                            user.lud16 = pickedName + "@primal.net"
                            shouldUpdate = true
                        }
                        
                        if user.nip05 == oldPremiumState?.nostr_address {
                            user.nip05 = pickedName + "@primal.net"
                            shouldUpdate = true
                        }
                        
                        if shouldUpdate {
                            IdentityManager.instance.updateProfile(user) { _ in
                                IdentityManager.instance.requestUserProfile(local: false)
                            }
                        }
                    }
                    
                    WalletManager.instance.refreshPremiumState()
                    
                    guard let premium = navigationController?.viewControllers.first(where: { $0 as? PremiumViewController != nil }) else {
                        navigationController?.viewControllers.removeAll(where: { $0 as? PremiumSearchNameController != nil })
                        return
                    }
                    navigationController?.popToViewController(premium, animated: true)
                }
                .store(in: &cancellables)
        }), for: .touchUpInside)
    }
    
    func userStackView() -> UIView? {
        guard let user = IdentityManager.instance.parsedUser else { return nil }
        let image = FLAnimatedImageView().constrainToSize(80)
        image.layer.cornerRadius = 40
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.setUserImage(user, size: .init(width: 80, height: 80))
        
        let checkbox = VerifiedView().constrainToSize(24)
        
        let nameLabel = UILabel(pickedName, color: .foreground, font: .appFont(withSize: 22, weight: .bold))
        let nameStack = UIStackView([nameLabel, checkbox])
        nameStack.alignment = .center
        nameStack.spacing = 6
                
        let userStack = UIStackView(axis: .vertical, [image, SpacerView(height: 16), nameStack])
        userStack.alignment = .center
        
        userStack.setCustomSpacing(24, after: nameStack)
        userStack.addArrangedSubview(UILabel("Your Primal Name is available!", color: .init(rgb: 0x52CE0A), font: .appFont(withSize: 16, weight: .semibold)))
        
        return userStack
    }
}
