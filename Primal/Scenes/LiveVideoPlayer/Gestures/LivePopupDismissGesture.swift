//
//  LivePopupDismissGesture.swift
//  Primal
//
//  Created by Pavle Stevanović on 13. 8. 2025..
//

import UIKit

class LivePopupDismissGesture: UIPanGestureRecognizer {
    weak var livePopup: UIViewController?
    
    init(vc: UIViewController) {
        livePopup = vc
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }
    
    @objc private func execute() {
        let trans = translation(in: nil)
        
        switch state {
        case .ended, .cancelled, .failed:
            if trans.y > 150 || velocity(in: nil).y > 300 {
                UIView.animate(withDuration: 0.3) {
                    self.view?.transform = .init(translationX: 0, y: 700)
                    self.view?.alpha = 0
                } completion: { _ in
                    self.livePopup?.view.removeFromSuperview()
                    self.livePopup?.removeFromParent()
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.view?.transform = .identity
                }
            }
        default:
            var y = trans.y
            if y < 0 {
                y = -sqrt(-y) * 3
            }
            self.view?.transform = .init(translationX: 0, y: y)
            break
        }
    }
}
