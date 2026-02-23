//
//  PostingImageView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 24.7.23..
//

import UIKit
import AVFoundation
import FLAnimatedImage

protocol PostingImageCollectionViewDelegate: AnyObject {
    func didTapImage(resource: PostingAsset)
    func didTapDeleteImage(resource: PostingAsset)
}

final class PostingImageCollectionView: UICollectionView {
    weak var imageDelegate: PostingImageCollectionViewDelegate?

    var imageResources: [PostingAsset] = [] {
        didSet {
            reloadData()
        }
    }
    
    let height: CGFloat

    init(height: CGFloat = 145, inset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 88, bottom: 0, right: 16)) {
        self.height = height
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = inset
        super.init(frame: .zero, collectionViewLayout: layout)
        dataSource = self
        delegate = self
        bounces = false
        showsHorizontalScrollIndicator = false
        register(PostingImageCell.self, forCellWithReuseIdentifier: "cell")
        
        constrainToSize(height: height)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PostingImageCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let image = imageResources[indexPath.item].resource?.thumbnailImage else {
            return .init(width: height, height: height)
        }
        
        return .init(width: image.size.width / image.size.height * height, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageDelegate?.didTapImage(resource: imageResources[indexPath.item])
    }
}

extension PostingImageCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageResources.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let r = imageResources[indexPath.item]
        
        if let cell = cell as? PostingImageCell {
            if let thumnail = r.resource?.animatedImage {
                cell.imageView.animatedImage = thumnail
            } else if let image = r.resource?.thumbnailImage {
                cell.imageView.image = image
                cell.playerView.isHidden = true
            } else {
                if case .uploaded(let url) = r.state {
                    if url.isVideoURL {
                        Connection.regular.requestCache(name: "get_media_metadata", payload: ["urls": [.string(url)]]) { result in
                            guard 
                                let resource: MediaMetadata = result.first?.objectValue?["content"]?.stringValue?.decode(),
                                let thumbnail = resource.thumbnails?.first?.value
                            else {
                                DispatchQueue.main.async {
                                    guard let url = URL(string: url) else { return }
                                    cell.playerView.playerLayer.player = AVPlayer(url: url)
                                    cell.playerView.playerLayer.player?.isMuted = true
                                    cell.playerView.isHidden = false
                                }
                                return
                            }
                            
                            DispatchQueue.main.async {
                                cell.imageView.kf.setImage(with: URL(string: thumbnail))
                            }
                        }
                    } else {
                        cell.imageView.kf.setImage(with: URL(string: url))
                    }
                }
            }
            cell.delegate = self
            
            switch r.state {
            case .failed:
                cell.loadingParent.isHidden = false
                cell.loadingIndicator.isHidden = true
            case .uploading(let progress):
                cell.loadingParent.isHidden = false
                cell.loadingIndicator.isHidden = false
                if progress < 0.01 {
                    cell.loadingIndicator.progress = progress
                } else {
                    cell.loadingIndicator.setProgressWithAnimation(duration: 0.1, value: progress)
                }
            case .uploaded:
                cell.loadingParent.isHidden = true
            }
        }
        
        return cell
    }
}

extension PostingImageCollectionView: PostingImageCellDelegate {
    func deleteButtonPressed(in cell: PostingImageCell) {
        guard let indexPath = indexPath(for: cell) else { return }
        imageDelegate?.didTapDeleteImage(resource: imageResources[indexPath.item])
    }
}

protocol PostingImageCellDelegate: AnyObject {
    func deleteButtonPressed(in cell: PostingImageCell)
}

final class PostingImageCell: UICollectionViewCell {
    
    weak var delegate: PostingImageCellDelegate?
    
    let imageView = FLAnimatedImageView()
    let playerView = PlayerView()
    let playButton = UIImageView(image: .videoPlay)
    let xButton = UIButton()
    
    let loadingParent = UIView()
    let loadingIndicator = CircularProgressView(frame: .init(origin: .zero, size: .init(width: 34, height: 34)))

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.pinToSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        
        contentView.addSubview(playerView)
        playerView.pinToSuperview()
        playerView.layer.cornerRadius = 8
        playerView.layer.masksToBounds = true
        
        playerView.addSubview(playButton)
        playButton.centerToSuperview()
        playerView.isHidden = true
        
        playerView.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            guard let self, let player = playerView.playerLayer.player else { return }
            if player.rate == 0 {
                player.play()
                playButton.isHidden = true
            } else {
                player.pause()
                playButton.isHidden = false
            }
        }))
        
        contentView.addSubview(loadingParent)
        loadingParent.pinToSuperview()
        loadingParent.backgroundColor = .background2.withAlphaComponent(0.5)
        
        loadingParent.addSubview(loadingIndicator)
        loadingIndicator.constrainToSize(34).centerToSuperview()
        
        contentView.addSubview(xButton)
        xButton.constrainToSize(24).pinToSuperview(edges: [.top, .trailing], padding: 4)
        xButton.setImage(UIImage(named: "deleteImageIcon"), for: .normal)
        xButton.addAction(.init(handler: { [unowned self] _ in
            self.delegate?.deleteButtonPressed(in: self)
        }), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        playerView.isHidden = true
        playButton.isHidden = false
    }
}
