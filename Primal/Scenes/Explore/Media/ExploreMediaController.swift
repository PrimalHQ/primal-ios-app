//
//  ExploreMediaController.swift
//  Primal
//
//  Created by Pavle Stevanović on 7.10.24..
//

import Combine
import UIKit

class ExploreMediaController: UIViewController, Themeable {
    private var cancellables: Set<AnyCancellable> = []
    private let feedManager = ExploreMediaFeedManager()
    
    private var notes: [ParsedContent] = [] {
        didSet {
            table.reloadData()
        }
    }
    
    private let table = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        feedManager.$notes
            .receive(on: DispatchQueue.main)
            .assign(to: \.notes, onWeak: self)
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        table.reloadData()
        
        feedManager.refresh()
    }
    
    func updateTheme() {
        table.reloadData()
    }
}

private extension ExploreMediaController {
    func setup() {
        view.addSubview(table)
        table.pinToSuperview()
        table.contentInsetAdjustmentBehavior = .never
        table.register(MediaTripleCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.separatorStyle = .none
        
        table.contentInset = .init(top: 157 + 16, left: 0, bottom: 80, right: 0)
        table.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 50, right: 0)
        
    }
}

extension ExploreMediaController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { (notes.count + 2) / 3 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? MediaTripleCell {
            let index = indexPath.row * 3
            let mediaSlice = Array(notes[index..<min(index + 3, notes.count)])
            cell.setupMetadata(mediaSlice, delegate: self)
        }
        return cell
    }
}

extension ExploreMediaController: MediaTripleCellDelegate {
    func cellDidSelectImage(_ cell: MediaTripleCell, imageIndex: Int) {
        guard
            let indexPath = table.indexPath(for: cell),
            let note = notes[safe: indexPath.row * 3 + imageIndex]
        else { return }
        
        show(ThreadViewController(post: note), sender: nil)
    }
}
