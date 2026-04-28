//
//  PrimalNavigationBar.swift
//  Primal
//
//  Created by Pavle Stevanović on 3.4.26..
//

import Combine
import UIKit

enum ChromeSize {
    case small, regular, medium, large

    static let current: ChromeSize = {
        let screenWidth = RootViewController.instance.view.frame.size.width

        if screenWidth < 380 { return .small }
        if screenWidth < 405 { return .regular }
        if screenWidth < 430 { return .medium }
        return .large
    }()
}

protocol PrimalNavigationBarController: UIViewController {
    var primalNavigationBar: PrimalNavigationBar { get }
    
}

private let navBarCoverViewTag = 94201

extension PrimalNavigationBarController {
    func addNavigationBar() {
        view.addSubview(primalNavigationBar)
        primalNavigationBar.pinToSuperview(edges: .horizontal).pinToSuperview(edges: .top, safeArea: true)

        addNavBarCoverIfNeeded()
    }

    var navBarCoverView: UIView? { view.viewWithTag(navBarCoverViewTag) }

    @discardableResult
    func addNavBarCoverIfNeeded() -> UIView {
        if let existing = navBarCoverView { return existing }

        let cover = ThemeableView().setTheme { $0.backgroundColor = .background }
        cover.tag = navBarCoverViewTag
        view.addSubview(cover)
        cover.pinToSuperview(edges: [.top, .horizontal])
        cover.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        return cover
    }

    func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        if hidden == primalNavigationBar.isHidden { return }
        
        addNavBarCoverIfNeeded()
        
        guard animated else {
            primalNavigationBar.isHidden = hidden
            return
        }

        if !hidden {
            primalNavigationBar.isHidden = false
            primalNavigationBar.transform = PrimalNavigationBar.transformForMaxExcited
        }
        
        UIView.animate(withDuration: 0.3, animations: { [self] in
            primalNavigationBar.transform = hidden ? PrimalNavigationBar.transformForMaxExcited : .identity
        }) { _ in
            self.primalNavigationBar.isHidden = hidden
        }
    }
    
    func setNavigationBarExcited(excited: CGFloat, animated: Bool) {
        guard !primalNavigationBar.isHidden, primalNavigationBar.transform.ty != PrimalNavigationBar.maxTranslation else { return }
        
        guard animated else {
            primalNavigationBar.transform = PrimalNavigationBar.transformForExcited(excited)
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.primalNavigationBar.transform = PrimalNavigationBar.transformForExcited(excited)
        }
    }
}

final class PrimalNavigationBar: UIView, Themeable {
    static let height: CGFloat = {
        switch ChromeSize.current {
        case .small: return 64
        case .regular: return 70
        case .medium: return 76
        case .large: return 83
        }
    }()

    private static let titleFontSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 24
        case .regular: return 26
        case .medium: return 28
        case .large: return 30
        }
    }()

    private static let subtitleFontSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 14
        case .regular: return 15
        case .medium: return 15
        case .large: return 17
        }
    }()

    private static let avatarSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 37
        case .regular: return 41
        case .medium: return 43
        case .large: return 45
        }
    }()

    private static let chevronSize: CGFloat = {
        switch ChromeSize.current {
        case .small: return 10
        case .regular: return 10
        case .medium: return 10
        case .large: return 12
        }
    }()

    let titleLabel = UILabel()
    let chevronView = UIImageView(image: UIImage(named: "navChevron"))
    let subtitleLabel = UILabel()
    let userImageView = UserImageView(height: PrimalNavigationBar.avatarSize)
    let border = SpacerView(height: 1, color: .background3)

    private let titleButton = UIButton()
    private let avatarButton = UIButton()

    fileprivate lazy var leftStack: UIStackView = {
        let titleRow = UIStackView(spacing: 8, [titleLabel, chevronView])
        titleRow.alignment = .center
        let stack = UIStackView(axis: .vertical, spacing: 2, [titleRow, subtitleLabel])
        stack.alignment = .leading
        return stack
    }()

    fileprivate weak var transitionView: UIView?
    fileprivate var transitionConstraint: NSLayoutConstraint?

    private var cancellables: Set<AnyCancellable> = []

    var title: String = "" {
        didSet { titleLabel.text = title }
    }

    var subtitle: String = "" {
        didSet { subtitleLabel.text = subtitle }
    }

    var showChevron: Bool = true {
        didSet { chevronView.isHidden = !showChevron }
    }

    var onTitleTapped: (() -> Void)?
    var onAvatarTapped: (() -> Void)?

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTheme() {
        backgroundColor = .background
        border.backgroundColor = .background3
        titleLabel.textColor = .foreground
        subtitleLabel.textColor = .foreground5
        chevronView.image = UIImage(named: "navChevron")?.withTintColor(.foreground).withRenderingMode(.alwaysOriginal)
    }
}

private extension PrimalNavigationBar {
    func setup() {
        constrainToSize(height: Self.height)

        addSubview(border)
        border.pinToSuperview(edges: [.horizontal, .bottom])

        titleLabel.font = .appFont(withSize: Self.titleFontSize, weight: .bold)
        subtitleLabel.font = .appFont(withSize: Self.subtitleFontSize, weight: .semibold)

        chevronView.constrainToSize(Self.chevronSize)
        chevronView.contentMode = .scaleAspectFit
        chevronView.setContentHuggingPriority(.required, for: .horizontal)
        chevronView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let mainStack = UIStackView(spacing: 6, [leftStack, UIView(), userImageView])
        mainStack.alignment = .center

        addSubview(mainStack)
        mainStack
            .pinToSuperview(edges: .leading, padding: 18)
            .pinToSuperview(edges: .trailing, padding: 16)
            .centerToSuperview(axis: .vertical)

        addSubview(titleButton)
        titleButton.pin(to: leftStack)
        titleButton.addAction(.init(handler: { [weak self] _ in
            self?.onTitleTapped?()
        }), for: .touchUpInside)

        addSubview(avatarButton)
        avatarButton.pin(to: userImageView)
        avatarButton.addAction(.init(handler: { [weak self] _ in
            self?.onAvatarTapped?()
        }), for: .touchUpInside)

        IdentityManager.instance.$parsedUser
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.userImageView.setUserImage(user)
            }
            .store(in: &cancellables)

        updateTheme()
    }
}

extension PrimalNavigationBar {
    func startTransition(left: Bool, newTitle: String, newSubtitle: String) {
        transitionView?.removeFromSuperview()

        let overlay = UIView()
        overlay.backgroundColor = .background
        overlay.clipsToBounds = true
        addSubview(overlay)
        
        overlay
            .pinToSuperview(edges: .vertical)
            .pin(to: leftStack, edges: left ? .leading : .trailing)
        
        let mirrorBar = PrimalNavigationBar()
        mirrorBar.title = newTitle
        mirrorBar.subtitle = newSubtitle
        mirrorBar.showChevron = showChevron
        
        let mirrorView = mirrorBar.leftStack

        overlay.addSubview(mirrorView)
        mirrorView.pin(to: leftStack, edges: .leading).centerToView(leftStack, axis: .vertical)
        
        let overlayBar = SpacerView(width: 10, color: .background)
        overlay.addSubview(overlayBar)
        overlayBar.pinToSuperview(edges: .vertical).pinToSuperview(edges: left ? .trailing : .leading)
        
        let widthC = overlay.widthAnchor.constraint(equalToConstant: 0)
        widthC.priority = .defaultHigh
        
        let edgeC: NSLayoutConstraint
        if left {
            edgeC = overlay.leadingAnchor.constraint(equalTo: leftStack.leadingAnchor)
        } else {
            edgeC = overlay.trailingAnchor.constraint(equalTo: leftStack.trailingAnchor)
            edgeC.priority = .init(1)
            
            let otherEdgeC = overlay.trailingAnchor.constraint(greaterThanOrEqualTo: mirrorView.trailingAnchor)
            otherEdgeC.priority = .init(999)
            otherEdgeC.isActive = true
        }
        
        NSLayoutConstraint.activate([
            edgeC, widthC,
            overlay.trailingAnchor.constraint(lessThanOrEqualTo: userImageView.leadingAnchor)
        ])
        
        transitionView = overlay
        transitionConstraint = widthC

        bringSubviewToFront(avatarButton)
        bringSubviewToFront(titleButton)
    }

    func updateTransition(percent: CGFloat) {
        transitionConstraint?.constant = bounds.width * percent.clamped(to: 0...1)
    }

    func cancelTransition() {
        transitionConstraint?.constant = 0
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }

    func completeTransitionAnimated(newTitle: String, newSubtitle: String) {
        transitionConstraint?.constant = bounds.width
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.transitionView?.removeFromSuperview()
            self.title = newTitle
            self.subtitle = newSubtitle
        }
    }

    func completeTransition(newTitle: String, newSubtitle: String) {
        transitionView?.removeFromSuperview()
        title = newTitle
        subtitle = newSubtitle
    }
}

protocol TitleSwipeController: PrimalNavigationBarController {
    var pageVC: UIPageViewController { get }

    func titleSubtitleToLeftOfCurrent()  -> (title: String, subtitle: String)?
    func titleSubtitleToRightOfCurrent() -> (title: String, subtitle: String)?
}

final class TitleSwipeGesture: UIPanGestureRecognizer {
    weak var vc: TitleSwipeController?

    private var oldTransition: (left: Bool, String)?

    init(vc: TitleSwipeController) {
        self.vc = vc
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(execute))
        delegate = self
    }

    @objc private func execute() {
        guard let pageVC = vc?.pageVC, let navBar = vc?.primalNavigationBar else { return }

        if let scroll: UIScrollView = pageVC.view.findAllSubviews().first, scroll.contentOffset.x == scroll.frame.width {
            return
        }

        let x = translation(in: view).x
        let left = x > 0

        guard let pair = left ? vc?.titleSubtitleToLeftOfCurrent() : vc?.titleSubtitleToRightOfCurrent() else { return }

        if let oldTransition, oldTransition.left == left && oldTransition.1 == pair.title {
            // continue existing transition
        } else {
            self.oldTransition = (left, pair.title)
            navBar.startTransition(left: left, newTitle: pair.title, newSubtitle: pair.subtitle)
        }

        switch state {
        case .possible, .began, .changed:
            navBar.updateTransition(percent: abs(x) / pageVC.view.frame.width)
        case .ended, .cancelled, .failed:
            let velocity = velocity(in: view).x
            let halfWidth = pageVC.view.frame.width / 2

            if (velocity > 300 && x > 0) || (velocity < -300 && x < 0) || (velocity < 200 && x < -halfWidth) || (velocity > -200 && x > halfWidth) {
                navBar.completeTransitionAnimated(newTitle: pair.title, newSubtitle: pair.subtitle)
            } else {
                navBar.cancelTransition()
            }
            oldTransition = nil
        @unknown default:
            break
        }
    }
}

extension TitleSwipeGesture: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer, abs(pan.translation(in: view).y) >= 0.01 {
            return false
        }
        return true
    }
}
