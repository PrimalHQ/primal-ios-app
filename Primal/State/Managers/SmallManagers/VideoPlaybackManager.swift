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

class VideoPlayer: NSObject {
    
    var didInitPlayer = false
    
    private var looper: AVPlayerLooper?
    lazy var avPlayer: AVPlayer = playerWithURL(url)
    
    @Published var isPlaying = false
    
    var shouldPause = false
    
    var url: String
    var userPubkey: String
    var originalURL: String
    
    init(url: String, originalURL: String, userPubkey: String) {
        self.url = url
        self.originalURL = originalURL
        self.userPubkey = userPubkey
        super.init()
        
        if ContentDisplaySettings.autoPlayVideos {
            _ = avPlayer // Force init
        }
    }
    
    deinit {
        
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
    
    private func playerWithURL(_ url: String) -> AVPlayer {
        let queuePlayer = AVQueuePlayer()
        
        if let url = URL(string: url) {
            let item = AVPlayerItem(url: url)
            looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            
            looper?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        }
        didInitPlayer = true
        return queuePlayer
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard
            keyPath == "status", 
            let item = object as? AVPlayerLooper,
            case .failed = item.status
        else { return }
        
        (object as? NSObject)?.removeObserver(self, forKeyPath: "status")
                
        attemptBlossomLoad()
    }
    
    @objc private func playerItemFailed(_ notification: Notification) {
        if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? NSError {
            print("AVPlayerItemFailedToPlayToEndTime: \(error.localizedDescription)")
        }
        attemptBlossomLoad()
    }

    func attemptBlossomLoad() {
        guard let finalURL: URL = { () -> URL? in
            guard
                let blossomInfo = BlossomServerManager.instance.serversForUser(pubkey: userPubkey),
                let firstServer = blossomInfo.first,
                let pathComponent = URL(string: originalURL)?.pathExtension
            else { return URL(string: originalURL) }
            
            let serverURL = blossomInfo.first(where: { !url.contains($0) }) ?? firstServer
            guard var finalURL = URL(string: serverURL) else { return URL(string: originalURL) }
            finalURL.append(path: pathComponent)
            return finalURL
        }()
        else { return }
        
        if finalURL.absoluteString == url {
            print("REACHED THE END OF BLOSSOM LIST")
            return
        }
        
        guard let queuePlayer = avPlayer as? AVQueuePlayer else { return }
        
        let item = AVPlayerItem(url: finalURL)
        url = finalURL.absoluteString
        looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        looper?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
    }
}
