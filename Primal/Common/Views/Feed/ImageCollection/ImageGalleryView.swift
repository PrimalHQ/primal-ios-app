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
    func didTapMediaInCollection(_ collection: ImageGalleryView, resource: MediaMetadata.Resource)
}

class FullScreenFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        scrollDirection = .horizontal
        
        guard let collectionView = collectionView else { return }
        
        // Set item size to match the collection view's bounds
        itemSize = collectionView.bounds.size
//        minimumLineSpacing = 0
//        minimumInteritemSpacing = 0
    }
}

class SizeReloadingCollectionView: UICollectionView {
    var size: CGSize = .zero
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if frame.size != size {
            size = frame.size
            collectionViewLayout.invalidateLayout()
        }
    }
}

final class ImageGalleryView: UIView {
    weak var imageDelegate: ImageCollectionViewDelegate?
    
    lazy var collection = SizeReloadingCollectionView(frame: .zero, collectionViewLayout: FullScreenFlowLayout())
    
    let progress = PrimalProgressView(bottomPadding: 0)

    var noDownsampling = false
    var userPubkey = ""
    var resources: [MediaMetadata.Resource] {
        didSet {
            progress.isHidden = resources.count < 2
            progress.currentPage = 0
            progress.numberOfPages = resources.count
            
            collection.reloadData()
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
        progress.isHidden = true
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageDelegate?.didTapMediaInCollection(self, resource: resources[indexPath.item])
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
        let adjustedVelocity = velocity.x.clamp(-0.5, 0.5)
        let adjusted = (current + adjustedVelocity).clamp(0, CGFloat(resources.count))
        let endPoint = adjusted.rounded() * (collection.frame.width + 10)
        
        if abs(current - endPoint) > 150 || abs(current - targetContentOffset.pointee.x) > 100 {
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
            
            let url = r.url(for: .small)?.absoluteString ?? r.url
            
            let player: VideoPlayer
            if let current = VideoPlaybackManager.instance.currentlyPlaying, current.url == url {
                player = current
            } else {
                player = .init(url: url, originalURL: r.url, userPubkey: userPubkey)
            }
            
            if let cell = cell as? VideoCell {
                cell.player = player
                cell.thumbnailImage.image = nil
                cell.duration = r.variants.compactMap({ $0.dur }).map({ Int($0) }).first
                
                if let thumbnailString = thumbnails[r.url], let url = URL(string: thumbnailString) {
                    cell.thumbnailImage.kf.setImage(with: url)
                }
            }
        } else if r.url.hasSuffix("gif"), let url = r.url(for: .medium), ContentDisplaySettings.autoPlayVideos {
            CachingManager.instance.fetchAnimatedImage(url) { [weak self] result in
                switch result {
                case .success(let image):
                    (cell as? ImageCell)?.imageView.animatedImage = image
                case .failure:
                    (cell as? ImageCell)?.setup(
                        url: r.url(for: .medium),
                        downsampling: .none,
                        originalUrl: r.url,
                        userPubkey: self?.userPubkey ?? "",
                        delegate: self
                    )
                }
            }
        } else {
            (cell as? ImageCell)?.setup(
                url: r.url(for: .medium),
                downsampling: noDownsampling ? .none : .size(frame.size),
                originalUrl: r.url,
                userPubkey: userPubkey,
                delegate: self
            )
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let videoCell = cell as? VideoCell {
            if videoCell.player?.isPlaying == true {
                videoCell.player?.delayedPause()
            }
        }
        if let cell = cell as? YoutubeVideoCell {
            cell.videoView.metadata = .init()
        }
    }
}

extension ImageGalleryView: ImageCellDelegate {
    func imagePreviewTappedFromCell(_ cell: ImageCell) {
        guard let media = resources[safe: collection.indexPath(for: cell)?.item] else { return }
        imageDelegate?.didTapMediaInCollection(self, resource: media)
    }
}
