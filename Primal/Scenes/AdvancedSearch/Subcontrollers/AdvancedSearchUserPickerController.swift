//
//  AdvancedSearchUserPickerController.swift
//  Primal
//
//  Created by Pavle Stevanović on 14.10.24..
//

import Combine
import UIKit
import SafariServices

final class AdvancedSearchUserPickerController: UIViewController, Themeable {
    let navigationExtender = SpacerView(height: 7)
    let navigationBorder = SpacerView(height: 1)
    let searchView = SearchInputView()
    let userTable = UITableView()
    let pickedCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).constrainToSize(height: 36)
    let anyoneView = UIView()
    let applyButton = UIButton.largeRoundedButton(title: "Apply")
    
    @Published var pickedUsers: [ParsedUser]
    
    @Published var userSearchText: String = ""
    
    var textSearch: String?
    
    var cancellables: Set<AnyCancellable> = []
    
    var users: [ParsedUser] = [] {
        didSet {
            userTable.reloadData()
        }
    }
    
    let callback: ([ParsedUser]) -> Void
    init(current: [ParsedUser] = [], title: String, callback: @escaping ([ParsedUser]) -> Void) {
        pickedUsers = current
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
        searchView.inputField.placeholder = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.transform = .identity
        
        searchView.inputField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func updateTheme() {
        userTable.reloadData()
        searchView.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background4
        navigationExtender.backgroundColor = .background4
        navigationBorder.backgroundColor = .background3
    }
}

private extension AdvancedSearchUserPickerController {
    func setup() {
        let inputParent = UIView()
        inputParent.addSubview(searchView)
        searchView.pinToSuperview(padding: 20)
        
        let applyParent = UIView()
        applyParent.addSubview(applyButton)
        applyButton.pinToSuperview(edges: [.horizontal, .top], padding: 20)
        applyParent.isHidden = true
        
        let stack = UIStackView(arrangedSubviews: [pickedCollectionView, inputParent, navigationBorder, userTable, applyParent])
        view.addSubview(stack)
        stack.axis = .vertical
        stack.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .horizontal).pinToSuperview(edges: .bottom)
        applyButton.pin(to: view, edges: .bottom, padding: 20, safeArea: true)
        
        userTable.register(UserInfoTableCell.self, forCellReuseIdentifier: "userCell")
        userTable.separatorStyle = .none
        userTable.delegate = self
        userTable.dataSource = self
        userTable.backgroundColor = .background4

        pickedCollectionView.register(UserPickerCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        pickedCollectionView.dataSource = self
        pickedCollectionView.delegate = self
        pickedCollectionView.showsHorizontalScrollIndicator = false
        if let flow = pickedCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .horizontal
            flow.minimumInteritemSpacing = 8
            flow.itemSize = .init(width: 48, height: 36)
            flow.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        }
        pickedCollectionView.backgroundColor = .background4
        
        view.addSubview(anyoneView)
        anyoneView
            .constrainToSize(height: 36)
            .pin(to: pickedCollectionView, edges: .top).pin(to: pickedCollectionView, edges: .leading, padding: 20)
        let label = UILabel()
        label.text = "Anyone"
        anyoneView.addSubview(label)
        label.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 16)
        label.font = .appFont(withSize: 16, weight: .regular)
        label.textColor = Theme.inverse.foreground6
        anyoneView.layer.cornerRadius = 18
        anyoneView.layer.borderColor = UIColor.foreground6.cgColor
        anyoneView.layer.borderWidth = 1
        
        searchView.inputField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        applyButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            navigationController?.popViewController(animated: true)
            callback(self.pickedUsers)
        }), for: .touchUpInside)
        
        updateTheme()
        setBindings()
    }
    
    func setBindings() {
        $userSearchText
            .flatMap { [weak self] in
                self?.userTable.reloadData()
                
                return SmartContactsManager.instance.userSearchPublisher($0)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] users in
                self?.users = users
            })
            .store(in: &cancellables)
        
        if let applyButtonSuperview = applyButton.superview {
            $pickedUsers.map({ _ in false }).assign(to: \.isHidden, on: applyButtonSuperview).store(in: &cancellables)
        }
        $pickedUsers.map({ !$0.isEmpty }).assign(to: \.isHidden, on: anyoneView).store(in: &cancellables)
        $pickedUsers.sink(receiveValue: { [weak self] _ in self?.pickedCollectionView.reloadData() }).store(in: &cancellables)
    }
    
    func doSearch() {
        if userSearchText.isEmpty { return }
        
        if userSearchText.hasPrefix("npub1") && userSearchText.count == 63 {
            notify(.primalProfileLink, userSearchText)
            navigationController?.popViewController(animated: true)
            return
        }
        
        if userSearchText.hasPrefix("note1") && userSearchText.count == 63, let text = userSearchText.noteIdToHex() {
            notify(.primalNoteLink, text)
            navigationController?.popViewController(animated: true)
            return
        }
        
        if let url = URL(string: userSearchText), url.scheme?.lowercased() == "https" {
            present(SFSafariViewController(url: url), animated: true)
            navigationController?.popViewController(animated: true)
            return
        }
        
        let feed = RegularFeedViewController(feed: FeedManager(search: userSearchText))
        show(feed, sender: nil)
    }
    
    @objc func textFieldDidChange() {
        userSearchText = searchView.inputField.text ?? ""
    }
}

extension AdvancedSearchUserPickerController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        (cell as? UserInfoTableCell)?.update(user: users[indexPath.row])
        cell.contentView.backgroundColor = .background4
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = users[safe: indexPath.row] else { return }
        pickedUsers.removeAll(where: { user.data.pubkey == $0.data.pubkey })
        pickedUsers.insert(user, at: 0)
    }
}

extension AdvancedSearchUserPickerController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { pickedUsers.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        (cell as? UserPickerCollectionViewCell)?.setupWithUser(pickedUsers[indexPath.item])
        return cell
    }
}

extension AdvancedSearchUserPickerController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pickedUsers.remove(at: indexPath.item)
    }
}

final class SearchInputView: UIView, Themeable {
    let inputField = UITextField()
    let icon = UIImageView(image: UIImage(named: "searchIconSmall"))
    
    init() {
        super.init(frame: .zero)
        
        constrainToSize(height: 36)
        layer.cornerRadius = 18
        
        let stack = UIStackView(arrangedSubviews: [icon, inputField])
        stack.alignment = .center
        stack.spacing = 8
        
        addSubview(stack)
        stack.centerToSuperview().pinToSuperview(edges: .horizontal, padding: 12)
        
        icon.setContentHuggingPriority(.required, for: .horizontal)
        
        inputField.font = .appFont(withSize: 16, weight: .medium)
        inputField.autocorrectionType = .no
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        backgroundColor = .background3
        inputField.textColor = .foreground
        icon.tintColor = .foreground
    }
}
