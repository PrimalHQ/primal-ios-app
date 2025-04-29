//
//  NoteZapsViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.4.24..
//

import Combine
import UIKit
import SafariServices

class NoteZapsViewController: UIViewController, Themeable {
    private let table = UITableView()
    private let emptyView = EmptyTableView(title: "There are no zaps for this note yet")
    
    var zaps: [ParsedZap] = [] {
        didSet {
            table.reloadData()
            
            emptyView.isHidden = !zaps.isEmpty
        }
    }
    var cancellables: Set<AnyCancellable> = []
    
    let noteId: String
    init(noteId: String) {
        self.noteId = noteId
        
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.register(ZapTableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(emptyView)
        emptyView.centerToSuperview()
        emptyView.isHidden = true
        emptyView.refresh.addAction(.init(handler: { [unowned self] _ in
            refresh()
        }), for: .touchUpInside)
        
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        table.reloadData()
    }
    
    func refresh() {
        NoteZapsRequest(noteId: noteId, limit: 100).publisher()
            .receive(on: DispatchQueue.main)
            .assign(to: \.zaps, onWeak: self)
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        table.backgroundColor = .background
    }
}

extension NoteZapsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { zaps.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? ZapTableViewCell)?.updateForZap(zaps[indexPath.row], delegate: self)
        return cell
    }
}

extension NoteZapsViewController: ZapTableViewCellDelegate {
    func messageTappedInZapCell(_ cell: ZapTableViewCell) {
        guard
            let index = table.indexPath(for: cell)?.row,
            let zap = zaps[safe: index],
            !zap.message.isEmpty, zap.message.isValidURL,
            let url = URL(string: zap.message),
            UIApplication.shared.canOpenURL(url)
        else { return }
        
        UIApplication.shared.open(url)
    }
    
    func contextMenuForZapCell(_ cell: ZapTableViewCell) -> UIMenu? {
        guard
            let index = table.indexPath(for: cell)?.row,
            let zap = zaps[safe: index],
            !zap.message.isEmpty
        else { return nil }
        
        
        var items: [UIAction] = [
            UIAction(title: NSLocalizedString("Copy text", comment: ""), image: UIImage(named: "MenuCopyText")) { [weak self] _ in
                UIPasteboard.general.string = zap.message
                
                self?.view.showToast("Copied!", extraPadding: 0)
            },
        ]
        
        if zap.message.isValidURL, let url = URL(string: zap.message) {
            items.append(.init(title: "Open URL", image: UIImage(named: "MenuCopyLink")) { [weak self] _ in
                self?.present(SFSafariViewController(url: url), animated: true)
            })
        }
        
        return UIMenu(title: "", children: items)
    }
}

extension NoteZapsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        show(ProfileViewController(profile: zaps[indexPath.row].user), sender: nil)
    }
}

