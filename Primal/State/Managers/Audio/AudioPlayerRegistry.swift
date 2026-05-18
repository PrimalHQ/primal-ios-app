//
//  AudioPlayerRegistry.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 5. 2026..
//

import Foundation

final class AudioPlayerRegistry {
    static let instance = AudioPlayerRegistry()

    private var byURL: [String: AudioPlayer] = [:]

    func player(for audio: ParsedAudio) -> AudioPlayer {
        if let existing = byURL[audio.url] { return existing }

        let domain = URL(string: audio.url)?.host?
            .split(separator: ".")
            .suffix(2)
            .joined(separator: ".") ?? ""

        let player = AudioPlayer(
            url: audio.url,
            title: audio.title,
            domain: domain,
            imetaDuration: audio.duration
        )
        byURL[audio.url] = player
        return player
    }

    func drop(url: String) {
        byURL[url] = nil
    }

    var currentAudioPlayer: AudioPlayer? {
        VideoPlaybackManager.instance.currentlyPlaying as? AudioPlayer
    }
}
