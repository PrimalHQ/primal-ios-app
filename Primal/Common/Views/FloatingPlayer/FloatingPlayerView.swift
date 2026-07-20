//
//  FloatingPlayerView.swift
//  Primal
//
//  Created by Pavle Stevanović on 28. 7. 2025..
//

import AVFoundation
import Combine
import UIKit

final class FloatingPlayerView: UIView {
    enum Mode {
        case none
        case live(LiveVideoPlayer)
        case audio(AudioPlayer)
    }

    @Published var showChevron = false

    private let leftChevron = UIImageView(image: .livePlayerChevron)
    private let rightChevron = UIImageView(image: .livePlayerChevron)

    private(set) var currentContent: (UIView & FloatingPlayerContent)?
    private var chevronCancellable: AnyCancellable?

    var mode: Mode = .none {
        didSet { applyMode() }
    }

    var liveContent: LivePlayerContentView? { currentContent as? LivePlayerContentView }
    var audioContent: AudioPlayerContentView? { currentContent as? AudioPlayerContentView }
    var livePlayerLayer: AVPlayerLayer? { liveContent?.livePlayerLayer }
    var livePlayer: LiveVideoPlayer? {
        if case .live(let p) = mode { return p }
        return nil
    }

    init() {
        super.init(frame: .zero)

        clipsToBounds = true
        layer.cornerRadius = 6
        backgroundColor = .black

        addSubview(leftChevron)
        leftChevron.pinToSuperview(edges: [.leading, .vertical])
        leftChevron.transform = .init(rotationAngle: .pi)

        addSubview(rightChevron)
        rightChevron.pinToSuperview(edges: [.trailing, .vertical])

        leftChevron.isHidden = true
        rightChevron.isHidden = true

        chevronCancellable = $showChevron
            .receive(on: DispatchQueue.main)
            .sink { [weak self] peeking in
                guard let self else { return }
                leftChevron.isHidden = !peeking
                rightChevron.isHidden = !peeking
                currentContent?.setPeeking(peeking)
            }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func applyMode() {
        currentContent?.removeFromSuperview()
        currentContent = nil

        // Always reset peek state when swapping modes so a new content starts visible.
        showChevron = false

        switch mode {
        case .none:
            backgroundColor = .clear
            return
        case .live(let player):
            backgroundColor = .black
            let content = LivePlayerContentView()
            content.setup(player: player)
            install(content)
        case .audio(let player):
            backgroundColor = .clear
            let content = AudioPlayerContentView()
            content.player = player
            content.onClose = {
                RootViewController.instance.dismissFloatingAudio(clearRegistry: false)
            }
            install(content)
        }
    }

    private func install(_ content: UIView & FloatingPlayerContent) {
        addSubview(content)
        content.pinToSuperview()
        bringSubviewToFront(leftChevron)
        bringSubviewToFront(rightChevron)
        currentContent = content
        content.setPeeking(showChevron)
    }
}
