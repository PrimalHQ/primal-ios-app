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
    let themeExplanation = SettingsToggleView(title: "Automatically set Dark or Light mode based on your device settings.")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    var cellID: String = "cell"
    func updateTheme() {
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        
        cellID = "cell" + UUID().uuidString.prefix(10)
        previewTable.register(FeedDesign.current.feedCellClass, forCellReuseIdentifier: cellID)
        previewTable.reloadData()

        themeExplanation.toggle.setOn(ContentDisplaySettings.autoDarkMode, animated: false)
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
        
        themeExplanation.toggle.setOn(ContentDisplaySettings.autoDarkMode, animated: false)
        themeExplanation.toggle.addAction(.init(handler: { [weak themeExplanation] _ in
            guard let newValue = themeExplanation?.toggle.isOn else { return }
            ContentDisplaySettings.autoDarkMode = newValue
            ThemingManager.instance.setStartingTheme()
        }), for: .valueChanged)
        
        previewTable.dataSource = self
        previewTable.isUserInteractionEnabled = false
        previewTable.backgroundColor = .clear
        previewTable.separatorStyle = .none
        
        let previewParent = UIView()
        previewParent.addSubview(previewTable)
        previewTable.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: -24)
        
        let mainStack = UIStackView(axis: .vertical, [
            SpacerView(height: 12, priority: .defaultLow),
            SettingsTitleViewVibrant(title: "THEME"),       SpacerView(height: 12, priority: .defaultLow),
            themeStack,                                     SpacerView(height: 20, priority: .defaultLow),
            themeExplanation,                               SpacerView(height: 20, priority: .defaultHigh),
            BorderView(),                                   SpacerView(height: 16, priority: .defaultHigh),
            SettingsTitleViewVibrant(title: "FONT"),        SpacerView(height: 22, priority: .defaultLow),
            slider,                                         SpacerView(height: 20, priority: .defaultHigh),
            BorderView(),                                   SpacerView(height: 16, priority: .defaultHigh),
            SettingsTitleViewVibrant(title: "LAYOUT"),      SpacerView(height: 12, priority: .defaultLow),
            toggle,                                         SpacerView(height: 16, priority: .defaultHigh),
            BorderView(),                                   SpacerView(height: 16, priority: .defaultHigh),
            SettingsTitleViewVibrant(title: "PREVIEW"),     SpacerView(height: 12, priority: .defaultLow),
            previewParent
        ])
        mainParent.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .horizontal, padding: 24).pinToSuperview(edges: .vertical)
        
        previewTable.heightAnchor.constraint(greaterThanOrEqualToConstant: 190).isActive = true
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.pinToSuperview(edges: [.horizontal, .top], safeArea: true).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        scrollView.addSubview(stack)
        stack.pinToSuperview()
        stack.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        stack.heightAnchor.constraint(equalToConstant: 650).isActive = true
        
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
                sig: "",
                deleted: false
            ))
        )
        post.text = "Welcome to #Nostr! A magical place where you can speak freely and truly own your account, content, and followers. ✨"
        post.hashtags = [.init(position: 11, length: 6, text: "#Nostr", reference: "#Nostr")]
        post.buildContentString()
        
        (cell as? FeedCell)?.update(post)
        
        return cell
    }
    
    
}
