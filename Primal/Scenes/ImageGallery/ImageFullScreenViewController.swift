//
//  ImageFullScreenViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8.12.23..
//

import UIKit
import FLAnimatedImage
import Kingfisher
import Combine

protocol ImageMenuHandler: AnyObject {
    var viewController: UIViewController { get }
    var url: String { get }
    var image: UIImage? { get }
}

extension ImageMenuHandler {
    var imageMenuActions: [UIAction] {
        if url.isVideoURL {
            return [
                UIAction(title: "Copy Video URL", image: UIImage(named: "MenuCopyLink")) { [weak self] _ in
                    guard let self else { return }
                    UIPasteboard.general.string = url
                    viewController.view?.showToast("Copied!", extraPadding: 0)
                }
            ]
        }
        
        return [
            UIAction(title: "Save Image", image: UIImage(named: "MenuImageSave"), handler: { [weak self] _ in
                guard let self, let image = image else { return }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                viewController.view?.showToast("Saved!", extraPadding: 0)
            }),
            UIAction(title: "Share Image", image: UIImage(named: "MenuImageShare"), handler: { [weak self] _ in
                guard let self, let image = image else { return }
                let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                viewController.present(activityViewController, animated: true, completion: nil)
            }),
            UIAction(title: "Copy Image", image: UIImage(named: "MenuImageCopy"), handler: { [weak self] _ in
                guard let self, let image = image else { return }
                UIPasteboard.general.image = image
                viewController.view?.showToast("Copied!", extraPadding: 0)
            }),
            UIAction(title: "Copy Image URL", image: UIImage(named: "MenuCopyLink")) { [weak self] _ in
                guard let self else { return }
                UIPasteboard.general.string = url
                viewController.view?.showToast("Copied!", extraPadding: 0)
            }
        ]
    }
}

final class ImageFullScreenViewController: UIViewController {
    let background = UIView()
    let imageView = FLAnimatedImageView()
    let scroll = UIScrollView()
        
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    var imageConstraint: NSLayoutConstraint?
    
    var cancellables: Set<AnyCancellable> = []
    
    let closeButton = UIButton()
    let threeDotsButton = UIButton()
    
    var gallery: ImageGalleryController? { findParent() }
    
    let url: String
    
    var showChrome: Bool = true {
        didSet {
            guard showChrome != oldValue else { return }
            updateChrome()
        }
    }
    
    init(url: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    func prepareForAnimation() {
        background.alpha = 0
        scroll.alpha = 0
    }
    
    func animateTransitionFrom(_ startImageView: UIImageView) {
        let animatingIV = UIImageView(image: startImageView.image)
        view.addSubview(animatingIV)
        
        animatingIV.contentMode = startImageView.contentMode
        animatingIV.layer.cornerRadius = startImageView.layer.cornerRadius
        animatingIV.layer.masksToBounds = startImageView.layer.masksToBounds
        
        startImageView.alpha = 0.01
        
        if imageView.image == nil, let image = startImageView.image {
            imageView.image = image
            
            let s = image.size
            imageConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: s.width / s.height)
            imageConstraint?.isActive = true
            
            setInsetForZoomedIn(viewSize: view.frame.size)
        }
        
        var cs: [NSLayoutConstraint] = []
        if startImageView.window == view.window {
            let startingFrame = startImageView.convert(startImageView.bounds, to: nil)
            animatingIV.translatesAutoresizingMaskIntoConstraints = false
            cs = [
                animatingIV.topAnchor.constraint(equalTo: view.topAnchor, constant: startingFrame.minY),
                animatingIV.leftAnchor.constraint(equalTo: view.leftAnchor, constant: startingFrame.minX),
                animatingIV.widthAnchor.constraint(equalToConstant: startingFrame.width),
                animatingIV.heightAnchor.constraint(equalToConstant: startingFrame.height)
            ]
            NSLayoutConstraint.activate(cs)
            view.layoutIfNeeded()
        }
        
        NSLayoutConstraint.deactivate(cs)
        animatingIV.pin(to: self.imageView)
        
        UIView.animate(withDuration: 0.3) {
            self.background.alpha = 1
            self.view.layoutIfNeeded()
            animatingIV.layer.cornerRadius = 0
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                animatingIV.alpha = 0
            } completion: { _ in
                animatingIV.removeFromSuperview()
            }
            self.scroll.alpha = 1
            startImageView.alpha = 1
        }
    }
    
    // MARK: - View cycle
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { _ in
            self.setInsetForZoomedIn(viewSize: size)
        }
    }
    
    var oldSize = CGSize.zero
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if view.frame.size != oldSize {
            oldSize = view.frame.size
            setInsetForZoomedIn(viewSize: oldSize)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scroll.zoomScale = 1
        setInsetForZoomedIn(viewSize: view.frame.size)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ImageFullScreenViewController {
    func setup() {
        view.addSubview(background)
        background.pinToSuperview()
        background.isUserInteractionEnabled = false
        background.backgroundColor = .black
        
        view.addSubview(scroll)
        scroll.pinToSuperview()
        
        scroll.addSubview(imageView)
        imageView.pinToSuperview()
        widthConstraint = imageView.widthAnchor.constraint(equalTo: view.widthAnchor)
        heightConstraint = imageView.heightAnchor.constraint(equalTo: view.heightAnchor)
        
        view.addSubview(closeButton)
        closeButton.pinToSuperview(edges: .leading, padding: 14).pinToSuperview(edges: .top, padding: 50).constrainToSize(32)
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        
        view.addSubview(threeDotsButton)
        threeDotsButton.pinToSuperview(edges: .trailing, padding: 14).centerToView(closeButton, axis: .vertical).constrainToSize(32)
        threeDotsButton.setImage(UIImage(named: "threeDots"), for: .normal)
        
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: url)) { [weak self] res in
            guard let self, case .success(let result) = res else { return }
            
            imageConstraint?.isActive = false
            let s = result.image.size
            imageConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: s.width / s.height)
            imageConstraint?.isActive = true
            
            if view.window != nil {
                setInsetForZoomedIn(viewSize: view.frame.size)
            } else {
                setInsetForZoomedIn(viewSize: UIScreen.main.bounds.size)
            }
        }

        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = 4
        scroll.delegate = self
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        
        let tap = BindableTapGestureRecognizer(action: { [weak self] in self?.showChrome = !(self?.showChrome ?? false) })
        tap.require(toFail: doubleTap)
        view.addGestureRecognizer(tap)
        
        closeButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        threeDotsButton.tintColor = .white
        threeDotsButton.showsMenuAsPrimaryAction = true
        threeDotsButton.menu = .init(children: imageMenuActions)
        
        imageView.addInteraction(UIContextMenuInteraction(delegate: self))
        imageView.isUserInteractionEnabled = true
    }
    
    func setInsetForZoomedIn(viewSize: CGSize) {
        guard let s = imageView.image?.size else { return }
        
        let zoom = scroll.zoomScale
                
        let aspectWidth = (viewSize.width / s.width) * zoom
        let aspectHeight = (viewSize.height / s.height) * zoom
        
        if aspectHeight > aspectWidth {
            let imageHeight = s.height * aspectWidth
            let topInset = max(0, (viewSize.height - imageHeight) / 2)
            
            heightConstraint?.isActive = false
            widthConstraint?.isActive = true
            scroll.contentInset = .init(top: topInset, left: 0, bottom: 0, right: 0)
        } else {
            let imageWidth = s.width * aspectHeight
            let leftInset = max(0, (viewSize.width - imageWidth) / 2)
            
            heightConstraint?.isActive = true
            widthConstraint?.isActive = false
            scroll.contentInset = .init(top: 0, left: leftInset, bottom: 0, right: 0)
        }
    }
    
    func updateChrome() {
        UIView.animate(withDuration: 0.2) {
            self.gallery?.progress.alpha = self.showChrome ? 1 : 0
            self.closeButton.alpha = self.showChrome ? 1 : 0
            self.threeDotsButton.alpha = self.showChrome ? 1 : 0
        }
    }
    
    // MARK: - @objc
    
    @objc func didDoubleTap(_ sender: UITapGestureRecognizer) {
        var location = sender.location(in: imageView)
        let size = imageView.frame.size
        
        if scroll.zoomScale > 1.1 {
            UIView.animate(withDuration: 0.3) {
                self.scroll.zoomScale = 1
            }
            return
        }
        
        location.x = location.x.clamp(0, size.width)
        location.y = location.y.clamp(0, size.height)
        
        let maxSize = scroll.frame.size
        
        let offsetX = (maxSize.width / 2) - location.x
        let offsetY = (maxSize.height / 2) - location.y
        
        print("\(offsetX)  \(offsetY)")
        
        UIView.animate(withDuration: 0.3) {
            self.scroll.contentOffset = .init(x: -offsetX, y: -offsetY)
            self.scroll.zoomScale = 3
        }
    }
    
    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        let trans = sender.translation(in: view)
        
        switch sender.state {
        case .began:
            gallery?.view.backgroundColor = .clear
            showChrome = false
            fallthrough
        case .changed:
            let rotationProgress = (trans.x / 400).clamp(-1, 1)
            let rotation = (.pi * 0.2) * rotationProgress
            
            scroll.transform = CGAffineTransform(translationX: trans.x, y: trans.y).rotated(by: rotation)
            
            let totalTrans = sqrt(trans.x * trans.x + trans.y * trans.y)
            let progress = (totalTrans / 500).clamp(0, 1)
            background.alpha = 1 - progress
        case .ended, .cancelled:
            let velocity = sender.velocity(in: view)
            let extendedTrans = CGPoint(x: trans.x + velocity.x / 20, y: trans.y + velocity.y / 20)
                        
            let totalTrans = sqrt(extendedTrans.x * extendedTrans.x + extendedTrans.y * extendedTrans.y)
            if totalTrans > 200 {
                UIView.animate(withDuration: 0.4) { [self] in
                    scroll.transform = scroll.transform.translatedBy(x: velocity.x / 5, y: velocity.y / 5)
                    background.alpha = 0
                    imageView.alpha = 0
                } completion: { _ in
                    self.dismiss(animated: false)
                }
            } else {
                showChrome = true
                UIView.animate(withDuration: 0.3) {
                    self.scroll.transform = .identity
                    self.background.alpha = 1
                }
            }
        default:
            break
        }
    }
}

extension ImageFullScreenViewController: ImageMenuHandler, UIContextMenuInteractionDelegate {
    var viewController: UIViewController { self }
    
    var image: UIImage? { imageView.image }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        .init(actionProvider:  { [weak self] suggested in
            .init(children: self?.imageMenuActions ?? [] + suggested)
        })
    }
}

extension ImageFullScreenViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        setInsetForZoomedIn(viewSize: view.frame.size)
        parent?.parent?.view.backgroundColor = .black
    }
}

// MARK: - UIGestureRecognizerDelegate for panning exit gesture
extension ImageFullScreenViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        
        if let gallery, gallery.urls.count < 2 {
            return true
        }
        
        let velocity = pan.velocity(in: view)
        return abs(velocity.y) > abs(velocity.x)
    }
}
