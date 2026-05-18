//
//  AudioWaveformView.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 5. 2026..
//

import UIKit

final class AudioWaveformView: UIView {
    static let barCount = 40

    var seed: String = "" {
        didSet { if seed != oldValue { regenerateHeights(); setNeedsLayout() } }
    }

    var progress: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }

    var onScrub: ((CGFloat) -> Void)?

    private var heights: [CGFloat] = []
    private var bars: [CALayer] = []
    private let containerLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(containerLayer)
        regenerateHeights()
        buildBars()

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleScrub))
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBars()
    }

    func setProgressInstant(_ value: CGFloat) {
        progress = max(0, min(1, value))
    }

    private func regenerateHeights() {
        var rng = SeededRandom(seed: seed.isEmpty ? "default" : seed)
        heights = (0..<Self.barCount).map { _ in CGFloat(rng.nextDouble(min: 0.18, max: 1.0)) }
    }

    private func buildBars() {
        bars.forEach { $0.removeFromSuperlayer() }
        bars.removeAll()
        for _ in 0..<Self.barCount {
            let bar = CALayer()
            bar.cornerRadius = 1
            containerLayer.addSublayer(bar)
            bars.append(bar)
        }
    }

    private func layoutBars() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        containerLayer.frame = bounds

        let totalSpacing: CGFloat = CGFloat(Self.barCount - 1) * 2
        let barWidth = max(1, (bounds.width - totalSpacing) / CGFloat(Self.barCount))
        let progressX = bounds.width * progress

        let foreground = UIColor.foreground.cgColor
        let dimmed = UIColor.foreground5.cgColor

        for (index, bar) in bars.enumerated() {
            let height = max(2, heights[index] * bounds.height)
            let x = CGFloat(index) * (barWidth + 2)
            let y = (bounds.height - height) / 2
            bar.frame = CGRect(x: x, y: y, width: barWidth, height: height)
            bar.backgroundColor = (x + barWidth / 2) <= progressX ? foreground : dimmed
        }
    }

    @objc private func handleScrub(_ gr: UIPanGestureRecognizer) {
        let location = gr.location(in: self)
        reportScrub(at: location.x)
    }

    @objc private func handleTap(_ gr: UITapGestureRecognizer) {
        let location = gr.location(in: self)
        reportScrub(at: location.x)
    }

    private func reportScrub(at x: CGFloat) {
        guard bounds.width > 0 else { return }
        let ratio = max(0, min(1, x / bounds.width))
        onScrub?(ratio)
    }
}

private struct SeededRandom {
    private var state: UInt64

    init(seed: String) {
        var hash: UInt64 = 1469598103934665603
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        self.state = hash == 0 ? 1 : hash
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }

    mutating func nextDouble(min: Double, max: Double) -> Double {
        let raw = Double(next() % 1_000_000) / 1_000_000
        return min + raw * (max - min)
    }
}
