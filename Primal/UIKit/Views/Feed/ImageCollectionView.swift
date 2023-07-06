//
//  ImageCollectionView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import UIKit
import Kingfisher
import FLAnimatedImage

protocol ImageCollectionViewDelegate: AnyObject {
    func didTapImage(resource: MediaMetadata.Resource)
}

final class ImageCollectionView: UICollectionView {
    weak var imageDelegate: ImageCollectionViewDelegate?

    var imageResources: [MediaMetadata.Resource] {
        didSet {
            reloadData()
        }
    }

    init(resources: [MediaMetadata.Resource] = []) {
        imageResources = resources
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
        imageDelegate?.didTapImage(resource: imageResources[indexPath.item])
    }
}

extension ImageCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageResources.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let r = imageResources[indexPath.item]
        
        if r.url.hasSuffix("gif"), let url = r.url(for: .large) {
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data else {
                    return
                }
                
                let anim = FLAnimatedImage(gifData: data)
                
                DispatchQueue.main.async {
                    (cell as? ImageCell)?.imageView.animatedImage = anim
                }
            }
            task.resume()
        } else {
            (cell as? ImageCell)?.imageView.kf.setImage(with: r.url(for: .large), options: [
                .processor(DownsamplingImageProcessor(size: frame.size)),
                .transition(.fade(0.1)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
        }
        return cell
    }
}

final class ImageCell: UICollectionViewCell {
    let imageView = FLAnimatedImageView()

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
