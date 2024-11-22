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
    
    @Published var isMuted = true {
        didSet {
            if isMuted {
                try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            } else {
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            }
            currentlyPlaying?.avPlayer.isMuted = isMuted
        }
    }
    
    var currentlyPlaying: VideoPlayer? {
        didSet {
            if oldValue !== currentlyPlaying {
                oldValue?.pause()
            }
            
            currentlyPlaying?.avPlayer.isMuted = isMuted
            currentlyPlaying?.avPlayer.play()
        }
    }
}

class VideoPlayer {
    let url: String
    
    var didInitPlayer = false
    
    private var looper: AVPlayerLooper?
    lazy var avPlayer: AVPlayer = {
        let queuePlayer = AVQueuePlayer()
        
        if let url = URL(string: url) {
            let item = AVPlayerItem(url: url)
            looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        }
        didInitPlayer = true
        return queuePlayer
    }()
    
    @Published var isPlaying = false
    
    var shouldPause = false
    
    init(url: String) {
        self.url = url
        
        if ContentDisplaySettings.autoPlayVideos {
            _ = avPlayer // Force init
        }
    }
    
    func play() {
        shouldPause = false
        isPlaying = true
        
//        avPlayer.isMuted = isMuted
//        if isMuted {
//            try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
//        } else {
//            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//        }
        
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
