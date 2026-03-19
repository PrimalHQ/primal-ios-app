//
//  CacheBreakdownView.swift
//  Primal
//
//  Created by Pavle Stevanović on 19.3.26..
//

import Combine
import UIKit

final class CacheBreakdownView: UIView {
    private let imagesColor = UIColor(rgb: 0xBC1870)
    private let gifsColor = UIColor(rgb: 0xFF9F2F)
    private let databaseColor = UIColor(rgb: 0x0090F8)
    private let urlCacheColor = UIColor(rgb: 0x52CE0D)
    private let tempColor = UIColor(rgb: 0xAAAAAA)

    private let totalLabel = UILabel("Calculating...", color: .foreground, font: .appFont(withSize: 16, weight: .semibold))

    private lazy var graphViewImages = SpacerView(color: imagesColor)
    private lazy var graphViewGifs = SpacerView(color: gifsColor)
    private lazy var graphViewDatabase = SpacerView(color: databaseColor)
    private lazy var graphViewURLCache = SpacerView(color: urlCacheColor)
    private lazy var graphViewTemp = SpacerView(color: tempColor)

    private let graphBar = SpacerView(height: 22, color: .foreground6, priority: .required)
    private var graphConstraints: [NSLayoutConstraint] = []

    var cancellables: Set<AnyCancellable> = []

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func startObserving() {
        LocalCacheManager.instance.recalculate()

        LocalCacheManager.instance.$cacheSizeInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                self?.updateGraph(info)
            }
            .store(in: &cancellables)
    }
}

private extension CacheBreakdownView {
    func setup() {
        graphBar.layer.cornerRadius = 4
        graphBar.clipsToBounds = true

        let segments = [graphViewImages, graphViewGifs, graphViewDatabase, graphViewURLCache, graphViewTemp]
        let segmentStack = UIStackView(segments)
        segmentStack.spacing = 1

        let stackParent = SpacerView(color: .background)
        stackParent.addSubview(segmentStack)
        segmentStack.pinToSuperview(edges: [.leading, .vertical]).pinToSuperview(edges: .trailing, padding: 1)

        graphBar.addSubview(stackParent)
        stackParent.pinToSuperview(edges: [.vertical, .leading])

        let legendRow1 = UIStackView([
            DotView(color: imagesColor), SpacerView(width: 4), UILabel("Images", color: .foreground3, font: .appFont(withSize: 14, weight: .regular)), SpacerView(width: 16),
            DotView(color: gifsColor), SpacerView(width: 4), UILabel("GIFs", color: .foreground3, font: .appFont(withSize: 14, weight: .regular)), SpacerView(width: 16),
            DotView(color: databaseColor), SpacerView(width: 4), UILabel("Database", color: .foreground3, font: .appFont(withSize: 14, weight: .regular)), UIView()
        ])
        legendRow1.alignment = .center

        let legendRow2 = UIStackView([
            DotView(color: urlCacheColor), SpacerView(width: 4), UILabel("URLCache", color: .foreground3, font: .appFont(withSize: 14, weight: .regular)), SpacerView(width: 16),
            DotView(color: tempColor), SpacerView(width: 4), UILabel("Temp", color: .foreground3, font: .appFont(withSize: 14, weight: .regular)), UIView()
        ])
        legendRow2.alignment = .center

        let mainStack = UIStackView(axis: .vertical, [totalLabel, SpacerView(height: 8), graphBar, SpacerView(height: 8), legendRow1, legendRow2])
        mainStack.spacing = 4

        addSubview(mainStack)
        mainStack.pinToSuperview()
    }

    func updateGraph(_ info: CacheSizeInfo) {
        for constraint in graphConstraints {
            constraint.isActive = false
        }
        graphConstraints = []

        let total = max(info.totalBytes, 1)

        totalLabel.text = "\(info.formattedTotal) total cache"

        let segments: [(view: UIView, bytes: UInt64)] = [
            (graphViewImages, info.imagesBytes),
            (graphViewGifs, info.gifsBytes),
            (graphViewDatabase, info.databaseBytes),
            (graphViewURLCache, info.urlCacheBytes),
            (graphViewTemp, info.tempFilesBytes),
        ]

        for (view, bytes) in segments {
            let ratio = CGFloat(bytes) / CGFloat(total)
            view.isHidden = ratio < 0.005

            if !view.isHidden {
                let constraint = graphBar.widthAnchor.constraint(
                    equalTo: view.widthAnchor, multiplier: 1 / max(0.001, ratio), constant: 3
                )
                graphConstraints.append(constraint)
            }
        }

        NSLayoutConstraint.activate(graphConstraints)
    }
}
