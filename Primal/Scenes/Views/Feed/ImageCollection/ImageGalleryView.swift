//
//  ImageGalleryView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 3.5.23..
//

import UIKit
import Combine
import Kingfisher
import FLAnimatedImage
import AVFoundation

protocol ImageCollectionViewDelegate: AnyObject {
    func didTapMedia(resource: MediaMetadata.Resource)
}

final class ImageGalleryView: UIView {
    weak var imageDelegate: ImageCollectionViewDelegate?
    
    let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    lazy var collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    let progress = PrimalProgressView(bottomPadding: 0)

    var resources: [MediaMetadata.Resource] {
        didSet {
            collection.reloadData()
            
            progress.isHidden = resources.count < 2
            progress.currentPage = 0
            progress.numberOfPages = resources.count
        }
    }
    
    var thumbnails: [String: String] = [:]

    init(resources: [MediaMetadata.Resource] = []) {
        self.resources = resources
        super.init(frame: .zero)
        collection.dataSource = self
        collection.delegate = self
        collection.bounces = false
        collection.register(ImageCell.self, forCellWithReuseIdentifier: "image")
        collection.register(VideoCell.self, forCellWithReuseIdentifier: "video")
        collection.register(YoutubeVideoCell.self, forCellWithReuseIdentifier: "youtube")
        
        collection.layer.cornerRadius = 8
        collection.layer.masksToBounds = true
        collection.backgroundColor = .background2
        collection.showsHorizontalScrollIndicator = false
        
        let stack = UIStackView(axis: .vertical, [collection, progress])
        stack.spacing = 8
        addSubview(stack)
        stack.pinToSuperview()
        progress.primaryColor = .foreground
        progress.secondaryColor = .foreground.withAlphaComponent(0.4)
    }
    
    func cellIdForURL(_ url: String) -> String { url.isVideoURL ? (url.isYoutubeVideoURL ? "youtube" : "video") : "image" }
    
    func currentImageCell() -> ImageCell? {
        collection.visibleCells.compactMap({ $0 as? ImageCell }).first
    }
    
    func currentVideoCell() -> VideoCell? {
        collection.visibleCells.compactMap({ $0 as? VideoCell }).first
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageGalleryView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageDelegate?.didTapMedia(resource: resources[indexPath.item])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex = (scrollView.contentOffset.x / scrollView.frame.width) + 0.5
        progress.currentPage = Int(currentIndex)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        
        scrollToCurrent()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let current = collection.contentOffset.x / (collection.frame.width + 10)
        let adjusted = (current + velocity.x).clamp(0, CGFloat(resources.count))
        let endPoint = adjusted.rounded() * (collection.frame.width + 10)
        
        if abs(current - endPoint) > 150 && abs(current - targetContentOffset.pointee.x) > 100 {
            targetContentOffset.pointee.x = endPoint
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToCurrent()
    }
    
    func scrollToCurrent() {
        let x = (collection.contentOffset.x / collection.frame.width).rounded() * (collection.frame.width + 10)
        collection.setContentOffset(.init(x: x, y: 0), animated: true)
    }
}

extension ImageGalleryView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resources.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let r = resources[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdForURL(r.url), for: indexPath)
        
        if r.url.isVideoURL {
            if r.url.isYoutubeVideoURL {
                (cell as? YoutubeVideoCell)?.loadURL(r.url)
                return cell
            }
            
            let player: VideoPlayer
            if let current = VideoPlaybackManager.instance.currentlyPlaying, current.url == r.url {
                player = current
            } else {
                player = .init(url: r.url)
            }
            
            if let cell = cell as? VideoCell {
                cell.player = player
                cell.thumbnailImage.image = nil
                if let thumbnailString = thumbnails[r.url], let url = URL(string: thumbnailString) {
                    cell.thumbnailImage.kf.setImage(with: url)
                }
            }
        } else if r.url.hasSuffix("gif"), let url = r.url(for: .large) {
            CachingManager.instance.fetchAnimatedImage(url) { result in
                switch result {
                case .success(let image):
                    (cell as? ImageCell)?.imageView.animatedImage = image
                case .failure(let error):
                    print(error)
                }
            }
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let videoCell = cell as? VideoCell {
            if videoCell.player?.avPlayer.rate ?? 0 > 0 {
                videoCell.player?.delayedPause()
            }
        }
        if let cell = cell as? YoutubeVideoCell {
            cell.videoView.metadata = .init()
        }
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
        
        contentView.backgroundColor = .background3
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
