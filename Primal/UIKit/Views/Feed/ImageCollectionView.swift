//
//  ImageCollectionView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import UIKit
import Kingfisher

protocol ImageCollectionViewDelegate: AnyObject {
    func didTapImage(url: URL, urls: [URL])
}

final class ImageCollectionView: UICollectionView {
    weak var imageDelegate: ImageCollectionViewDelegate?
    
    var imageURLs: [URL] {
        didSet {
            reloadData()
        }
    }
    
    init(urls: [URL] = []) {
        imageURLs = urls
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        dataSource = self
        delegate = self
        bounces = false
        register(ImageCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageDelegate?.didTapImage(url: imageURLs[indexPath.row], urls: imageURLs)
    }
}

extension ImageCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        (cell as? ImageCell)?.imageView.kf.setImage(with: imageURLs[indexPath.item], options: [
            .processor(DownsamplingImageProcessor(size: frame.size)),
            .transition(.fade(0.1)),
            .scaleFactor(UIScreen.main.scale),
            .cacheOriginalImage
        ])
        return cell
    }
}

final class ImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.pinToSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
