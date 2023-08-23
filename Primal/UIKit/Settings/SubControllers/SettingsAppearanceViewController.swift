//
//  SettingsAppearanceViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 15.8.23..
//

import UIKit

class SettingsAppearanceViewController: UIViewController, Themeable {
    var previewTable = UITableView()
    let mainParent = UIView()
    lazy var stack = UIStackView(axis: .vertical, [mainParent])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    
    var cellID: String { "cell"}
    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        
        previewTable.removeFromSuperview()
        previewTable = UITableView()
        stack.addArrangedSubview(previewTable)
        
        previewTable.dataSource = self
        previewTable.isUserInteractionEnabled = false
        previewTable.backgroundColor = .clear
        previewTable.separatorStyle = .none
        previewTable.register(FeedDesign.current.feedCellClass, forCellReuseIdentifier: cellID)
        previewTable.reloadData()
    }
}

private extension SettingsAppearanceViewController {
    func setupView() {
        title = "Appearance"
        
        let themeStack = UIStackView([
            ThemeButton(theme: .sunsetWave),
            ThemeButton(theme: .midnightWave),
            ThemeButton(theme: .sunriseWave),
            ThemeButton(theme: .iceWave),
        ])
        themeStack.distribution = .fillEqually
        themeStack.spacing = 14
        
        let slider = FontSliderParent()
        slider.slider.selectedNumber = FontSizeSelection.current.rawValue + 1
        slider.slider.addAction(.init(handler: { [weak slider] _ in
            guard let newValue = slider?.slider.selectedNumber, let selection = FontSizeSelection(rawValue: newValue - 1) else { return }
            FontSizeSelection.current = selection
        }), for: .valueChanged)
        
        let toggle = SettingsToggleView(title: "Use full width layout")
        toggle.toggle.setOn(FeedDesign.current == .fullWidth, animated: false)
        toggle.toggle.addAction(.init(handler: { [weak toggle] _ in
            guard let newValue = toggle?.toggle.isOn else { return }
            FeedDesign.current = newValue ? .fullWidth : .standard
        }), for: .valueChanged)
        
        let mainStack = UIStackView(axis: .vertical, [
            SettingsTitleViewVibrant(title: "THEME"),       SpacerView(height: 12),
            themeStack,                                     SpacerView(height: 20),
            BorderView(),                                   SpacerView(height: 16),
            SettingsTitleViewVibrant(title: "FONT"),        SpacerView(height: 22),
            slider,                                         SpacerView(height: 20),
            BorderView(),                                   SpacerView(height: 16),
            SettingsTitleViewVibrant(title: "LAYOUT"),      SpacerView(height: 12),
            toggle,                                         SpacerView(height: 16),
            BorderView(),                                   SpacerView(height: 16),
            SettingsTitleViewVibrant(title: "PREVIEW"),     SpacerView(height: 12),
        ])
        mainParent.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical)
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .vertical, padding: 12, safeArea: true)
        
        updateTheme()
    }
}

extension SettingsAppearanceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let post = ParsedContent(
            post: .init(
                id: "",
                pubkey: "",
                created_at: Date().timeIntervalSince1970 - (18 * 60),
                tags: [],
                content: "Welcome to #Nostr! A magical place where you can speak freely and truly own your account, content, and followers. ✨",
                sig: "",
                likes: 56,
                mentions: 14,
                replies: 4,
                zaps: 2,
                satszapped: 2400,
                score24h: 2,
                reposts: 14
            ),
            user: .init(data: .init(
                id: "",
                pubkey: "",
                npub: "",
                name: "preston",
                about: "",
                picture: "https://primal.b-cdn.net/media-cache?s=m&a=1&u=https%3A%2F%2Fi.imgur.com%2FXf8iV9G.gif",
                nip05: "preston@primal.net",
                banner: "",
                displayName: "preston",
                location: "",
                lud06: "",
                lud16: "",
                website: "",
                tags: [],
                created_at: 0,
                sig: ""
            ))
        )
        post.text = "Welcome to #Nostr! A magical place where you can speak freely and truly own your account, content, and followers. ✨"
        post.hashtags = [.init(position: 11, length: 6, text: "#Nostr", reference: "#Nostr")]
        post.buildContentString()
        
        (cell as? FeedCell)?.update(post,
            didLike: true,
            didRepost: true,
            didZap: false,
            isMuted: false
        )
        
        return cell
    }
    
    
}
