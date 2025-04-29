//
//  SettingsMutedWordsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.4.25..
//

import Combine
import UIKit
import Kingfisher

enum MuteOption: String {
    case user = "p"
    case word = "word"
    case hashtag = "t"
    case thread = "e"
}

class SettingsMutedWordsController: UIViewController, Themeable {
    let table = UITableView()
    
    let botView = UIView()
    let botBorder = SpacerView(height: 1)
    let input = UITextField()
    let muteButton = UIButton(configuration: .accentPill(text: "mute", font: .appFont(withSize: 16, weight: .medium))).constrainToSize(height: 40)
    
    var mutedWords: [String] = []
    
    var cancellables: Set<AnyCancellable> = []
    
    let option: MuteOption
    init(option: MuteOption) {
        self.option = option
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.register(UnmuteWordCell.self, forCellReuseIdentifier: "cell")
        table.register(EmptyMuteListCell.self, forCellReuseIdentifier: "empty")
        table.separatorStyle = .none
        table.contentInset = .init(top: 60, left: 0, bottom: 0, right: 0)
        table.keyboardDismissMode = .onDrag
        
        switch option {
        case .user:
            input.placeholder = "Mute new pubkey..."
        case .word:
            input.placeholder = "Mute new word..."
        case .hashtag:
            input.placeholder = "# Mute new hashtag..."
        case .thread:
            input.placeholder = "Mute new event id..."
        }
        input.layer.cornerRadius = 20
        input.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        input.leftViewMode = .always
        input.delegate = self

        let stack = UIStackView([input, muteButton])
        stack.spacing = 8
        botView.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .top, padding: 20).pinToSuperview(edges: .bottom, padding: 10)
        botView.addSubview(botBorder)
        botBorder.pinToSuperview(edges: [.horizontal, .top])
        
        let spacer = KeyboardSizingView()
        
        let mainStack = UIStackView(axis: .vertical, [table, botView, spacer])
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .horizontal).pinToSuperview(edges: .bottom)
        
        botView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        
        spacer.updateHeightCancellable().store(in: &cancellables)
        
        muteButton.addAction(.init(handler: { [weak self] _ in self?.muteCurrentWord() }), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        mainTabBarController?.showTabBarBorder = false
        
        updateTable()
        updateTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainTabBarController?.showTabBarBorder = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mainTabBarController?.showTabBarBorder = true
    }
    
    func updateTheme() {
        botBorder.backgroundColor = .background3
        input.backgroundColor = .background3
        botView.backgroundColor = .background
        table.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        table.reloadData()
    }
    
    func muteOption(_ text: String) -> MuteManager.Option {
        switch option {
        case .word:
            return .word(text)
        case .hashtag:
            return .hashtag(text)
        case .user:
            return .user(pubkey: text)
        case .thread:
            return .thread(eventId: text)
        }
    }
    
    func updateTable() {
        mutedWords = MuteManager.instance.muteTags.filter({ $0.first == option.rawValue }).compactMap({ $0[safe: 1] }).sorted()
        table.reloadData()
    }
    
    func muteCurrentWord() {
        guard let word = input.text?.trimmingCharacters(in: .whitespaces), !word.isEmpty else { return }
        
        input.text = ""
        
        if MuteManager.instance.isMuted(muteOption(word)) { return }
        
        MuteManager.instance.toggleMuted(muteOption(word))
        updateTable()
    }
}

extension SettingsMutedWordsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { mutedWords.isEmpty ? 1 : mutedWords.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if mutedWords.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath)
            switch option {
            case .user: break
            case .word: (cell as? EmptyMuteListCell)?.label.text = "Muted words\nwill appear here"
            case .hashtag: (cell as? EmptyMuteListCell)?.label.text = "Muted hashtags\nwill appear here"
            case .thread: (cell as? EmptyMuteListCell)?.label.text = "Muted threads\nwill appear here"
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let word = mutedWords[indexPath.row]
        
        guard let cell = cell as? UnmuteWordCell else { return cell }
        
        cell.updateTheme()
        cell.delegate = self
        
        cell.nameLabel.text = word
        
        return cell
    }
}

extension SettingsMutedWordsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        muteCurrentWord()
        textField.resignFirstResponder()
        return false
    }
}

extension SettingsMutedWordsController: UnmuteWordCellDelegate {
    func unmuteButtonPressed(_ cell: UnmuteWordCell) {
        guard let indexPath = table.indexPath(for: cell), let word = mutedWords[safe: indexPath.row] else { return }

        MuteManager.instance.toggleMuted(muteOption(word))
        updateTable()
    }
}
