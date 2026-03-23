//
//  WalletSpinnerView.swift
//  Primal
//
//  Created by Pavle Stevanović on 16. 2. 2026..
//

import Combine
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

    private let introView = PlayerView()
    private let loopView = PlayerView()
    private let endView = PlayerView()

    private var introPlayer: AVPlayer?
    private var loopPlayer: AVQueuePlayer?
    private var endPlayer: AVPlayer?

    private var looper: AVPlayerLooper?
    private var statusObservation: NSKeyValueObservation?
    private var didFinishCancellable: AnyCancellable?

    private var loopURL: URL?
    private var shouldStop = false

    let theme: Theme

    @MainActor required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init() {
        theme = .current.kind

        super.init()

        constrainToSize(640 / 2)

        let prefix = Theme.current.isDarkTheme ? "walletSendAnimationDark" : "walletSendAnimation"
        guard
            let introURL = Bundle.main.url(forResource: "\(prefix)1", withExtension: "mp4"),
            let loopURL = Bundle.main.url(forResource: "\(prefix)2", withExtension: "mp4"),
            let endURL = Bundle.main.url(forResource: "\(prefix)3", withExtension: "mp4")
        else {
            return
        }

        self.loopURL = loopURL

        introPlayer = AVPlayer(url: introURL)
        introView.player = introPlayer

        let loopQP = AVQueuePlayer()
        loopPlayer = loopQP
        loopView.player = loopQP

        endPlayer = AVPlayer(url: endURL)
        endView.player = endPlayer

        [introView, loopView, endView].forEach {
            addSubview($0)
            $0.pinToSuperview()
            $0.isHidden = true
        }
    }

    func startPlayback() {
        shouldStop = false
        didFinishCancellable = nil
        statusObservation = nil

        looper = nil
        if let loopURL, let loopPlayer {
            looper = AVPlayerLooper(player: loopPlayer, templateItem: .init(url: loopURL))
        }

        introPlayer?.seek(to: .zero)
        endPlayer?.seek(to: .zero)
        
        introView.isHidden = false
        loopView.isHidden = true
        endView.isHidden = true

        didFinishCancellable = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: introPlayer?.currentItem)
            .sink { [weak self] _ in
                self?.introDidFinish()
            }

        introPlayer?.play()
    }

    func stopLooping() {
        shouldStop = true
        guard let looper else { return }
        looper.disableLooping()

        guard let loopPlayer else { return }
        if loopPlayer.timeControlStatus == .paused {
            playEnd()
            return
        }
        statusObservation = loopPlayer.observe(\.timeControlStatus) { [weak self] player, _ in
            if player.timeControlStatus == .paused {
                self?.statusObservation = nil
                self?.playEnd()
            }
        }
    }

    private func introDidFinish() {
        if shouldStop {
            playEnd()
        } else {
            startLoop()
        }
    }

    private func startLoop() {
        guard let loopPlayer else { return }
        loopView.isHidden = false
        loopPlayer.play()
        introView.isHidden = true
    }

    private func playEnd() {
        looper = nil
        statusObservation = nil
        guard let endPlayer else { return }
        endView.isHidden = false
        endPlayer.play()
        loopView.isHidden = true
    }
}
