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
            if isMuted {
                try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            } else {
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            }
            avPlayer.isMuted = isMuted
        }
    }
    
    @Published var isPlaying = false
    
    var shouldPause = false
    
    init(url: String, isMuted: Bool = true) {
        self.url = url
        self.isMuted = isMuted
        
        let queuePlayer = AVQueuePlayer()
        
        if let url = URL(string: url) {
            let item = AVPlayerItem(url: url)
            looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        }
        avPlayer = queuePlayer
        avPlayer.isMuted = isMuted
    }
    
    func play() {
        shouldPause = false
        isPlaying = true
        
        if isMuted {
            try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        } else {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        }
        
        VideoPlaybackManager.instance.currentlyPlaying = self
    }
    
    func pause() {
        isPlaying = false
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
