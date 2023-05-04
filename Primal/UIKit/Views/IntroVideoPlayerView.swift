//
//  IntroVideoPlayerView.swift
//  Primal
//
//  Created by Pavle D Stevanović on 22.4.23..
//

import AVKit
import UIKit

class IntroVideoPlayerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    let player = AVPlayer()
    
    init() {
        super.init(frame: .zero)
        
        playerLayer.player = player
        
        guard let path = Bundle.main.path(forResource: "Intro", ofType:"mov") else {
            debugPrint("Intro.mov not found")
            return
        }
        let item = AVPlayerItem(url: URL(fileURLWithPath: path))
        player.replaceCurrentItem(with: item)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func play() {
        playerLayer.player?.play()
    }
}
