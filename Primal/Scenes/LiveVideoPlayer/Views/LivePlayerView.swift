//
//  LivePlayerView.swift
//  Primal
//
//  Created by Pavle Stevanović on 14. 7. 2025..
//

import AVKit
import UIKit

class LivePlayerView: UIView {
    let playerView = PlayerView()
    var playerLayer: AVPlayerLayer { playerView.playerLayer }
    
    init() {
        super.init(frame: .zero)
        
        addSubview(playerView)
        playerView.pinToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
