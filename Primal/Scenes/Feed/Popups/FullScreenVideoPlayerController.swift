//
//  FullScreenVideoPlayerController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.11.23..
//

import UIKit
import AVKit

final class FullScreenVideoPlayerController: AVPlayerViewController {
    
    static weak var instance: FullScreenVideoPlayerController?
    
    let video: VideoPlayer
    
    init(_ video: VideoPlayer) {
        self.video = video
        super.init(nibName: nil, bundle: nil)
        player = video.avPlayer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        video.play()  // Necessary to cancel delayed pause
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        player?.isMuted = false
        player?.play()
        
        Self.instance = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        video.avPlayer.isMuted = VideoPlaybackManager.instance.isMuted
        
        if !ContentDisplaySettings.autoPlayVideos {
            // Video will automatically pause from AVKit so we need to inform our part of the code not to resume it
            video.pause()
        }
    }
}
