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

    private static let chipSize: CGFloat = 80
    static let viewHeight: CGFloat = 104
    private static let nativePreviewWidth: CGFloat = 375
    private static let chipCornerRadius: CGFloat = 10
    private static let countBadgeSize: CGFloat = 28

    private let countBadge = UIView()
    private let countLabel = UILabel()
    private let closeButton = UIButton(configuration: .previewEmbedsClose)
    private var chipViews: [UIView] = []
    private var cancellables: Set<AnyCancellable> = []
    
    private var widthC: NSLayoutConstraint?
    
    @Published var isExpanded: Bool = false
    
    var isShowingPublisher: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher()
    
    init() {
        super.init(frame: .zero)
        clipsToBounds = false
        isHidden = true
        constrainToSize(height: Self.viewHeight)
        setupCountBadge()
        
        widthC = widthAnchor.constraint(equalToConstant: Self.viewHeight)
        widthC?.isActive = true
        
        addSubview(closeButton)
        closeButton.constrainToSize(Self.chipSize  / 2).pinToSuperview(edges: .trailing, padding: Self.chipSize  / 4).centerToSuperview(axis: .vertical)
        
        closeButton.addAction(.init(handler: { [weak self] _ in
            self?.isExpanded = false
        }), for: .touchUpInside)
        
        addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.isExpanded.toggle()
        }))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(to manager: PostingTextViewManager) {
        cancellables = []
        
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
            
            let fullWidth = RootViewController.instance.view.frame.width
            
            UIView.animate(withDuration: 0.2) {
                self.countBadge.alpha = isExpanded ? 0 : 1
                self.closeButton.alpha = isExpanded ? 1 : 0
                self.widthC?.constant = isExpanded ? fullWidth : Self.viewHeight
                
                if isExpanded {
                    let startTranslation = Self.chipSize - fullWidth
                    self.chipViews.enumerated().forEach { index, view in
                        view.transform = .init(translationX: startTranslation + CGFloat(index) * (Self.chipSize + 8), y: 0)
                    }
                } else {
                    self.chipViews.enumerated().forEach { index, view in
                        view.transform = CGAffineTransform(rotationAngle: self.rotation(forPositionFromBottom: index))
                    }
                }
            }
        }
        .store(in: &cancellables)
    }
}

private extension PostingPreviewEmbedsView {
    enum StackItem {
        case poll(PollData)
        case embed(PostEmbedPreview)
        case media(PostingAsset)
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
        chipViews.forEach { $0.removeFromSuperview() }
        chipViews.removeAll()

        var items: [StackItem] = []
        if let poll { items.append(.poll(poll)) }
        items.append(contentsOf: embeds.reversed().map { .embed($0) })
        items.append(contentsOf: media.reversed().map { .media($0) })

        let total = items.count
        for (depth, item) in items.enumerated().reversed() {
            addChip(for: item, positionFromBottom: total - 1 - depth)
        }
        countLabel.text = "\(total)"
        bringSubviewToFront(countBadge)

        let shouldHide = items.isEmpty
        guard isHidden != shouldHide else { return }
        UIView.animate(withDuration: 0.2) {
            self.isHidden = shouldHide
            self.superview?.layoutIfNeeded()
        }
    }

    func addChip(for item: StackItem, positionFromBottom: Int) {
        let chip = makeChip(for: item)
        addSubview(chip)
        chipViews.append(chip)
        chip
            .constrainToSize(Self.chipSize)
            .pinToSuperview(edges: .trailing)
            .centerToSuperview(axis: .vertical)
        
        chip.transform = CGAffineTransform(rotationAngle: rotation(forPositionFromBottom: positionFromBottom))
    }

    func rotation(forPositionFromBottom position: Int) -> CGFloat {
        guard position > 0 else { return 0 }
        let sign: CGFloat = (position % 2 == 1) ? -1 : 1
        let degrees = sign * CGFloat(position * 2)
        return (5 * degrees) * .pi / 180
    }

    func makeChip(for item: StackItem) -> UIView {
        switch item {
        case .poll(let poll):       return makePollChip(poll)
        case .embed(let embed):     return makeEmbedChip(embed)
        case .media(let asset):     return makeMediaChip(asset)
        }
    }

    func makePollChip(_ poll: PollData) -> UIView {
        let chip = chipBase()
        let icon = UIImageView(image: UIImage(named: "pollIcon")?.withRenderingMode(.alwaysTemplate))
        icon.tintColor = .foreground
        icon.contentMode = .scaleAspectFit
        icon.constrainToSize(28)
        let label = UILabel()
        label.text = poll.options.isEmpty ? "Poll" : "\(poll.options.count) options"
        label.font = .appFont(withSize: 12, weight: .semibold)
        label.textColor = .foreground
        let stack = UIStackView(axis: .vertical, spacing: 4, [icon, label])
        stack.alignment = .center
        chip.addSubview(stack)
        stack.centerToSuperview()
        return chip
    }

    func makeEmbedChip(_ embed: PostEmbedPreview) -> UIView {
        let chip = chipBase()
        let inner = embed.makeView()
        inner.isUserInteractionEnabled = false
        inner.layer.borderWidth = 0
        inner.backgroundColor = .background3
        inner.translatesAutoresizingMaskIntoConstraints = false
        chip.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.widthAnchor.constraint(equalToConstant: Self.nativePreviewWidth),
            inner.heightAnchor.constraint(equalToConstant: Self.nativePreviewWidth),
            inner.centerXAnchor.constraint(equalTo: chip.centerXAnchor),
            inner.centerYAnchor.constraint(equalTo: chip.centerYAnchor),
        ])
        let scale = Self.chipSize / Self.nativePreviewWidth
        inner.transform = CGAffineTransform(scaleX: scale, y: scale)
        return chip
    }

    func makeMediaChip(_ asset: PostingAsset) -> UIView {
        let chip = chipBase()
        let imageView = FLAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
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
        return chip
    }

    func chipBase() -> UIView {
        let chip = UIView()
        chip.backgroundColor = .background3
        chip.layer.cornerRadius = Self.chipCornerRadius
        chip.clipsToBounds = true
        return chip
    }
}
