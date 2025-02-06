//
//  LegendListController.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.2.25..
//

import Combine
import UIKit

struct LegendListItem {
    let index: Int
    let user: ParsedUser
    let since: Date
    let sats: Int
}

struct LegendListServerResponse: Codable {
    let pubkey: String
    let donated_btc: String
    let last_donation: Double
}

class LegendListController: PrimalPageController {
    var cancellables: Set<AnyCancellable> = []
    
    let latest: LegendListTableController
    let contribution: LegendListTableController
    
    init() {
        let latest = LegendListTableController()
        let contribution = LegendListTableController()
        let aboutButton = UIButton(configuration: .accent("About Legends", font: .appFont(withSize: 14, weight: .regular)))
        let aboutParent = UIView()
        aboutParent.addSubview(aboutButton)
        aboutButton.centerToSuperview(axis: .vertical).pinToSuperview(edges: .trailing, padding: 0)
        
        self.latest = latest
        self.contribution = contribution
        
        super.init(
            tabs: [
                ("LATEST", { latest }),
                ("CONTRIBUTION", { contribution })
            ],
            extraViews: [aboutParent]
        )
        
        tabSelectionView.stack.spacing = 22
        tabSelectionView.distribution = .fill
        
        title = "Primal Legends"
        
        aboutButton.addAction(.init(handler: { [weak self] _ in
            self?.show(PremiumBecomeLegendController(), sender: nil)
        }), for: .touchUpInside)
        aboutButton.transform = .init(translationX: 0, y: -3)
        
        SocketRequest(name: "membership_legends_leaderboard", payload: [
            "limit": 1000,
            "order_by": "donated_btc",
        ])
        .publisher()
        .receive(on: DispatchQueue.main)
        .sink { [weak self] res in
            guard
                let listResponse = res.events.first(where: { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.primalLegendInfoList.rawValue }),
                let items: [LegendListServerResponse] = listResponse["content"]?.stringValue?.decode()
            else {
                return
            }
            
            let users = res.getSortedUsers()
            
            let legends: [LegendListItem] = items.enumerated().map { (index, item) in
                .init(
                    index: index + 1,
                    user: users.first(where: { $0.data.pubkey == item.pubkey }) ?? .init(data: .init(pubkey: item.pubkey)),
                    since: Date(timeIntervalSince1970: item.last_donation),
                    sats: Int((Double(item.donated_btc) ?? 0))
                )
            }
            
            self?.contribution.legends = legends
            self?.latest.legends = legends.sorted(by: { $0.since > $1.since })
        }
        .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func updateTheme() {
        super.updateTheme()
        
        navigationItem.leftBarButtonItem = customBackButton
    }
}


class LegendListTableController: UITableViewController, Themeable {
    var legends: [LegendListItem] = [] { didSet { tableView.reloadData() } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(LegendListTableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.contentInset = .init(top: 60, left: 0, bottom: 60, right: 0)
        tableView.separatorStyle = .none
    }
    
    var firstTime = true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstTime {
            firstTime = false
            if !legends.isEmpty {
                tableView.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = legends[safe: indexPath.row]?.user else { return }
        show(ProfileViewController(profile: user), sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { legends.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? LegendListTableViewCell)?.setup(item: legends[indexPath.row])
        return cell
    }
    
    func updateTheme() {
        tableView.reloadData()
    }
}


class LegendListTableViewCell: UITableViewCell, Themeable {
    let indexLabel = UILabel()
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
        let mainStack = UIStackView([indexLabel, userImage, centerStack, satsStack])
        
        centerStack.alignment = .leading
        satsStack.alignment = .trailing
        mainStack.alignment = .center
        nameStack.alignment = .center
        
        nameStack.spacing = 4
        centerStack.spacing = 4
        satsStack.spacing = 4
        mainStack.spacing = 8
        
        indexLabel.constrainToSize(width: 40)
        
        contentView.addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .vertical, padding: 20)
            .pinToSuperview(edges: .leading, padding: 12)
            .pinToSuperview(edges: .trailing, padding: 16)
        
        contentView.addSubview(borderView)
        borderView.pinToSuperview(edges: [.horizontal, .bottom])
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        indexLabel.font = .appFont(withSize: 16, weight: .bold)
        nameLabel.font = .appFont(withSize: 15, weight: .bold)
        sinceLabel.font = .appFont(withSize: 14, weight: .regular)
        satsLabel.font = .appFont(withSize: 15, weight: .bold)
        satsInfoLabel.font = .appFont(withSize: 14, weight: .regular)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setup(item: LegendListItem) {
        indexLabel.text = item.index.localized()
        
        userImage.setUserImage(item.user)
        nameLabel.text = item.user.data.firstIdentifier
        
        check.user = item.user.data
        
        sinceLabel.text = "Since: \(dateFormatter.string(from: item.since))"
        satsLabel.text = item.sats.localized()
     
        updateTheme()
    }
    
    func updateTheme() {
        indexLabel.textColor = .foreground
        nameLabel.textColor = .foreground
        satsLabel.textColor = .foreground
        
        sinceLabel.textColor = .foreground4
        satsInfoLabel.textColor = .foreground4
        
        borderView.backgroundColor = .background3
    }
}

