//
//  WalletHomeViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 9.10.23..
//

import AudioToolbox
import Combine
import UIKit
import GenericJSON

protocol WalletHomeTransitionButton: UIControl {
    var imageView: UIImageView? { get }
}

extension UIButton: WalletHomeTransitionButton {
    var imageBackground: UIView? { self }
}

extension LargeWalletButton: WalletHomeTransitionButton {
    var imageView: UIImageView? { iconView }
}


final class WalletHomeViewController: UIViewController, Themeable {
    enum Cell {
        case loading
        case activateWallet
        case buySats
        case error(String)
        case transaction((WalletTransaction, ParsedUser))
        
        var transaction: WalletTransaction? { parsedTransaction?.0 }
        
        var parsedTransaction: (WalletTransaction, ParsedUser)? {
            if case let .transaction(trans) = self {
                return trans
            }
            return nil
        }
    }
    
    struct Section {
        var title: String?
        var cells: [Cell] = []
        
        var parsedTransactions: [(WalletTransaction, ParsedUser)] { cells.compactMap { $0.parsedTransaction } }
    }
    
    private let navBar = WalletNavView()
    let table = UITableView()
    
    private var cancellables: Set<AnyCancellable> = []
    private var foregroundUpdate: AnyCancellable?
    
    private var forceNavbarOpen = false
    private var extraOffset: CGFloat = 0
    private var contentOffsetStart = CGPoint.zero
    
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    
    var transitionButton: WalletHomeTransitionButton?
    
    var selectedIndexPath: IndexPath?
    
    var animationsOn = false
    
    private var tableData: [Section] = [] {
        didSet {
            guard navigationController?.topViewController == parent, view.window != nil else { return }
            
            table.reloadData()
            animateCellsAppear(howManyCellsToAppear(oldValue, tableData))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.animationsOn = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        WalletManager.instance.recheck()
        WalletManager.instance.loadNewExchangeRate()
        
        ICloudKeychainManager.instance.$userPubkey
            .compactMap { $0.isEmpty ? nil : $0 }
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                self?.cancellables = []
            }
            .store(in: &cancellables)
        
        table.reloadData()
        mainTabBarController?.setTabBarHidden(false, animated: animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        (navigationController as? MainNavigationController)?.isTransparent = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        heavyImpact.prepare()
        
        foregroundUpdate = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink(receiveValue: { [weak self] _ in
                self?.table.reloadData()
            })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        foregroundUpdate = nil
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        table.backgroundColor = .background
        table.reloadData()
        
        updateBuySatsButton()
    }
    
    func updateBuySatsButton() {
        guard WalletManager.instance.primal?.userHasWallet == true else {
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
                cell.setup(with: transaction, showBTC: WalletManager.instance.isBitcoinPrimary)
                cell.delegate = self
            }
            
            if indexPath.section >= tableData.count - 1 {
                WalletManager.instance.impl.loadMoreTransactions()
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.forceNavbarOpen = false
        }
        
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
            selectedIndexPath = indexPath
            show(TransactionViewController(transaction: transaction, user: user), sender: nil)
        case .activateWallet:
            activateWalletPressed()
        }
    }
}

extension WalletHomeViewController: BuySatsCellDelegate, ActivateWalletCellDelegate {
    func activateWalletPressed() {
        if WalletManager.instance.primal == nil {
            WalletManager.instance.setUsePrimalWallet()
        } else {
            show(WalletActivateViewController(), sender: nil)
        }
    }
    
    func buySatsPressed() {
        present(WalletInAppPurchaseController(), animated: true)
    }
}

// MARK: - HeaderPanGesture
extension WalletHomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let translation = pan.translation(in: view)
        return translation.y < 0 && abs(translation.y) > abs(translation.x)
    }
}

// MARK: - Private
private extension WalletHomeViewController {
    func setup() {
        title = "Wallet"
        
        let stack = UIStackView(axis: .vertical, [navBar, table])
        view.addSubview(stack)
        // It's necessary to keep the table longer than the view itself, so when the navbar expands and table shortens, we don't see any empty parts of the table
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .bottom, padding: -100)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(headerPanned))
        pan.delegate = self
        navBar.largeView.addGestureRecognizer(pan)
        
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
            if WalletManager.instance.userHasWallet != true {
                WalletManager.instance.primal?.refreshHasWallet()
                return
            }
            
            WalletManager.instance.refresh()
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
            guard let self else { return }
            
            let grouping = Dictionary(grouping: transactions) {
                Calendar.current.dateComponents([.day, .year, .month], from: Date(timeIntervalSince1970: TimeInterval($0.0.created_at)))
            }
            
            table.refreshControl?.endRefreshing()
            var firstSection = Section(cells: [])
            
            guard LoginManager.instance.method() == .nsec else {
                tableData = [firstSection, Section(cells: [.error("Primal is in read only mode because you are signed in via your public key. To enable all options, please sign in with your private key, starting with 'nsec...")])]
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
            
            let allowAnimation = animationsOn || transactions.count == 1
            
            if allowAnimation, howManyCellsToAppear(self.tableData, tableData) > 0, tableData.first?.cells.map({ $0.transaction }).first??.type == "DEPOSIT" {
                mainTabBarController?.playThunderAnimation()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    self.tableData = tableData
                }
            } else {
                self.tableData = tableData
            }
        }
        .store(in: &cancellables)
        
        if LoginManager.instance.method() == .nsec {
            navBar.receivePressedEvent.sink { [weak self] button in
                self?.transitionButton = button as? WalletHomeTransitionButton
                
                self?.heavyImpact.impactOccurred()
                self?.show(WalletReceiveViewController(), sender: nil)
            }
            .store(in: &cancellables)
            
            navBar.sendPressedEvent.sink { [weak self] button in
                self?.transitionButton = button as? WalletHomeTransitionButton
                
                self?.heavyImpact.impactOccurred()
                self?.show(WalletSendParentViewController(startingTab: .nostr), sender: nil)
            }
            .store(in: &cancellables)
            
            navBar.scanPressedEvent.sink { [weak self] button in
                self?.transitionButton = button as? WalletHomeTransitionButton
                
                self?.heavyImpact.impactOccurred()
                (self?.navigationController as? MainNavigationController)?.isTransparent = true
                DispatchQueue.main.async {
                    self?.show(WalletSendParentViewController(startingTab: .scan), sender: nil)
                }
            }
            .store(in: &cancellables)
        }
        
        navBar.balanceConversionView.$isBitcoinPrimary.dropFirst().sink { isBitcoinPrimary in
            WalletManager.instance.isBitcoinPrimary = isBitcoinPrimary
        }
        .store(in: &cancellables)
        
        WalletManager.instance.$isBitcoinPrimary.dropFirst().removeDuplicates().throttle(for: 0.3, scheduler: DispatchQueue.main, latest: true).sink { [weak self] _ in
            guard let self else { return }
            if self.tableData.count > 1 {
                self.table.reloadData()
            }
        }
        .store(in: &cancellables)
        
        WalletManager.instance.$userHasWallet
            .map { $0 ?? false }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isHidden, onWeak: navBar.blockerView)
            .store(in: &cancellables)
    }
    
    
    @objc func headerPanned(_ sender: UIPanGestureRecognizer) {
        if case .began = sender.state {
            contentOffsetStart = table.contentOffset
        }
        
        let translation = sender.translation(in: view).y
        table.contentOffset.y = max(5, contentOffsetStart.y - translation)
    }
    
    func howManyCellsToAppear(_ oldValue: [Section], _ newValue: [Section]) -> Int {
        guard table.window != nil, let indexPaths = table.indexPathsForVisibleRows else { return 0 }
        
        let oldIds = Set(oldValue.flatMap { $0.cells.compactMap({ cell in cell.transaction?.id }) })
        let newIds = Set(newValue.flatMap { $0.cells.compactMap({ cell in cell.transaction?.id }) })
        
        if oldIds.isEmpty { return 0 }
        
        let deltaIds = newIds.subtracting(oldIds)
        var animateCount = 0
        for indexPath in indexPaths {
            if let transaction = newValue[safe: indexPath.section]?.cells[safe: indexPath.row]?.transaction, deltaIds.contains(transaction.id) {
                animateCount += 1
            } else {
                break
            }
        }
        
        return animateCount
    }
    
    func animateCellsAppear(_ count: Int) {
        guard count > 0 else { return }
        
        let cellsToAnimate = table.visibleCells.prefix(count).compactMap { $0 as? TransactionCell }
        let otherCells = table.visibleCells.dropFirst(count)
        
        for cell in cellsToAnimate {
            cell.contentView.alpha = 0
            cell.contentView.transform = .init(translationX: 200, y: 0)
            
            let view = UIView()
            view.backgroundColor = Theme.current.isDarkTheme ? .init(rgb: 0x222222) : .init(rgb: 0xCCCCCC)
            view.frame = cell.bounds
            view.alpha = 0
            cell.insertSubview(view, at: 0)
            
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(.easeInOutQuart)
            
            UIView.animate(withDuration: 6 / 30, delay: 5 / 30) {
                cell.contentView.transform = .identity
            }
            
            CATransaction.commit()
            
            UIView.animate(withDuration: 6 / 30, delay: 5 / 30) {
                cell.contentView.alpha = 1
                view.alpha = 1
            } completion: { _ in
                UIView.animate(withDuration: 25 / 30) {
                    view.alpha = 0
                } completion: { _ in
                    view.removeFromSuperview()
                }
            }
        }
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(.easeInOutQuart)
        
        for cell in otherCells {
            cell.contentView.transform = .init(translationX: 0, y: -CGFloat(count) * 68)
            
            UIView.animate(withDuration: 11 / 30) {
                cell.contentView.transform = .identity
            }
        }
        
        CATransaction.commit()
    }
}
