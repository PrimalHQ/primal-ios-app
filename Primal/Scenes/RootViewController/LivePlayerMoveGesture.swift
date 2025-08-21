//
//  LivePlayerMoveGesture.swift
//  Primal
//
//  Created by Pavle Stevanović on 19. 8. 2025..
//

import Combine
import UIKit

public final class LivePlayerMoveGesture: UIPanGestureRecognizer {
    
    private var oldTranslation = CGPoint.zero
    
    static let margin: CGFloat = 16
    static let smallVideoWidth: CGFloat = 199
    static let bottomBarMargin: CGFloat = 116
    static let hideAdjustment: CGFloat = smallVideoWidth + margin - 24
    
    var liveView: LiveVideoEmbeddedView? { view as? LiveVideoEmbeddedView }
    
    static var botLeftPosition: CGPoint {
        let view = RootViewController.instance.view!

        return CGPoint(x: margin + smallVideoWidth / 2, y: view.frame.height - view.safeAreaInsets.bottom - bottomBarMargin)
    }
    
    static private let extraSpacing: CGFloat = 1000
    
    static var edgePositions: [CGPoint] {
        let view = RootViewController.instance.view!

        let botRight = CGPoint(x: view.frame.width - (margin + smallVideoWidth / 2), y: view.frame.height - view.safeAreaInsets.bottom - bottomBarMargin)
        let topLeft = CGPoint(x: margin + smallVideoWidth / 2, y: view.safeAreaInsets.top + bottomBarMargin)
        let topRight = CGPoint(x: view.frame.width - (margin + smallVideoWidth / 2), y: view.safeAreaInsets.top + bottomBarMargin)
        
        let hiddenBotLeft = botLeftPosition.translated(by: .init(x: -hideAdjustment, y: 0))
        let hiddenBotRight = botRight.translated(by: .init(x: hideAdjustment, y: 0))
        let hiddenTopLeft = topLeft.translated(by: .init(x: -hideAdjustment, y: 0))
        let hiddenTopRight = topRight.translated(by: .init(x: hideAdjustment, y: 0))
        
        return [botLeftPosition, botRight, topLeft, topRight, hiddenBotLeft, hiddenBotRight, hiddenTopLeft, hiddenTopRight]
    }
    
    static var adjustedEdgePositions: [CGPoint] {
        let view = RootViewController.instance.view!

        let botRight = CGPoint(x: view.frame.width - (margin + smallVideoWidth / 2), y: view.frame.height - view.safeAreaInsets.bottom - bottomBarMargin)
        let topLeft = CGPoint(x: margin + smallVideoWidth / 2, y: view.safeAreaInsets.top + bottomBarMargin)
        let topRight = CGPoint(x: view.frame.width - (margin + smallVideoWidth / 2), y: view.safeAreaInsets.top + bottomBarMargin)
        
        let hiddenBotLeft = botLeftPosition.translated(by: .init(x: -hideAdjustment - extraSpacing, y: 0))
        let hiddenBotRight = botRight.translated(by: .init(x: hideAdjustment + extraSpacing, y: 0))
        let hiddenTopLeft = topLeft.translated(by: .init(x: -hideAdjustment - extraSpacing, y: 0))
        let hiddenTopRight = topRight.translated(by: .init(x: hideAdjustment + extraSpacing, y: 0))
        
        return [botLeftPosition, botRight, topLeft, topRight, hiddenBotLeft, hiddenBotRight, hiddenTopLeft, hiddenTopRight]
    }
    
    init() {
        super.init(target: nil, action: nil)
        
        addTarget(self, action: #selector(gesture))
    }
    
    @objc func gesture() {
        guard let view, let rootView = RootViewController.instance.view else { return }
        let translation = translation(in: nil)
        
        switch state {
        case .began:
            oldTranslation = .zero
        case .changed:
            view.frame.origin = .init(x: view.frame.origin.x + translation.x - oldTranslation.x, y: view.frame.origin.y + translation.y - oldTranslation.y)
            
            self.liveView?.showChevron = view.center.x < -50 || view.center.x > rootView.frame.width + 50
        case .ended, .cancelled:
            let velocity = velocity(in: nil)
            
            let projectedPosition = CGPoint(
                x: view.center.x + velocity.x * 0.2,  // scale velocity influence
                y: view.center.y + velocity.y * 0.2
            )
            
            var target: CGPoint
            
            if view.frame.minX < 0 || view.frame.maxX > rootView.frame.width {
                target = Self.edgePositions.min(by: {
                    $0.distance(to: projectedPosition) < $1.distance(to: projectedPosition)
                }) ?? Self.botLeftPosition
            } else {
                target = Self.adjustedEdgePositions.min(by: {
                    $0.distance(to: projectedPosition) < $1.distance(to: projectedPosition)
                }) ?? Self.botLeftPosition
                
                // Unadjust positions
                if target.x < 0 {
                    target.x += Self.extraSpacing
                } else if target.x > rootView.frame.width {
                    target.x -= Self.extraSpacing
                }
            }
            
            // Animate with spring
            UIView.animate(
                withDuration: 0.6,
                delay: 0,
                usingSpringWithDamping: 0.7,   // lower = bouncier
                initialSpringVelocity: 1,    // influences starting speed
                options: [.curveEaseOut],
                animations: {
                    view.center = target
                    self.liveView?.showChevron = target.x < 0 || target.x > rootView.frame.width
                },
                completion: nil
            )
        default:
            return
        }
        
        oldTranslation = translation
    }
}
