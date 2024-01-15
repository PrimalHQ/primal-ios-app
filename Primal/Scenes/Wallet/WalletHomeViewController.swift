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
        case loading
        case activateWallet
        case buySats
        case error(String)
        case transaction((WalletTransaction, ParsedUser))
        
        var transaction: WalletTransaction? {
            if case let .transaction(trans) = self {
                return trans.0
            }
            return nil
        }
    }
    
    struct Section {
        var title: String?
        var cells: [Cell] = []
    }
    
    @Published var isBitcoinPrimary = true
    
    private let navBar = WalletNavView()
    let table = UITableView()
    
    private var cancellables: Set<AnyCancellable> = []
    private var updateIsBitcoin: AnyCancellable?
    private var update: ContinousConnection?
    private var updateUpdate: AnyCancellable?
    
    private var forceNavbarOpen = false
    private var extraOffset: CGFloat = 0
    private var contentOffsetStart = CGPoint.zero
    
    private var tableData: [Section] = [] {
        didSet {
            guard
                oldValue.count == tableData.count,
                let oldLast = oldValue.last?.cells.last?.transaction,
                let newLast = tableData.last?.cells.last?.transaction,
                oldLast.id == newLast.id,
                let oldTransactionList = oldValue.drop(while: { $0.title == nil }).first?.cells.compactMap({ $0.transaction }),
                let newTransactionList = tableData.drop(while: { $0.title == nil }).first?.cells.compactMap({ $0.transaction }),
                oldTransactionList.first?.id != newTransactionList.first?.id
            else {
                table.reloadData()
                return
            }
            
            let section = oldValue.first?.title == nil ? 1 : 0
            
            // Make sure other sections are not changed
            for index in oldValue.indices {
                if index < 2 { continue }
                if oldValue[index].cells.count != tableData[index].cells.count {
                    table.reloadData()
                    return
                }
            }
            
            let newTransCount = newTransactionList.count - oldTransactionList.count
            
            guard newTransCount > 0 else {
                table.reloadData()
                return
            }
            table.beginUpdates()
            
            if section > 0 {
                table.reloadSections(.init(integer: 0), with: .none)
            }
            
            let indexPaths: [IndexPath] = (0..<newTransCount).map { .init(row: $0, section: section) }
            table.insertRows(at: indexPaths, with: .top)
            table.endUpdates()
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
        (navigationController as? MainNavigationController)?.isTransparent = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let event = NostrObject.wallet("{\"subwallet\":1}") else { return }

        updateUpdate = Connection.wallet.$isConnected.removeDuplicates().filter { $0 }
            .sink { [weak self] _ in
                self?.update = Connection.wallet.requestCacheContinous(name: "wallet_monitor", request: ["operation_event": event.toJSON()]) { result in
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
        
        updateBuySatsButton()
    }
    
    func updateBuySatsButton() {
        guard WalletManager.instance.userHasWallet == true else {
            navigationItem.rightBarButtonItem = nil
            return
        }
        let button = UIButton()
        button.setImage(UIImage(named: "buySats"), for: .normal)
        button.tintColor = .foreground3
        button.addAction(.init(handler: { [weak self] _ in self?.buySatsPressed() }), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
}

// MARK: - TableDatasource
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
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
            (cell as? ChatLoadingCell)?.updateTheme()
            return cell
        case let .error(message):
            let cell = tableView.dequeueReusableCell(withIdentifier: "error", for: indexPath)
            (cell as? ErrorMessageCell)?.setText(message)
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

// MARK: - Delegate
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
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        navBar.shouldExpand = true
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        forceNavbarOpen = true
        navBar.shouldExpand = true
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if forceNavbarOpen {
            navBar.shouldExpand = true
            if scrollView.contentOffset.y < 5 {
                forceNavbarOpen = false
            }
            return
        }
        
        if navBar.shouldExpand {
            navBar.shouldExpand = scrollView.contentOffset.y < 5
            
            if !navBar.shouldExpand {
                extraOffset = navBar.expandedHeight - navBar.tightenedHeight - scrollView.contentOffset.y
                scrollView.contentOffset.y = 1
            }
        } else {
            if scrollView.contentOffset.y <= 0 {
                navBar.shouldExpand = true
            } else if navBar.isAnimating && extraOffset > 0 {
                extraOffset -= scrollView.contentOffset.y
                scrollView.contentOffset.y = 1
            } else {
                print(navBar.isAnimating)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableData[indexPath.section].cells[indexPath.row] {
        case .loading, .error:
            break
        case .buySats:
            buySatsPressed()
        case .transaction((let transaction, let user)):
            show(TransactionViewController(transaction: transaction, user: user), sender: nil)
        case .activateWallet:
            activateWalletPressed()
        }
    }
}

extension WalletHomeViewController: BuySatsCellDelegate, ActivateWalletCellDelegate {
    func activateWalletPressed() {
        show(WalletActivateViewController(), sender: nil)
    }
    
    func buySatsPressed() {
        present(WalletInAppPurchaseController(), animated: true)
    }
}

// MARK: - HeaderPanGesture
extension WalletHomeViewController: UIGestureRecognizerDelegate {
    
}

// MARK: - Private
private extension WalletHomeViewController {
    func setup() {
        title = "Wallet"
        
        let stack = UIStackView(axis: .vertical, [navBar, table])
        view.addSubview(stack)
        // It's necessary to keep the table longer than the view itself, so when the navbar expands and table shortens, we don't see any empty parts of the table
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .bottom, padding: -100)
        
        navBar.largeView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(headerPanned)))
        
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.contentInsetAdjustmentBehavior = .never
        table.showsVerticalScrollIndicator = false
        table.register(TransactionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        table.register(TransactionCell.self, forCellReuseIdentifier: "cell")
        table.register(WalletInfoCell.self, forCellReuseIdentifier: "info")
        table.register(BuySatsCell.self, forCellReuseIdentifier: "buySats")
        table.register(ActivateWalletCell.self, forCellReuseIdentifier: "activateWallet")
        table.register(ChatLoadingCell.self, forCellReuseIdentifier: "loading")
        table.register(ErrorMessageCell.self, forCellReuseIdentifier: "error")
        table.contentInset = .init(top: 0, left: 0, bottom: 186, right: 0)
        
        let refresh = UIRefreshControl()
        refresh.addAction(.init(handler: { _ in
            WalletManager.instance.refreshTransactions()
            WalletManager.instance.refreshBalance()
        }), for: .valueChanged)
        table.refreshControl = refresh
        
        updateTheme()
        
        WalletManager.instance.$userHasWallet.sink { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self?.updateBuySatsButton()
            }
        }
        .store(in: &cancellables)
        
        let isPoorPublisher = WalletManager.instance.$balance.map { $0 < 1000 }.removeDuplicates()
        let shouldShowBuySatsPublisher = Publishers.CombineLatest(isPoorPublisher, WalletManager.instance.$didJustCreateWallet).map { $0 && $1 }
        
        Publishers.CombineLatest4(
            WalletManager.instance.$userHasWallet,
            WalletManager.instance.$isLoadingWallet,
            WalletManager.instance.$parsedTransactions,
            shouldShowBuySatsPublisher.removeDuplicates()
        )
        .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] hasWallet, isLoading, transactions, shouldShowBuySats in
            let grouping = Dictionary(grouping: transactions) {
                Calendar.current.dateComponents([.day, .year, .month], from: Date(timeIntervalSince1970: TimeInterval($0.0.created_at)))
            }
            
            self?.table.refreshControl?.endRefreshing()
            var firstSection = Section(cells: [])
            
            guard LoginManager.instance.method() == .nsec else {
                self?.tableData = [firstSection, Section(cells: [.error("Primal is in read only mode because you are signed in via your public key. To enable all options, please sign in with your private key, starting with 'nsec...")])]
                return
            }
            
            if hasWallet == false {
                firstSection.cells += [.activateWallet]
            } else if isLoading && transactions.isEmpty {
                firstSection.cells += [.loading]
            } else if shouldShowBuySats {
                firstSection.cells += [.buySats]
            }
            
            var tableData = [Section]()
            if !firstSection.cells.isEmpty {
                tableData.append(firstSection)
            }
            tableData.append(contentsOf: grouping.sorted(by: { $0.1.first?.0.created_at ?? 0 > $1.1.first?.0.created_at ?? 0 }).map {
                let date = Date(timeIntervalSince1970: TimeInterval($0.value.first?.0.created_at ?? 0))
                return .init(title: date.daysAgoDisplay(), cells: $0.value.map { .transaction($0) })
            })
            
            self?.tableData = tableData
        }
        .store(in: &cancellables)
        
        navBar.receivePressedEvent.sink { [weak self] in
            self?.show(WalletReceiveViewController(), sender: nil)
        }
        .store(in: &cancellables)
        
        navBar.sendPressedEvent.sink { [weak self] in
            self?.show(WalletSendParentViewController(startingTab: .nostr), sender: nil)
        }
        .store(in: &cancellables)
        
        navBar.scanPressedEvent.sink { [weak self] in
            (self?.navigationController as? MainNavigationController)?.isTransparent = true
            DispatchQueue.main.async {
                self?.show(WalletSendParentViewController(startingTab: .scan), sender: nil)
            }
        }
        .store(in: &cancellables)
        
        navBar.balanceConversionView.$isBitcoinPrimary.dropFirst().sink { [weak self] isBitcoinPrimary in
            self?.isBitcoinPrimary = isBitcoinPrimary
        }
        .store(in: &cancellables)
        
        $isBitcoinPrimary.dropFirst().removeDuplicates().throttle(for: 0.3, scheduler: DispatchQueue.main, latest: true).sink { [weak self] _ in
            guard let self else { return }
            if self.tableData.count > 1 {
                self.table.reloadData()
            }
        }
        .store(in: &cancellables)
    }
    
    
    @objc func headerPanned(_ sender: UIPanGestureRecognizer) {
        if case .began = sender.state {
            contentOffsetStart = table.contentOffset
        }
        
        let translation = sender.translation(in: view).y
        table.contentOffset.y = contentOffsetStart.y - translation
    }
}
