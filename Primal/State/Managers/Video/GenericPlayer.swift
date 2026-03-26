//
//  GenericPlayer.swift
//  Primal
//
//  Created by Pavle Stevanović on 11. 12. 2025..
//

import AVKit
import Foundation

protocol PlayableProtocol {
    func playSpecial()
    func pause()
    var isMuted: Bool { get set }
}

protocol PlayerProtocol: AnyObject {
    func play()
    func pause()
    func delayedPause()

    func setMuted(_ isMuted: Bool)

    var isPlaying: Bool { get }
    var blocksAutoplay: Bool { get }
}

extension PlayerProtocol {
    var delayedPauseInterval: Int { 700 }
    var blocksAutoplay: Bool { false }
}

class GenericPlayer<T: PlayableProtocol>: NSObject, PlayerProtocol {
    func setMuted(_ isMuted: Bool) {
        underlyingPlayer.isMuted = isMuted
    }
    
    lazy var underlyingPlayer: PlayableProtocol = playerInit()
    
    @Published private(set) var isPlaying = false
    var shouldPause = false
    
    let playerInit: () -> T
    init(playerInit: @escaping () -> T) {
        self.playerInit = playerInit
    }
    
    func play() {
        shouldPause = false
        isPlaying = true
        underlyingPlayer.playSpecial()

        VideoPlaybackManager.instance.currentlyPlaying = self
    }
    
    func pause() {
        isPlaying = false
        shouldPause = false
        
        underlyingPlayer.pause()
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

extension AVPlayer: PlayableProtocol {
    func playSpecial() { play() }
}
extension AVAudioPlayer: PlayableProtocol {
    var isMuted: Bool {
        get {
            volume < 0.01
        }
        set {
            volume = newValue ? 0 : 1
        }
    }
    
    func playSpecial() { play() }
}
