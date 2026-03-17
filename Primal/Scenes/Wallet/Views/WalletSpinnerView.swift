//
//  WalletSpinnerView.swift
//  Primal
//
//  Created by Pavle Stevanović on 16. 2. 2026..
//

import UIKit
import AVFoundation

class WalletSpinnerView: PlayerView {
    private static var _reusable = WalletSpinnerView()
    static var reusable: WalletSpinnerView {
        if _reusable.theme.theme.isDarkTheme != Theme.current.isDarkTheme {
            _reusable = WalletSpinnerView()
        }
        return _reusable
    }
    
    private var queuePlayer: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    
    let theme: Theme
    
    @MainActor required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init() {
        theme = .current.kind
        
        super.init()
        
        let prefix = Theme.current.isDarkTheme ? "walletSendAnimationDark" : "walletSendAnimation"
        guard
            let introURL = Bundle.main.url(forResource: "\(prefix)1", withExtension: "mp4"),
            let loopURL = Bundle.main.url(forResource: "\(prefix)2", withExtension: "mp4"),
            let endURL = Bundle.main.url(forResource: "\(prefix)3", withExtension: "mp4")
        else {
            return
        }
        
        let introItem = AVPlayerItem(url: introURL)
        let loopItem = AVPlayerItem(url: loopURL)
        let endItem = AVPlayerItem(url: endURL)
        let player = AVQueuePlayer(items: [introItem, loopItem, endItem])
        
        looper = AVPlayerLooper(player: player, templateItem: loopItem)
        queuePlayer = player
        self.player = player
            
        constrainToSize(640 / 2)
    }
    
    func startPlayback() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    func stopLooping() {
        // looper?.disableLooping()§
    }
}
