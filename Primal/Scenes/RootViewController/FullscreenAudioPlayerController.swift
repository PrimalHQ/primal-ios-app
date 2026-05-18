//
//  FullscreenAudioPlayerController.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 5. 2026..
//

import AVKit

class FullscreenAudioPlayerController: AVPlayerViewController {
    
    let audio: AudioPlayer
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    init(audio: AudioPlayer) {
        self.audio = audio
        
        super.init(nibName: nil, bundle: nil)
        
        player = audio.avPlayer
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let shouldPlay = player?.rate ?? 0 > 0
        
        DispatchQueue.main.async {
            if shouldPlay {
                self.audio.play()
            } else {
                self.audio.pause()
            }
        }
    }
}
