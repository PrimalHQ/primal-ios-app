//
//  LiveVideoZapsController.swift
//  Primal
//
//  Created by Pavle Stevanović on 26. 8. 2025..
//

import UIKit
import Nantes
import SafariServices

class LiveVideoZapsController: UIViewController, Themeable {
    let zaps: [ParsedLiveComment]
    init(zaps: [ParsedLiveComment]) {
        self.zaps = zaps.sorted(by: {
            guard $0.zapAmount == $1.zapAmount else {
                return $0.zapAmount > $1.zapAmount
            }
            return $0.createdAt < $1.createdAt
        })
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private let pullbar = PullBarView(color: .foreground5.withAlphaComponent(0.8))
    private lazy var totalLabel = UILabel()
    private let zapIcon = UIImageView(image: .zapSatInfo.withRenderingMode(.alwaysTemplate))
    private lazy var zapsLabel = UILabel()
    private let infoBackground = UIView()
    private let border = SpacerView(height: 1, color: .foreground6)
    
    private let zapsTable = UITableView()
    
    private let backgroundExtender = SpacerView(height: 200, priority: .required)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoBackground.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        infoBackground.layer.cornerRadius = 16
        
        let topStack = UIStackView([totalLabel, UIView(), zapIcon, zapsLabel])
        topStack.spacing = 4
        topStack.alignment = .center
        
        infoBackground.addSubview(topStack)
        topStack.pinToSuperview(edges: .horizontal, padding: 20).pinToSuperview(edges: .bottom, padding: 14).pinToSuperview(edges: .top, padding: 40)
        
        infoBackground.addSubview(pullbar)
        pullbar.pinToSuperview(edges: [.horizontal, .top], padding: 12)
        
        let mainStack = UIStackView(axis: .vertical, [infoBackground, border, zapsTable, backgroundExtender])
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.top, .horizontal]).pinToSuperview(edges: .bottom, padding: -200)
        
        zapIcon.transform = .init(translationX: 0, y: -2)
        
        zapsTable.dataSource = self
        zapsTable.register(LiveVideoChatZapCell.self, forCellReuseIdentifier: "cell")
        zapsTable.separatorStyle = .none
        zapsTable.contentInsetAdjustmentBehavior = .never
        zapsTable.contentInset = .init(top: 6, left: 0, bottom: 60, right: 0)
        
        updateTheme()
        
        view.addGestureRecognizer(LivePopupDismissGesture(vc: self))
    }
    
    func updateTheme() {
        zapsTable.backgroundColor = .background
        infoBackground.backgroundColor = .background4
        backgroundExtender.backgroundColor = .background3
        
        pullbar.pullBar.backgroundColor = .foreground5.withAlphaComponent(0.8)
        
        let totalText = NSMutableAttributedString(string: "Total ", attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 18, weight: .regular)
        ])
        totalText.append(.init(string: zaps.count.localized(), attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: 20, weight: .bold)
        ]))
        totalText.append(.init(string: " zaps", attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 18, weight: .regular)
        ]))
        totalLabel.attributedText = totalText
        
        let satsText = NSMutableAttributedString(string: zaps.map({ $0.zapAmount }).reduce(0, +).localized(), attributes: [
            .foregroundColor: UIColor.foreground,
            .font: UIFont.appFont(withSize: 20, weight: .bold)
        ])
        satsText.append(.init(string: " sats", attributes: [
            .foregroundColor: UIColor.foreground3,
            .font: UIFont.appFont(withSize: 18, weight: .regular)
        ]))
        zapsLabel.attributedText = satsText
        
        zapIcon.tintColor = .foreground
    }
}

extension LiveVideoZapsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { zaps.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        (cell as? LiveVideoChatZapCell)?.updateForComment(zaps[indexPath.row], delegate: self)
        
        return cell
    }
}

extension LiveVideoZapsController: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        let handler = PrimalWebsiteScheme.shared
        if handler.canOpenURL(link) {
            dismiss(animated: true) {
                handler.openURL(link)
            }
        } else {
            present(SFSafariViewController(url: link), animated: true)
        }
    }
}
