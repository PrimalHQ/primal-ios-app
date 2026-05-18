//
//  PostingPreviewEmbedsView.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.5.26..
//

import Combine
import FLAnimatedImage
import Kingfisher
import UIKit

extension UIButton.Configuration {
    static var previewEmbedsClose: UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .small
        config.image = .close
        config.baseBackgroundColor = .background3
        config.baseForegroundColor = .accent
        return config
    }
}

final class PostingPreviewEmbedsView: UIView {

    private static let chipSize: CGFloat = 68
    static let viewHeight: CGFloat = 80
    private static let chipCornerRadius: CGFloat = 10
    private static let countBadgeSize: CGFloat = 28

    private let countBadge = UIView()
    private let countLabel = UILabel()
    private let closeButton = UIButton(configuration: .previewEmbedsClose)
    private var chipViews: [UIButton] = []
    private var cancellables: Set<AnyCancellable> = []

    private let chipStack = UIStackView(axis: .horizontal, spacing: -PostingPreviewEmbedsView.chipSize, [])

    private var widthC: NSLayoutConstraint?

    private weak var manager: PostingTextViewManager?

    @Published var isExpanded: Bool = false

    var isShowingPublisher: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()

    init() {
        super.init(frame: .zero)
        clipsToBounds = false
        isHidden = true
        constrainToSize(height: Self.viewHeight)
        widthC = widthAnchor.constraint(equalToConstant: Self.viewHeight)
        widthC?.isActive = true

        let scrollView = UIScrollView()
        addSubview(scrollView)
        scrollView.pinToSuperview()
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.addSubview(chipStack)
        chipStack.pinToSuperview(padding: (Self.viewHeight - Self.chipSize) / 2)

        addSubview(closeButton)
        closeButton.constrainToSize(Self.chipSize  / 2).pinToSuperview(edges: .trailing, padding: Self.chipSize  / 4).centerToSuperview(axis: .vertical)

        setupCountBadge()

        closeButton.addAction(.init(handler: { [weak self] _ in
            self?.isExpanded = false
        }), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func expandButtonTapped() {
        guard chipViews.count == 1, let only = chipViews.first else {
            isExpanded = true
            return
        }
        only.sendActions(for: .touchUpInside)
    }

    func bind(to manager: PostingTextViewManager) {
        cancellables = []
        self.manager = manager

        let updatePublisher = Publishers.CombineLatest3(manager.$media, manager.$embeddedElements, manager.$pollOptions)
            .debounce(for: 0.1, scheduler: DispatchQueue.main)

        updatePublisher
            .sink { [weak self] media, embeds, poll in
                self?.rebuild(media: media, embeds: embeds, poll: poll)
            }
            .store(in: &cancellables)

        isShowingPublisher = updatePublisher
                .map { media, elements, poll in
                    !(media.isEmpty && elements.isEmpty && poll == nil)
                }
                .removeDuplicates()
                .eraseToAnyPublisher()

        $isExpanded.sink { [weak self] isExpanded in
            guard let self else { return }

            let count = CGFloat(chipViews.count)
            let fullWidth = RootViewController.instance.view.frame.width
            let contentWidth = (Self.chipSize * (count + 1)) + (12 * (count - 1))

            UIView.animate(withDuration: 0.2) {
                self.countBadge.alpha = isExpanded ? 0 : 1
                self.closeButton.alpha = isExpanded ? 1 : 0
                self.widthC?.constant = isExpanded ? min(fullWidth, contentWidth) : Self.viewHeight
                self.chipStack.spacing = isExpanded ? 12 : -Self.chipSize

                self.chipViews.enumerated().forEach { index, view in
                    view.transform = isExpanded ? .identity : CGAffineTransform(rotationAngle: self.rotation(forPositionFromBottom: index))
                }
            }
        }
        .store(in: &cancellables)
    }

    static func reordered(_ media: [PostingAsset], movingIndex: Int, by offset: Int) -> [PostingAsset] {
        let newIndex = movingIndex + offset
        guard media.indices.contains(movingIndex), media.indices.contains(newIndex) else { return media }
        var result = media
        result.swapAt(movingIndex, newIndex)
        return result
    }
}

private extension PostingPreviewEmbedsView {
    enum StackItem {
        case poll(PollData)
        case embed(PostEmbedPreview, index: Int)
        case media(PostingAsset, index: Int, total: Int)
    }

    func setupCountBadge() {
        countBadge.backgroundColor = .background3
        countBadge.layer.cornerRadius = Self.countBadgeSize / 2
        addSubview(countBadge)
        countBadge
            .constrainToSize(Self.countBadgeSize)
            .pinToSuperview(edges: [.bottom, .trailing], padding: 8)

        countLabel.font = .appFont(withSize: 12, weight: .semibold)
        countLabel.textColor = .foreground
        countBadge.addSubview(countLabel)
        countLabel.centerToSuperview()
    }

    func rebuild(media: [PostingAsset], embeds: [PostEmbedPreview], poll: PollData?) {
        chipStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        chipViews.removeAll()

        var items: [StackItem] = []
        if let poll { items.append(.poll(poll)) }
        for (i, embed) in embeds.enumerated().reversed() {
            items.append(.embed(embed, index: i))
        }
        for (i, asset) in media.enumerated().reversed() {
            items.append(.media(asset, index: i, total: media.count))
        }

        let total = items.count
        for (depth, item) in items.enumerated().reversed() {
            addChip(for: item, positionFromBottom: total - 1 - depth)
        }
        countLabel.text = "\(total)"

        chipStack.addArrangedSubview(SpacerView(width: Self.chipSize))
        
        let fullWidth = RootViewController.instance.view.frame.width
        let contentWidth = (Self.chipSize * CGFloat(total + 1)) + CGFloat(12 * (total - 1))
        widthC?.constant = isExpanded ? min(fullWidth, contentWidth) : Self.viewHeight

        let shouldCollapse = total < 2
        if shouldCollapse && isExpanded {
            isExpanded = false
        }
        
        let shouldHide = items.isEmpty
        if shouldHide && isExpanded {
            isExpanded = false
        }
        guard isHidden != shouldHide else { return }
        UIView.animate(withDuration: 0.2) {
            self.isHidden = shouldHide
            self.superview?.layoutIfNeeded()
        }
    }

    func addChip(for item: StackItem, positionFromBottom: Int) {
        let chip = makeChip(for: item).constrainToSize(Self.chipSize)
        chipStack.addArrangedSubview(chip)
        chipViews.append(chip)

        if !isExpanded {
            chip.transform = CGAffineTransform(rotationAngle: rotation(forPositionFromBottom: positionFromBottom))
        }
    }

    func rotation(forPositionFromBottom position: Int) -> CGFloat {
        guard position > 0 else { return 0 }
        let sign: CGFloat = (position % 2 == 1) ? -1 : 1
        let degrees = sign * CGFloat(position * 2)
        return (5 * degrees) * .pi / 180
    }

    func makeChip(for item: StackItem) -> UIButton {
        switch item {
        case .poll(let poll):
            return makePollChip(poll)
        case .embed(let embed, let index):
            return makeEmbedChip(embed, index: index)
        case .media(let asset, let index, let total):
            return makeMediaChip(asset, index: index, total: total)
        }
    }

    func makeIconLabelChip(icon iconImage: UIImage, label labelText: String, tintColor: UIColor = .foreground) -> UIButton {
        let chip = chipBase()
        let icon = UIImageView(image: iconImage).constrainToSize(16)
        icon.tintColor = tintColor
        let label = UILabel()
        label.text = labelText
        label.font = .appFont(withSize: 12, weight: .semibold)
        label.textColor = tintColor
        let stack = UIStackView(axis: .vertical, spacing: 10, [icon, label])
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        chip.addSubview(stack)
        stack.centerToSuperview(axis: .horizontal).centerToSuperview(axis: .vertical, offset: 2)
        return chip
    }

    func makePollChip(_ poll: PollData) -> UIButton {
        let isValid = poll.isValid
        let labelText: String
        if !isValid {
            labelText = "Invalid poll"
        } else {
            labelText = poll.options.isEmpty ? "Poll" : "\(poll.options.count) options"
        }
        let chip = makeIconLabelChip(icon: .poll16, label: labelText, tintColor: isValid ? .foreground : .white)
        if !isValid {
            chip.backgroundColor = .delete
        }
        chip.addAction(.init(handler: { [weak self] _ in self?.presentPollActionSheet(from: chip) }), for: .touchUpInside)
        return chip
    }

    func makeEmbedChip(_ embed: PostEmbedPreview, index: Int) -> UIButton {
        let chip = makeIconLabelChip(icon: embed.chipIcon, label: embed.chipLabel)
        chip.addAction(.init(handler: { [weak self] _ in self?.presentEmbedActionSheet(index: index, from: chip) }), for: .touchUpInside)
        return chip
    }

    func makeMediaChip(_ asset: PostingAsset, index: Int, total: Int) -> UIButton {
        let chip = chipBase()
        chip.addAction(.init(handler: { [weak self] _ in self?.presentMediaActionSheet(index: index, total: total, from: chip) }), for: .touchUpInside)
        let imageView = FLAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        chip.addSubview(imageView)
        imageView.pinToSuperview()
        if let source = asset.resource?.thumbnailSource {
            switch source {
            case .animated(let anim):
                imageView.animatedImage = anim
            case .thumbnail(let img):
                imageView.image = img
            case .remote(let url):
                imageView.kf.setImage(with: url)
            }
        } else if case .uploaded(let urlString) = asset.state, let url = URL(string: urlString) {
            imageView.kf.setImage(with: url)
        }

        let loadingParent = UIView()
        loadingParent.backgroundColor = .background2.withAlphaComponent(0.5)
        loadingParent.isUserInteractionEnabled = false
        chip.addSubview(loadingParent)
        loadingParent.pinToSuperview()

        let progress = CircularProgressView(frame: .init(origin: .zero, size: .init(width: 24, height: 24)))
        loadingParent.addSubview(progress)
        progress.constrainToSize(24).centerToSuperview()

        switch asset.state {
        case .uploading(let value):
            loadingParent.isHidden = false
            progress.isHidden = false
            if value < 0.01 {
                progress.progress = value
            } else {
                progress.setProgressWithAnimation(duration: 0.1, value: value)
            }
        case .failed:
            loadingParent.isHidden = false
            progress.isHidden = true
        case .uploaded:
            loadingParent.isHidden = true
        }
        return chip
    }

    func chipBase() -> UIButton {
        let chip = UIButton(type: .custom)
        chip.backgroundColor = .background3
        chip.layer.cornerRadius = Self.chipCornerRadius
        chip.clipsToBounds = true
        return chip
    }
}

// MARK: - Action sheet presentation

private extension PostingPreviewEmbedsView {
    func presentMediaActionSheet(index: Int, total: Int, from sourceView: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if index > 0 {
            alert.addAction(UIAlertAction(title: "Move before", style: .default) { [weak self] _ in
                self?.moveAsset(at: index, by: -1)
            })
        }
        if index < total - 1 {
            alert.addAction(UIAlertAction(title: "Move after", style: .default) { [weak self] _ in
                self?.moveAsset(at: index, by: 1)
            })
        }
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.removeAsset(at: index)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, anchoredTo: sourceView)
    }

    func presentPollActionSheet(from sourceView: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            self?.editPoll()
        })
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.removePoll()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, anchoredTo: sourceView)
    }

    func presentEmbedActionSheet(index: Int, from sourceView: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.removeEmbed(at: index)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, anchoredTo: sourceView)
    }

    func present(_ alert: UIAlertController, anchoredTo sourceView: UIView) {
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.bounds
        RootViewController.instance.smartPresent(alert)
    }

    func moveAsset(at index: Int, by offset: Int) {
        guard let manager else { return }
        manager.media = Self.reordered(manager.media, movingIndex: index, by: offset)
    }

    func removeAsset(at index: Int) {
        guard let manager, manager.media.indices.contains(index) else { return }
        manager.media.remove(at: index)
    }

    func removeEmbed(at index: Int) {
        guard let manager, manager.embeddedElements.indices.contains(index) else { return }
        manager.embeddedElements.remove(at: index)
    }

    func editPoll() {
        guard let manager else { return }
        RootViewController.instance.smartPresent(PollInputViewController(manager: manager))
    }

    func removePoll() {
        manager?.pollOptions = nil
    }
}

private extension PostEmbedPreview {
    var chipLabel: String {
        switch self {
        case .highlight: return "Highlight"
        case .post:      return "Note"
        case .article:   return "Article"
        case .invoice:   return "Invoice"
        case .live:      return "Live"
        }
    }

    var chipIcon: UIImage {
        switch self {
        case .highlight: return .highlight16
        case .post:      return .note16
        case .article:   return .article16
        case .invoice:   return .invoice16
        case .live:      return .live16
        }
    }
}
