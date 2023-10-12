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
        case transaction((WalletTransaction, ParsedUser))
    }
    
    struct Section {
        var title: String?
        var cells: [Cell] = []
    }
    
    @Published var isBitcoinPrimary = true
    
    private let table = UITableView()
    
    private var cancellables: Set<AnyCancellable> = []
    private var updateIsBitcoin: AnyCancellable?
    
    private var tableData: [Section] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        
        let button = UIButton()
        button.setImage(UIImage(named: "settingsIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .foreground3
        button.addAction(.init(handler: { [weak self] _ in
            self?.show(SettingsWalletViewController(), sender: nil)
        }), for: .touchUpInside)
        navigationItem.rightBarButtonItem = .init(customView: button)
        
        view.backgroundColor = .background
        table.backgroundColor = .background
    }
}

extension WalletHomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { tableData.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { tableData[section].cells.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableData[indexPath.section].cells[indexPath.row] {
        case .info:
            let cell = tableView.dequeueReusableCell(withIdentifier: "info", for: indexPath)
            if let cell = cell as? WalletInfoCell {
                updateIsBitcoin = nil
                cell.delegate = self
                cell.balanceConversionView.isBitcoinPrimary = isBitcoinPrimary
                updateIsBitcoin = cell.balanceConversionView.$isBitcoinPrimary.sink(receiveValue: { [weak self] isBitcoinPrimary in
                    self?.isBitcoinPrimary = isBitcoinPrimary
                })
            }
            return cell
        case .transaction(let transaction):
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            (cell as? TransactionCell)?.setup(with: transaction, showBTC: isBitcoinPrimary)
            return cell
        }
    }
}

extension WalletHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = tableData[section].title else { return UIView() }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        (header as? TransactionHeader)?.set(title)
        return header
    }
}

extension WalletHomeViewController: WalletInfoCellDelegate {
    func sendButtonPressed() {
        show(WalletPickUserController(), sender: nil)
    }
}

private extension WalletHomeViewController {
    func setup() {
        title = "Primal Wallet"
        
        let stack = UIStackView(axis: .vertical, [table])
        view.addSubview(stack)
        stack.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .bottom, padding: 56, safeArea: true)
        
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.showsVerticalScrollIndicator = false
        table.register(TransactionCell.self, forCellReuseIdentifier: "cell")
        table.register(WalletInfoCell.self, forCellReuseIdentifier: "info")
        table.register(TransactionHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        
        updateTheme()
        
        WalletManager.instance.$parsedTransactions.receive(on: DispatchQueue.main).sink { [weak self] transactions in
            let together = Date()
            let grouping = Dictionary(grouping: transactions) {
                Calendar.current.dateComponents([.day, .year, .month], from: Date(timeIntervalSince1970: TimeInterval($0.0.created_at)))
            }
            
            self?.tableData = [.init(cells: [.info])] + grouping.sorted(by: { $0.1.first?.0.created_at ?? 0 > $1.1.first?.0.created_at ?? 0 }).map {
                let date = Date(timeIntervalSince1970: TimeInterval($0.value.first?.0.created_at ?? 0))
                return .init(title: date.daysAgoDisplay(), cells: $0.value.map { .transaction($0) })
            }
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
