//
//  ExploreTopicsViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.9.24..
//

import UIKit
import Combine

final class ExploreTopicsViewController: UIViewController, Themeable {
    var hashtags: [PopularHashtag] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    let collectionLayout = CollectionViewCenteredFlowLayout()
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
    
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
    }
}

private extension ExploreTopicsViewController {
    func setup() {
        view.addSubview(collectionView)
        collectionView.pinToSuperview()
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HashtagCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.contentInset = .init(top: 157, left: 0, bottom: 80, right: 0)
        collectionView.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 50, right: 0)
        
        updateTheme()
    }
    
    @objc func searchTapped() {
        navigationController?.fadeTo(SearchViewController())
    }
}

extension ExploreTopicsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
