//
//  VideoCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 4.9.23..
//

import AVKit
import Combine
import UIKit

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
