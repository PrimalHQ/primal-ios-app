//
//  PremiumListController.swift
//  Primal
//
//  Created by Pavle Stevanović on 5.2.25..
//

import Combine
import UIKit

struct PremiumListItem {
    let index: Int
    let user: ParsedUser
    let since: Date
}

struct PremiumListServerResponse: Codable {
    let pubkey: String
    let premium_since: Double
    let index: Double
}

class PremiumListController: PrimalPageController {
    init() {
        let buyButton = UIButton(configuration: .accent("Get Primal Premium", font: .appFont(withSize: 14, weight: .regular)))
        let aboutParent = UIView()
        aboutParent.addSubview(buyButton)
        buyButton.centerToSuperview(axis: .vertical).pinToSuperview(edges: .trailing, padding: 0)
        
        super.init(
            tabs: [
                ("LATEST", { PremiumListTableController() }),
            ],
            extraViews: [aboutParent]
        )
        
        tabSelectionView.stack.spacing = 22
        tabSelectionView.distribution = .fill
        
        title = "Premium Users"
        
        buyButton.addAction(.init(handler: { [weak self] _ in
            self?.show(PremiumViewController(), sender: nil)
        }), for: .touchUpInside)
        buyButton.transform = .init(translationX: 0, y: -3)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}


class PremiumListTableController: UITableViewController, Themeable {
    var legends: [PremiumListItem] = [] { didSet { tableView.reloadData() } }
    
    var cancellables: Set<AnyCancellable> = []
    
    let manager = PremiumListFeedManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(PremiumListTableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.contentInset = .init(top: 60, left: 0, bottom: 60, right: 0)
        tableView.separatorStyle = .none
        
        manager.$users.assign(to: \.legends, onWeak: self).store(in: &cancellables)
//
//        SocketRequest(name: "membership_premium_leaderboard", payload: [
//            "limit": 1000,
//        ])
//        .publisher()
//        .receive(on: DispatchQueue.main)
//        .sink { [weak self] res in
//            guard
//                let listResponse = res.events.first(where: { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.primalPremiumInfoList.rawValue }),
//                let items: [PremiumListServerResponse] = listResponse["content"]?.stringValue?.decode()
//            else {
//                return
//            }
//            
//            let users = res.getSortedUsers()
//            
//            let premiumUsers: [PremiumListItem] = items.enumerated().map { (index, item) in
//                .init(
//                    index: Int(item.index),
//                    user: users.first(where: { $0.data.pubkey == item.pubkey }) ?? .init(data: .init(pubkey: item.pubkey)),
//                    since: Date(timeIntervalSince1970: item.premium_since)
//                )
//            }
//            
//            self?.legends = premiumUsers
//        }
//        .store(in: &cancellables)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = legends[safe: indexPath.row]?.user else { return }
        show(ProfileViewController(profile: user), sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { legends.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? PremiumListTableViewCell)?.setup(item: legends[indexPath.row])
        
        if indexPath.row > legends.count - 20 {
            manager.requestNewPage()
        }
        
        return cell
    }
    
    func updateTheme() {
        tableView.reloadData()
    }
}


class PremiumListTableViewCell: UITableViewCell, Themeable {
    let userImage = UserImageView(height: 36)
    let nameLabel = UILabel()
    let check = VerifiedView().constrainToSize(16)
    let sinceLabel = UILabel()
    let satsLabel = UILabel()
    let satsInfoLabel = UILabel("sats", color: .foreground4, font: .appFont(withSize: 14, weight: .regular))
    let borderView = SpacerView(height: 1)
    
    let dateFormatter = DateFormatter()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let nameStack = UIStackView([nameLabel, check])
        let centerStack = UIStackView(axis: .vertical, [nameStack, sinceLabel])
        let satsStack = UIStackView(axis: .vertical, [satsLabel, satsInfoLabel])
        let mainStack = UIStackView([userImage, centerStack, satsStack])
        
        centerStack.alignment = .leading
        satsStack.alignment = .trailing
        mainStack.alignment = .center
        nameStack.alignment = .center
        
        nameStack.spacing = 4
        centerStack.spacing = 4
        satsStack.spacing = 4
        mainStack.spacing = 8
        
        contentView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .vertical, padding: 20)
            .pinToSuperview(edges: .leading, padding: 12)
            .pinToSuperview(edges: .trailing, padding: 16)
        
        contentView.addSubview(borderView)
        borderView.pinToSuperview(edges: [.horizontal, .bottom])
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        nameLabel.font = .appFont(withSize: 15, weight: .bold)
        sinceLabel.font = .appFont(withSize: 14, weight: .regular)
        satsLabel.font = .appFont(withSize: 15, weight: .bold)
        satsInfoLabel.font = .appFont(withSize: 14, weight: .regular)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setup(item: PremiumListItem) {
        userImage.setUserImage(item.user)
        nameLabel.text = item.user.data.firstIdentifier
        
        check.user = item.user.data
        
        sinceLabel.text = "Since: \(dateFormatter.string(from: item.since))"
        
        satsInfoLabel.text = String(Calendar.current.component(.year, from: item.since))
        satsLabel.text = "Primal OG"
     
        updateTheme()
    }
    
    func updateTheme() {
        nameLabel.textColor = .foreground
        satsLabel.textColor = .foreground
        
        sinceLabel.textColor = .foreground4
        satsInfoLabel.textColor = .foreground4
        
        borderView.backgroundColor = .background3
    }
}

