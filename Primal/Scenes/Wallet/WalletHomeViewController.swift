//
//  WalletHomeViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.10.23..
//

import Combine
import UIKit

final class WalletHomeViewController: UIViewController, Themeable {
    enum Cell {
        case info
        case activateWallet
        case buySats
        case transaction((WalletTransaction, ParsedUser))
    }
    
    struct Section {
        var title: String?
        var cells: [Cell] = []
    }
    
    @Published var isBitcoinPrimary = true
    
    private let navBar = WalletNavView()
    private let table = UITableView()
    
    private var cancellables: Set<AnyCancellable> = []
    private var updateIsBitcoin: AnyCancellable?
    private var update: ContinousConnection?
    private var updateUpdate: AnyCancellable?
    
    private var tableData: [Section] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    var isShowingNavBar = false {
        didSet {
            if isShowingNavBar == oldValue { return }
            
            if isShowingNavBar {
                navBar.balanceConversionView.isBitcoinPrimary = isBitcoinPrimary
            } else {
                (table.cellForRow(at: .init(row: 0, section: 0)) as? WalletInfoCell)?.balanceConversionView.isBitcoinPrimary = isBitcoinPrimary
            }
            
            if !isShowingNavBar {
                table.contentInset = isShowingNavBar ? UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0) : .zero
            }
            
            UIView.animate(withDuration: 0.2) {
                self.navBar.transform = self.isShowingNavBar ? .identity : .init(translationX: 0, y: -100)
            } completion: { _ in
                self.table.contentInset = self.isShowingNavBar ? UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0) : .zero
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WalletManager.instance.refreshBalance()
        WalletManager.instance.loadNewTransactions()
        
        mainTabBarController?.setTabBarHidden(false, animated: animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let event = NostrObject.wallet("{\"subwallet\":1}") else { return }

        updateUpdate = Connection.instance.$isConnected.removeDuplicates().filter { $0 }
            .sink { [weak self] _ in
                self?.update = Connection.instance.requestCacheContinous(name: "wallet_monitor", request: ["operation_event": event.toJSON()]) { result in
                    guard let content = result.arrayValue?.last?.objectValue?["content"]?.stringValue else { return }
                    guard let amountBTC = content.split(separator: "\"").compactMap({ Double($0) }).first else { return }
                    let sats = Int(amountBTC * .BTC_TO_SAT)
                    WalletManager.instance.balance = sats
                }
            }
        
        WalletManager.instance.refreshBalance()
        WalletManager.instance.loadNewTransactions()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        updateUpdate = nil
        update = nil
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        table.backgroundColor = .background
        table.reloadData()
        
        let button = UIButton()
        button.setImage(UIImage(named: "buySats"), for: .normal)
        button.tintColor = .foreground3
        button.addAction(.init(handler: { [weak self] _ in self?.buySatsPressed() }), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
}

extension WalletHomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { tableData.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { tableData[section].cells.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableData[indexPath.section].cells[indexPath.row] {
        case .activateWallet:
            let cell = tableView.dequeueReusableCell(withIdentifier: "activateWallet", for: indexPath)
            if let cell = cell as? ActivateWalletCell {
                cell.updateTheme()
                cell.delegate = self
            }
            return cell
        case .buySats:
            let cell = tableView.dequeueReusableCell(withIdentifier: "buySats", for: indexPath)
            if let cell = cell as? BuySatsCell {
                cell.updateTheme()
                cell.delegate = self
            }
            return cell
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "info", for: indexPath)
            if let cell = cell as? WalletInfoCell {
                updateIsBitcoin = nil
                cell.delegate = self
                cell.balanceConversionView.isBitcoinPrimary = isBitcoinPrimary
                updateIsBitcoin = cell.balanceConversionView.$isBitcoinPrimary.sink(receiveValue: { [weak self] isBitcoinPrimary in
                    self?.isBitcoinPrimary = isBitcoinPrimary
                })
                
                cell.contentView.alpha = WalletManager.instance.userHasWallet ? 1 : 0.5
                cell.contentView.isUserInteractionEnabled = WalletManager.instance.userHasWallet
            }
            return cell
        case .transaction(let transaction):
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            if let cell = cell as? TransactionCell {
                cell.setup(with: transaction, showBTC: isBitcoinPrimary)
                cell.delegate = self
            }
            
            if indexPath.section >= tableData.count - 1 {
                WalletManager.instance.loadMoreTransactions()
            }
            
            return cell
        }
    }
}

extension WalletHomeViewController: TransactionCellDelegate {
    func transactionCellDidTapAvatar(_ cell: TransactionCell) {
        guard
            let indexPath = table.indexPath(for: cell),
            case let .transaction((_, user)) = tableData[indexPath.section].cells[indexPath.row],
            user.data.pubkey != IdentityManager.instance.userHexPubkey
        else { return }
        
        show(ProfileViewController(profile: user), sender: nil)
    }
}

extension WalletHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = tableData[section].title else { return UIView() }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        (header as? TransactionHeader)?.set(title)
        return header
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        isShowingNavBar = scrollView.contentOffset.y > 190
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableData[indexPath.section].cells[indexPath.row] {
        case .info:
            break
        case .buySats:
            buySatsPressed()
        case .transaction((_, _)):
            break
        case .activateWallet:
            activateWalletPressed()
        }
    }
}

extension WalletHomeViewController: WalletInfoCellDelegate, BuySatsCellDelegate, ActivateWalletCellDelegate {
    func activateWalletPressed() {
        show(WalletActivateViewController(), sender: nil)
    }
    
    func buySatsPressed() {
        present(WalletInAppPurchaseController(), animated: true)
    }
    
    func receiveButtonPressed() {
        show(WalletReceiveViewController(), sender: nil)
    }
    
    func sendButtonPressed() {
        show(WalletPickUserController(), sender: nil)
    }
    
    func scanButtonPressed() {
        present(WalletQRCodeViewController(), animated: true)
    }
}

private extension WalletHomeViewController {
    func setup() {
        title = "Wallet"
        
        view.addSubview(table)
        table.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        
        view.addSubview(navBar)
        navBar.pinToSuperview(edges: [.horizontal, .top], safeArea: true)
        navBar.transform = .init(translationX: 0, y: -100)
        
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.showsVerticalScrollIndicator = false
        table.register(TransactionCell.self, forCellReuseIdentifier: "cell")
        table.register(WalletInfoCell.self, forCellReuseIdentifier: "info")
        table.register(TransactionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        table.register(BuySatsCell.self, forCellReuseIdentifier: "buySats")
        table.register(ActivateWalletCell.self, forCellReuseIdentifier: "activateWallet")
        
        let refresh = UIRefreshControl()
        refresh.addAction(.init(handler: { _ in
            WalletManager.instance.refreshTransactions()
            WalletManager.instance.refreshBalance()
        }), for: .valueChanged)
        table.refreshControl = refresh
        
        updateTheme()
        
        Publishers.CombineLatest(WalletManager.instance.$userHasWallet, WalletManager.instance.$parsedTransactions)
            .receive(on: DispatchQueue.main).sink { [weak self] hasWallet, transactions in
                let grouping = Dictionary(grouping: transactions) {
                    Calendar.current.dateComponents([.day, .year, .month], from: Date(timeIntervalSince1970: TimeInterval($0.0.created_at)))
                }
                
                self?.table.refreshControl?.endRefreshing()
                var firstSection = Section(cells: [.info])
                if hasWallet {
                    if WalletManager.instance.balance < 1000 {
                        firstSection.cells += [.buySats]
                    }
                } else {
                    firstSection.cells += [.activateWallet]
                }
                
                self?.tableData = [firstSection] + grouping.sorted(by: { $0.1.first?.0.created_at ?? 0 > $1.1.first?.0.created_at ?? 0 }).map {
                    let date = Date(timeIntervalSince1970: TimeInterval($0.value.first?.0.created_at ?? 0))
                    return .init(title: date.daysAgoDisplay(), cells: $0.value.map { .transaction($0) })
                }
            }
            .store(in: &cancellables)
        
        navBar.receive.addAction(.init(handler: { [weak self] _ in
            self?.receiveButtonPressed()
        }), for: .touchUpInside)
        navBar.send.addAction(.init(handler: { [weak self] _ in
            self?.sendButtonPressed()
        }), for: .touchUpInside)
        navBar.scan.addAction(.init(handler: { [weak self] _ in
            self?.scanButtonPressed()
        }), for: .touchUpInside)
        
        navBar.balanceConversionView.$isBitcoinPrimary.dropFirst().sink { [weak self] isBitcoinPrimary in
            self?.isBitcoinPrimary = isBitcoinPrimary
        }
        .store(in: &cancellables)
        
        $isBitcoinPrimary.dropFirst().removeDuplicates().throttle(for: 0.3, scheduler: DispatchQueue.main, latest: true).sink { [weak self] _ in
            guard let self else { return }
            if self.tableData.count > 1 {
                self.table.reloadData()
//                if let rows = self.table.indexPathsForVisibleRows?.filter({ $0.section != 0 }) {
//                    self.table.reloadRows(at: rows, with: .none)
//                }
            }
        }
        .store(in: &cancellables)
    }
}