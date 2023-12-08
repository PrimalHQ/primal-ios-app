//
//  ImageCollectionView.swift
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

final class ImageCollectionView: UICollectionView {
    weak var imageDelegate: ImageCollectionViewDelegate?

    var resources: [MediaMetadata.Resource] {
        didSet {
            reloadData()
        }
    }
    
    var thumbnails: [String: String] = [:]

    init(resources: [MediaMetadata.Resource] = []) {
        self.resources = resources
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        super.init(frame: .zero, collectionViewLayout: layout)
        dataSource = self
        delegate = self
        bounces = false
        register(ImageCell.self, forCellWithReuseIdentifier: "image")
        register(VideoCell.self, forCellWithReuseIdentifier: "video")
        register(YoutubeVideoCell.self, forCellWithReuseIdentifier: "youtube")
    }
    
    func cellIdForURL(_ url: String) -> String { url.isVideoURL ? (url.isYoutubeVideo ? "youtube" : "video") : "image" }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageDelegate?.didTapMedia(resource: resources[indexPath.item])
    }
}

extension ImageCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resources.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let r = resources[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdForURL(r.url), for: indexPath)
        
        if r.url.isVideoURL {
            if r.url.isYoutubeVideo {
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
