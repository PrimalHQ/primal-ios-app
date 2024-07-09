//
//  ExploreViewController.swift
//  Primal
//
//  Created by Pavle D Stevanović on 16.5.23..
//

import UIKit
import Combine

final class ExploreViewController: UIViewController, Themeable {
    var hashtags: [PopularHashtag] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    let collectionLayout = CollectionViewCenteredFlowLayout()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    let searchView = SearchHeaderView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
        
        SocketRequest.init(name: "trending_hashtags_7d", payload: nil).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.hashtags  = result.popularHashtags
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(false, animated: animated)
        
        SocketRequest.init(name: "trending_hashtags_7d", payload: nil).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.hashtags  = result.popularHashtags
            }
            .store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func updateTheme() {
        collectionView.backgroundColor = .background2
        
        searchView.updateTheme()
    }
}

private extension ExploreViewController {
    func setup() {
        navigationItem.titleView = searchView
        searchView.addTarget(self, action: #selector(searchTapped), for: .touchDown)
        
        view.addSubview(collectionView)
        collectionView.pinToSuperview(safeArea: true)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HashtagCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        updateTheme()
    }
    
    @objc func searchTapped() {
        navigationController?.fadeTo(SearchViewController())
    }
}

extension ExploreViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let text = "#" + hashtags[indexPath.item].title
        let feed = RegularFeedViewController(feed: FeedManager(search: text))
        show(feed, sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hashtags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? HashtagCollectionViewCell {
            cell.label.text = hashtags[indexPath.item].title
            cell.updateTheme()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = hashtags[indexPath.item].title as NSString
        
        let textWidth = text.size(withAttributes: [.font : UIFont.appFont(withSize: 18, weight: .medium)]).width
        
        return .init(width: textWidth + 41, height: 36)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: 20, left: 20, bottom: 20, right: 20)
    }
}
