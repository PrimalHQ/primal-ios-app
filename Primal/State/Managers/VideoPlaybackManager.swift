//
//  VideoPlaybackManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 29.8.23..
//

import Foundation
import AVFoundation

final class VideoPlaybackManager {
    static let instance = VideoPlaybackManager()
    
    var currentlyPlaying: VideoPlayer? {
        didSet {
            if oldValue !== currentlyPlaying {
                oldValue?.pause()
            }
            
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            currentlyPlaying?.avPlayer.play()
        }
    }
}

class VideoPlayer {
    let url: String
    
    let avPlayer: AVPlayer
    private var looper: AVPlayerLooper?
    
    @Published var isMuted = true {
        didSet {
            avPlayer.isMuted = isMuted
        }
    }
    
    var shouldPause = false
    
    init(url: String, isMuted: Bool = true) {
        self.url = url
        self.isMuted = isMuted
        
        let queuePlayer = AVQueuePlayer()
        
        let item = AVPlayerItem(url: URL(string: url) ?? URL(string: "https://google.com")!)
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        avPlayer = queuePlayer
        avPlayer.isMuted = isMuted
    }
    
    func play() {
        shouldPause = false
        VideoPlaybackManager.instance.currentlyPlaying = self
    }
    
    func pause() {
        shouldPause = false
        avPlayer.pause()
    }
    
    func delayedPause() {
        shouldPause = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
            if self.shouldPause {
                self.pause()
            }
        }
    }
}
