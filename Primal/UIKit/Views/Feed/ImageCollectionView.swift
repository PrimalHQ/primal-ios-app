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
        imageDelegate?.didTapMedia(resource: resources[indexPath.item])
    }
}

extension ImageCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        resources.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let r = resources[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: r.url.isVideoURL ? "video" : "image", for: indexPath)
        
        if r.url.isVideoURL {
            guard let url = URL(string: r.url) else { return cell }
            
            let player: VideoPlayer
            if let current = VideoPlaybackManager.instance.currentlyPlaying, current.url == r.url {
                player = current
            } else {
                player = .init(url: r.url)
            }
            
            if let cell = cell as? VideoCell {
                cell.player = player
            }
            player.play()
        } else if r.url.hasSuffix("gif"), let url = r.url(for: .large) {
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let videoCell = cell as? VideoCell else { return }
        if videoCell.player?.avPlayer.rate ?? 0 > 0 {
            videoCell.player?.delayedPause()
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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class VideoCell: UICollectionViewCell {
    let playerView = PlayerView()
    
    let muteButton = MuteButton()
    
    var muteUpdater: AnyCancellable?
    
    var player: VideoPlayer? {
        didSet {
            playerView.playerLayer.player = player?.avPlayer
            
            muteUpdater = player?.$isMuted.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] isMuted in
                self?.muteButton.buttonState = isMuted ? .muted : .unmuted
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(playerView)
        playerView.pinToSuperview()
        playerView.playerLayer.contentsGravity = .resizeAspect
        
        contentView.addSubview(muteButton)
        muteButton.pinToSuperview(edges: [.trailing, .bottom], padding: 4).constrainToSize(44)
        
        muteButton.addAction(.init(handler: { [weak self] _ in
            guard let player = self?.player, let button = self?.muteButton else { return }
            
            player.isMuted = !player.isMuted
            
            button.buttonState = player.isMuted ? .muted : .unmuted
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class PlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    init() {
        super.init(frame: .zero)
        playerLayer.videoGravity = .resizeAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class MuteButton: MyButton {
    enum State {
        case muted, unmuted, noaudio
        
        var imageName: String {
            switch self {
            case .muted:    return "videoMuted"
            case .unmuted:  return "videoUnmuted"
            case .noaudio:  return "videoUnmuted"
            }
        }
    }
    
    let imageView = UIImageView(image: .init(named: "videoMuted"))
    
    var buttonState = State.muted {
        didSet {
            imageView.image = UIImage(named: buttonState.imageName)
        }
    }
    
    init(buttonState: State = State.muted) {
        self.buttonState = buttonState
        super.init(frame: .zero)
        
        let background = SpacerView(width: 28, height: 28, color: .black.withAlphaComponent(0.5))
        background.layer.cornerRadius = 14
        addSubview(background)
        background.centerToSuperview()
        
        addSubview(imageView)
        imageView.pinToSuperview()
        imageView.contentMode = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
