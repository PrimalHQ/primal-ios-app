//
//  SettingsMutedViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.9.23..
//

import Combine
import UIKit
import Kingfisher

class SettingsMutedViewController: UIViewController, Themeable {
    let table = UITableView()
    
    var mutedUserNPUBs: [String] = []
    var loadedUsers: [String: PrimalUser] = [:]
    
    var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Muted Accounts"
        
        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        
        table.dataSource = self
        table.delegate = self
        table.register(UnmuteUserCell.self, forCellReuseIdentifier: "cell")
        table.register(EmptyMuteListCell.self, forCellReuseIdentifier: "empty")
        table.separatorStyle = .none
        
        updateTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        mutedUserNPUBs = MuteManager.instance.muteList.sorted()
        
        SocketRequest(name: "user_infos", payload: .object(["pubkeys": .array(mutedUserNPUBs.map { .string($0) })])).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }
                
                result.users.forEach { npub, user in
                    self.loadedUsers[npub] = user
                }
                
                self.mutedUserNPUBs.sort { npub1, npub2 in
                    let first = self.loadedUsers[npub1]?.firstIdentifier ?? npub1
                    let second = self.loadedUsers[npub2]?.firstIdentifier ?? npub2
                    return first < second
                }
                
                self.table.reloadData()
            }
            .store(in: &cancellables)
    }
    
    func updateTheme() {
        table.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        table.reloadData()
    }
}

extension SettingsMutedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { mutedUserNPUBs.isEmpty ? 1 : (loadedUsers.isEmpty ? 0 : mutedUserNPUBs.count) }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if mutedUserNPUBs.isEmpty { return tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath) }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let npub = mutedUserNPUBs[indexPath.row]
        
        guard let cell = cell as? UnmuteUserCell else { return cell }
        
        cell.updateTheme()
        cell.delegate = self
        
        guard let nostrData = loadedUsers[npub] else {
            cell.profileImage.imageView.image = UIImage(named: "Profile")
            cell.nameLabel.text = npub
            cell.usernameLabel.text = nil
            return cell
        }
        
        cell.profileImage.imageView.kf.setImage(with: URL(string: nostrData.picture), placeholder: UIImage(named: "Profile"), options: [
            .processor(DownsamplingImageProcessor(size: CGSize(width: 48, height: 48))),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        
        cell.nameLabel.text = nostrData.name
        cell.usernameLabel.text = nostrData.nip05
        
        return cell
    }
}

extension SettingsMutedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = loadedUsers[mutedUserNPUBs[indexPath.row]] else { return }
        let profile = ProfileViewController(profile: .init(data: user))
        show(profile, sender: nil)
    }
}

extension SettingsMutedViewController: UnmuteUserCellDelegate {
    func unmuteButtonPressed(_ cell: UnmuteUserCell) {
        guard let indexPath = table.indexPath(for: cell) else { return }
        
        let index = indexPath.row
        
        MuteManager.instance.toggleMute(mutedUserNPUBs[index])
        mutedUserNPUBs.remove(at: index)
        
        if mutedUserNPUBs.isEmpty {
            table.reloadData()
        } else {
            table.deleteRows(at: [indexPath], with: .left)
        }
    }
}


final class EmptyMuteListCell: UITableViewCell, Themeable {
    let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTheme() {
        contentView.backgroundColor = .background
        
        label.textColor = .foreground
    }
}

private extension EmptyMuteListCell {
    func setup() {
        selectionStyle = .none
        
        contentView.addSubview(label)
        label
            .pinToSuperview(edges: .horizontal, padding: 60)
            .pinToSuperview(edges: .vertical, padding: 100)
        
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = .appFont(withSize: 30, weight: .bold)
        label.text = "Muted accounts\nwill appear here"
        
        updateTheme()
    }
}
