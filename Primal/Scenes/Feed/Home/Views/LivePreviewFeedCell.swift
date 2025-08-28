//
//  LivePreviewFeedCell.swift
//  Primal
//
//  Created by Pavle Stevanović on 7. 8. 2025..
//

import UIKit
import Lottie

protocol AnimatingViewProtocol {
    func stopAnimating()
    func startAnimating()
}

protocol LivePreviewFeedCellDelegate: AnyObject {
    func didSelectLive(_ live: ProcessedLiveEvent, user: ParsedUser)
}

class LivePreviewFeedCell: UITableViewCell, AnimatingViewProtocol {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).constrainToSize(height: 72)
    let border = SpacerView(height: 1, color: .background3)
    
    var lives: [(ParsedUser, ProcessedLiveEvent)] = [] { didSet { collectionView.reloadData() } }
    
    weak var delegate: LivePreviewFeedCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(collectionView)
        collectionView.pinToSuperview()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LivePreviewFeedCellCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = false
        
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .horizontal
            flow.minimumInteritemSpacing = 8
            flow.sectionInset = .init(top: 8, left: 8, bottom: 0, right: 8)
        }
        
        contentView.addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUsers(_ users: [ParsedUser], delegate: LivePreviewFeedCellDelegate?) {
        self.delegate = delegate
        
        border.backgroundColor = .background3
        
        lives = users.compactMap {
            guard let live = LiveEventManager.instance.liveEvent(for: $0.data.pubkey) else { return nil }
            return ($0, live)
        }
    }
    
    func stopAnimating() {
        collectionView.visibleCells.forEach({ ($0 as? AnimatingViewProtocol)?.stopAnimating() })
    }
    
    func startAnimating() {
        collectionView.visibleCells.forEach({ ($0 as? AnimatingViewProtocol)?.startAnimating() })
    }
}

extension LivePreviewFeedCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        lives.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let (usr, event) = lives[indexPath.item]
        (cell as? LivePreviewFeedCellCell)?.setup(user: usr, live: event)
        return cell
    }   
}

extension LivePreviewFeedCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if lives.count == 1 {
            return .init(width: frame.width - 16, height: 58)
        }
        
        return .init(width: frame.width * 0.8, height: 58)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let (usr, event) = lives[indexPath.item]
        delegate?.didSelectLive(event, user: usr)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? LivePreviewFeedCellCell)?.stopAnimating()
    }
}

class LivePreviewFeedCellCell: UICollectionViewCell, AnimatingViewProtocol {
    let userImage = UserImageView(height: 40, showLegendGlow: false)
    let watchersIcon = UIImageView(image: .livePillUser)
    let watcherCountLabel = UILabel("", color: .white, font: .appFont(withSize: 16, weight: .bold))
    let textLabel = HorizontallyScrollingLabel()
    let liveIcon = LottieAnimationView(animation: AnimationType.liveIcon.animation).constrainToSize(20)
    
    let background = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(background)
        background.pinToSuperview(edges: .vertical, padding: 5).pinToSuperview(edges: .horizontal)
        
        let userBackground = UIView()
        userBackground.addSubview(userImage)
        userImage.pinToSuperview(padding: 2)
        userBackground.backgroundColor = .white
        userBackground.layer.cornerRadius = 22
        
        let mainStack = UIStackView([userBackground, watchersIcon, watcherCountLabel, textLabel, liveIcon])
        mainStack.setCustomSpacing(4, after: watchersIcon)
        mainStack.spacing = 10
        mainStack.alignment = .center
        contentView.addSubview(mainStack)
        mainStack.pinToSuperview(edges: [.leading], padding: 2).pinToSuperview(edges: .trailing, padding: 12).pinToSuperview(edges: .vertical, padding: 7)
        
        userImage.showLivePill = false
        
        [watchersIcon, watcherCountLabel, liveIcon].forEach { $0.setContentHuggingPriority(.required, for: .horizontal) }
        
        liveIcon.loopMode = .loop
        
        background.layer.cornerRadius = 24
        contentView.clipsToBounds = false
        clipsToBounds = false
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setup(user: ParsedUser, live: ProcessedLiveEvent) {
        userImage.setUserImage(user)
        textLabel.setText(.init(string: live.title, attributes: [
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.white
        ]))
        
        watcherCountLabel.text = live.participants.localized()
        
        textLabel.backgroundColor = .accent
        background.backgroundColor = .accent
        
        background.startPulsingXY()
        liveIcon.play()
    }
    
    deinit {
        stopAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stopAnimating()
    }
    
    func stopAnimating() {
        background.stopPulsing()
        textLabel.stopAnimating()
        liveIcon.stop()
    }
    
    func startAnimating() {
        background.startPulsingXY()
        textLabel.startAnimating()
        liveIcon.play()
    }
}

private extension UIView {
    func startPulsingXY(scaleX: CGFloat = 1.01, scaleY: CGFloat = 1.05) {
        let pulseAnimation = CAKeyframeAnimation(keyPath: "transform")
        
        // Build keyframe transforms
        let identity = CATransform3DIdentity
        let scaledUp = CATransform3DMakeScale(scaleX, scaleY, 1)
        
        pulseAnimation.values = [
            identity,    // start
            scaledUp,    // scale up
            identity,    // back to normal
            identity     // pause at normal
        ]
        
        pulseAnimation.keyTimes = [0, 0.25, 0.5, 1]  // 0.5s up, 0.5s down, 1s pause
        pulseAnimation.duration = 2
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.isRemovedOnCompletion = false
        pulseAnimation.calculationMode = .linear
        
        layer.add(pulseAnimation, forKey: "pulseXY")
    }

}

class HorizontallyScrollingLabel: UIView, AnimatingViewProtocol {
    let label = UILabel()
    let hideIcon = UIImageView(image: .liveTextGradientCover)
    
    private var titleDisplayLink: CADisplayLink? {
        didSet {
            oldValue?.remove(from: .main, forMode: .default)
            titleDisplayLink?.add(to: .main, forMode: .default)
        }
    }

    override var backgroundColor: UIColor? {
        didSet {
            hideIcon.tintColor = backgroundColor
        }
    }
    
    var maxDelta: CGFloat = 0
    var currentDelta: CGFloat = 0 {
        didSet {
            label.transform = .init(translationX: -min(maxDelta, currentDelta), y: 0)
        }
    }
    var animationDuration: CGFloat { maxDelta / 50 }
    private var elapsed: CGFloat = 0
    var direction: CGFloat = -1
    var isPaused = false
    
    init() {
        super.init(frame: .zero)
        addSubview(label)
        label.pinToSuperview(edges: [.leading, .vertical])
        
        addSubview(hideIcon)
        hideIcon.pinToSuperview(edges: [.trailing, .vertical])
        
        clipsToBounds = true
    }
    
    func setText(_ text: NSAttributedString) {
        label.attributedText = text
        label.transform = .identity
        titleDisplayLink = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [weak self] in
            guard let self, label.frame.width > frame.width else { return }
            
            maxDelta = max(0, label.frame.width - frame.width + 20)
            
            startUpdatingLabel()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        titleDisplayLink?.remove(from: .main, forMode: .default)
    }
    
    func stopAnimating() {
        currentDelta = 0
        isPaused = false
        elapsed = 0
        label.transform = .identity
        titleDisplayLink = nil
    }
    
    func startAnimating() {
        startUpdatingLabel()
    }
    
    func startUpdatingLabel() {
        guard maxDelta > 0 else {
            stopAnimating()
            return
        }
        
        titleDisplayLink = .init(target: self, selector: #selector(updateLabelAnimation))
    }

    @objc private func updateLabelAnimation(link: CADisplayLink) {
        let dt = CGFloat(link.duration)
        elapsed += dt
        
        if isPaused {
            if elapsed < 2 {
                return
            }
            isPaused = false
            elapsed = 0
        }
        
        var progress = elapsed / animationDuration
        if progress >= 1 {
            // Switch direction
            direction *= -1
            elapsed = 0
            progress = 0
            
            isPaused = true // Pause after reaching start/end position
        }
        
        if direction < 0 {
            let delta = maxDelta * -progress
            
            let titleOffset = delta.clamp(-maxDelta, 0)
            label.transform = CGAffineTransform(translationX: titleOffset, y: 0)
        } else {
            let moveDelta = maxDelta * progress
            
            let titleDelta = -maxDelta + moveDelta
            
            let titleOffset = titleDelta.clamp(-maxDelta, 0)
            label.transform = CGAffineTransform(translationX: titleOffset, y: 0)
        }
    }

}
