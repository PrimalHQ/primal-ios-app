//
//  ExplorePeopleViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 7.10.24..
//

import Combine
import UIKit

class ExplorePeopleViewController: UIViewController, Themeable {
    private var cancellables: Set<AnyCancellable> = []
    private let feedManager = ExploreUsersFeedManager()
    
    private var userLists: [UserList] = [] {
        didSet {
            table.reloadData()
            loadingView.isHidden = !userLists.isEmpty
            if !userLists.isEmpty {
                loadingView.pause()
            }
        }
    }
    
    let loadingView = SkeletonLoaderView(aspect: 343 / 134)
    
    private let table = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        feedManager.$userLists
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userLists in
                self?.userLists = userLists
                self?.table.refreshControl?.endRefreshing()
            })
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userLists.isEmpty {
            feedManager.refresh()
        }
        
        updateTheme()
    }
    
    func updateTheme() {
        table.reloadData()
        
        DispatchQueue.main.async { [self] in
            loadingView.isHidden = !userLists.isEmpty
            if userLists.isEmpty {
                loadingView.play()
            }
        }
    }
}

private extension ExplorePeopleViewController {
    func setup() {
        view.addSubview(table)
        table.pinToSuperview()
        table.contentInsetAdjustmentBehavior = .never
        table.register(ExplorePeopleCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.refreshControl = .init(frame: .zero, primaryAction: .init(handler: { [weak self] _ in
            self?.feedManager.refresh()
        }))
        
        table.contentInset = .init(top: 157 + 16, left: 0, bottom: 80, right: 0)
        table.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 50, right: 0)
        
        view.addSubview(loadingView)
        loadingView.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, padding: 60, safeArea: true)
    }
}

extension ExplorePeopleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { userLists.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ExplorePeopleCell {
            cell.updateForUserList(userLists[indexPath.row])
        }
        
        if indexPath.item > userLists.count - 10 {
            feedManager.requestNewPage()
        }
        
        return cell
    }
}

extension ExplorePeopleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userList = userLists[safe: indexPath.row] else { return }
        show(UserListViewController(list: userList), sender: nil)
    }
}
