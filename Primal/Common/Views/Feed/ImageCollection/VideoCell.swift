//
//  VideoCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.9.23..
//

import AVKit
import Combine
import UIKit
import Kingfisher
import Photos

final class VideoCell: UICollectionViewCell {
    let thumbnailImage = UIImageView()
    let playerView = PlayerView()
    let playIcon = UIImageView(image: UIImage(named: "playVideoLarge"))
    
    let durationLabel = UILabel()
    let muteButton = MuteButton()
    
    var muteUpdater: AnyCancellable?
    var playUpdater: AnyCancellable?
    
    var player: VideoPlayer? {
        didSet {
            muteUpdater = VideoPlaybackManager.instance.isMutedPublisher.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] isMuted in
                self?.muteButton.buttonState = isMuted ? .muted : .unmuted
            })
            
            playUpdater = player?.$isPlaying.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] isPlaying in
                self?.playIcon.isHidden = ContentDisplaySettings.autoPlayVideos || isPlaying
                self?.durationLabel.isHidden = isPlaying
                
                if isPlaying {
                    self?.playerView.playerLayer.player = self?.player?.avPlayer
                }
            })
        }
    }
    
    var duration: Int? {
        didSet {
            guard let duration, duration > 0 else {
                durationLabel.alpha = 0
                return
            }
            durationLabel.alpha = 1
            
            let lengthMin = duration / 60
            let secs = duration % 60
            
            durationLabel.text = String(format: "%02d:%02d", lengthMin, secs)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(thumbnailImage)
        thumbnailImage.pinToSuperview()
        thumbnailImage.contentMode = .scaleAspectFill
        thumbnailImage.setContentCompressionResistancePriority(.init(1), for: .vertical)
        thumbnailImage.clipsToBounds = true
        
        contentView.addSubview(playerView)
        playerView.pinToSuperview()
        playerView.playerLayer.contentsGravity = .resizeAspect
        
        contentView.addSubview(muteButton)
        muteButton.pinToSuperview(edges: [.trailing, .bottom], padding: 4).constrainToSize(44)
        
        contentView.addSubview(durationLabel)
        durationLabel.pinToSuperview(edges: .leading, padding: 4).centerToView(muteButton, axis: .vertical).constrainToSize(width: 60, height: 28)
        durationLabel.layer.cornerRadius = 14
        durationLabel.layer.masksToBounds = true
        durationLabel.textAlignment = .center
        durationLabel.backgroundColor = .black.withAlphaComponent(0.5)
        durationLabel.font = .appFont(withSize: 16, weight: .regular)
        durationLabel.textColor = .white
        
        contentView.addSubview(playIcon)
        playIcon.centerToSuperview()
        
        muteButton.addAction(.init(handler: { [weak self] _ in
            guard let player = self?.player, let button = self?.muteButton else { return }
            
            VideoPlaybackManager.instance.isMuted = !VideoPlaybackManager.instance.isMuted
        }), for: .touchUpInside)
        
        contentView.backgroundColor = .background3
        
        let interaction = UIContextMenuInteraction(delegate: self)
        contentView.addInteraction(interaction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        playerView.playerLayer.player = nil
    }
    
    func setup(player: VideoPlayer, duration: Int, thumbnail: String?) {
        self.player = player
        thumbnailImage.image = nil
        self.duration = duration
        
        if let thumbnailString = thumbnail {
            thumbnailImage.kf.setImage(with: URL(string: thumbnailString))
        }
    }
    
    func showToast(_ text: String) {
        guard let mainTab: MainTabBarController = RootViewController.instance.findInChildren() else {
            RootViewController.instance.view?.showToast(text, extraPadding: 0)
            return
        }
        mainTab.showToast(text)
    }
}

extension VideoCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { suggestedActions in
                UIMenu(title: "", children: [
                    UIAction(title: "Save Video", image: UIImage(named: "MenuImageSave"), handler: { [weak self] _ in
                        guard let self, let videoPath = player?.url ?? player?.originalURL else { return }
                        saveVideo(videoPath)
                    }),
                    UIAction(title: "Share Video", image: UIImage(named: "MenuImageShare"), handler: { [weak self] _ in
                        guard let self, let videoPath = player?.originalURL else { return }
                        let activityViewController = UIActivityViewController(activityItems: [videoPath], applicationActivities: nil)
                        RootViewController.instance.present(activityViewController, animated: true, completion: nil)
                    }),
                    UIAction(title: "Copy Video URL", image: UIImage(named: "MenuCopyLink")) { [weak self] _ in
                        guard let self, let url = player?.originalURL else { return }
                        UIPasteboard.general.string = url
                        showToast("Copied!", extraPadding: 0)
                    }
                ] + suggestedActions)
            })
    }
    
    func saveVideo(_ urlString: String) {
        guard 
            let url = URL(string: urlString),
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        else { return }
        
        showToast("Downloading!", extraPadding: 0)
        
        DispatchQueue.global(qos: .background).async {
            let urlData = NSData(contentsOf: url)
            let filePath="\(documentsPath)/tempFile.mp4"
            DispatchQueue.main.async {
                urlData?.write(toFile: filePath, atomically: true)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                }) { completed, error in
                    if completed {
                        DispatchQueue.main.async {
                            RootViewController.instance.view?.showToast("Saved!", extraPadding: 0)
                        }
                    }
                }
            }
        }
    }
}

final class PlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
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
