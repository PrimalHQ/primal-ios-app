//
//  SettingsMediaUploadsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.4.25..
//

import Combine
import UIKit

extension String {
    static let blossomDefaultServer = "https://blossom.primal.net"
}

final class SettingsMediaUploadsController: UIViewController, SettingsController, Themeable {
    private let blossomServerInput = WebConnectInputView()
    private let mirrorInput = WebConnectInputView()
    private let mirrorStack = UIStackView(axis: .vertical, [])
    private let mirrorListStack = UIStackView(axis: .vertical, [])
    
    private var cancellables: Set<AnyCancellable> = []
    private var viewCancellables: Set<AnyCancellable> = []
    
    @Published var primaryServer: String = .blossomDefaultServer
    @Published var mirrors: [String] = []
    
    @Published var enableMirror: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}

private extension SettingsMediaUploadsController {
    func setup() {
        title = "Media Uploads"
        updateTheme()
        
        let allServers = BlossomServerManager.instance.serversForUser(pubkey: IdentityManager.instance.userHexPubkey) ?? []
        primaryServer = allServers.first ?? primaryServer
        mirrors = Array(allServers.dropFirst())
        
        enableMirror = mirrors.isEmpty == false
        
        blossomServerInput.input.placeholder = "enter media server url"
        mirrorInput.input.placeholder = "enter media mirror server url"

        let regularConnection = SettingsNetworkStatusView(title: primaryServer)
        regularConnection.status = true
        
        let regularConnectionParent = ThemeableView().constrainToSize(height: 44).setTheme { $0.backgroundColor = .background3 }
        regularConnectionParent.addSubview(regularConnection)
        regularConnection.pinToSuperview(edges: .horizontal, padding: 12).centerToSuperview()
        regularConnectionParent.layer.cornerRadius = 12
        
        let restoreBlossomButton = RightAlignedAccentButton(title: "restore default media server")
        
        let enableMirrorSwitch = SettingsSwitchView("Enable media mirrors")
        enableMirrorSwitch.switchView.isOn = enableMirror
        enableMirrorSwitch.switchView.addAction(.init(handler: { [weak self, weak enableMirrorSwitch] _ in
            self?.enableMirror = enableMirrorSwitch?.switchView.isOn ?? false
        }), for: .valueChanged)
        
        let stack = UIStackView(axis: .vertical, [
            titleLabel("MEDIA SERVER"), SpacerView(height: 16),
            regularConnectionParent, SpacerView(height: 20),
            SettingsTitleView(title: "SWITCH MEDIA SERVER"), SpacerView(height: 8),
            blossomServerInput, SpacerView(height: 16),
            restoreBlossomButton, SpacerView(height: 8),
            SettingsBorder(), SpacerView(height: 24),
            titleLabel("MEDIA MIRRORS"), SpacerView(height: 8),
            enableMirrorSwitch, SpacerView(height: 10),
            descLabel("You can enable one or more media mirror servers. When enabled, your uploads to the primary media server will be automatically copied to the mirror(s)."), SpacerView(height: 8),
            mirrorStack, SpacerView(height: 16)
        ])
        
        mirrorListStack.layer.cornerRadius = 12
        mirrorListStack.clipsToBounds = true
        
        [mirrorListStack, SpacerView(height: 20), SettingsTitleView(title: "ADD A MEDIA MIRROR SERVER"), SpacerView(height: 8), mirrorInput]
            .forEach { mirrorStack.addArrangedSubview($0) }
        
        mirrorStack.isHidden = !enableMirror
        
        let scroll = UIScrollView()
        
        view.addSubview(scroll)
        scroll.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .bottom, padding: 54, safeArea: true)
        scroll.addSubview(stack)
        stack.pinToSuperview(padding: 24)
        stack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48).isActive = true
        
        [mirrorInput, blossomServerInput].forEach { $0.input.isUserInteractionEnabled = false }
        mirrorInput.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            let vc = SettingsEditMediaUploadsController(title: "ADD A MEDIA MIRROR SERVER", completion: { mirrorServer in
                self?.mirrors.append(mirrorServer)
            })
            self?.navigationController?.fadeTo(vc)
            
            vc.blossomServerInput.input.placeholder = "enter media server url"
        }))
        blossomServerInput.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            let vc = SettingsEditMediaUploadsController(title: "SWITCH MEDIA SERVER", completion: { blossomServer in
                self?.primaryServer = blossomServer
            })
            self?.navigationController?.fadeTo(vc)
            vc.blossomServerInput.input.placeholder = "enter media mirror server url"
        }))
        
        restoreBlossomButton.addAction(.init(handler: { [weak self] _ in
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to restore the default media server?", preferredStyle: .alert)
            alert.addAction(.init(title: "Restore", style: .destructive) { _ in
                self?.primaryServer = .blossomDefaultServer
            })
            alert.addAction(.init(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        }), for: .touchUpInside)
        
        $enableMirror.removeDuplicates().dropFirst().sink { [weak self] enable in
            UIView.transition(with: stack, duration: 0.3, options: .transitionCrossDissolve) {
                self?.mirrorStack.isHidden = !enable
                self?.mirrorStack.alpha = enable ? 1 : 0
            }
        }
        .store(in: &cancellables)
        
        $primaryServer.sink { value in
            regularConnection.title = value
        }
        .store(in: &cancellables)
        
        $mirrors.sink { [weak self] mirrors in
            guard let self else { return }
            mirrorListStack.subviews.forEach { $0.removeFromSuperview() }
            
            for mirror in mirrors {
                let view = relayConnectionView(mirror, last: mirror == mirrors.last)
                mirrorListStack.addArrangedSubview(view)
            }
        }
        .store(in: &viewCancellables)
        
        Publishers.CombineLatest3($primaryServer, $mirrors, $enableMirror)
            .dropFirst()
            .sink { server, mirrors, enableMirror in
                guard
                    let ev = NostrObject.blossomSettings(servers: [server] + (enableMirror ? mirrors : [])),
                    let json = ev.toJSON().objectValue
                else {
                    print("Error creating blossom event")
                    return
                }
                
                BlossomServerManager.instance.addBlossomInfo(json)
                
                RelaysPostbox.instance.request(ev, successHandler: { _ in
                    // do nothing
                }, errorHandler: {
                    
                })
            }
            .store(in: &cancellables)
    }
    
    func titleLabel(_ text: String) -> UILabel {
        let label = ThemeableLabel().setTheme { $0.textColor = .foreground }
        label.text = text
        label.font = .appFont(withSize: 18, weight: .semibold)
        return label
    }
    
    func relayConnectionView(_ mirror: String, last: Bool) -> UIView {
        let view = SettingsNetworkStatusListView(title: mirror, onDelete: { [weak self] in
            let alert = UIAlertController(title: "Are you sure?", message: "Do you want to delete this mirror?\n\(mirror)", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .destructive) { _ in
                self?.mirrors.removeAll { $0 == mirror }
            })
            alert.addAction(.init(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
        })
        view.border.isHidden = last
        view.backgroundColor = .background3
        return view
    }
}
