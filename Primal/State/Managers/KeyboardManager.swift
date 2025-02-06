//
//  KeyboardManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 21.10.24..
//

import Combine
import UIKit

class KeyboardManager {
    static let instance = KeyboardManager()
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var keyboardHeight: CGFloat = 0
    
    var isShowingKeyboard: AnyPublisher<Bool, Never> {
        $keyboardHeight.map { $0 >= 5 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private(set) var animationDuration: Double = 0.25
    private(set) var curveRawValue: UInt = 7

    private init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo }
            .sink { [weak self] info in
                if let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                   let curveRawValue = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                    self?.animationDuration = duration
                    self?.curveRawValue = curveRawValue
                }
                
                if let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    self?.keyboardHeight = keyboardFrame.height
                }
            }
            .store(in: &cancellables)

        // Observe keyboard will hide notification
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .compactMap { $0.userInfo }
            .sink { [weak self] info in
                if let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                   let curveRawValue = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                    self?.animationDuration = duration
                    self?.curveRawValue = curveRawValue
                }
                
                self?.keyboardHeight = 0
            }
            .store(in: &cancellables)
    }
}

class KeyboardSizingView: UIView {
    private(set) var hConstraint: NSLayoutConstraint?
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        hConstraint = heightAnchor.constraint(equalToConstant: KeyboardManager.instance.keyboardHeight)
        hConstraint?.isActive = true
        hConstraint?.priority = .init(rawValue: 999)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateHeightCancellable(noAnimation: Bool = false) -> AnyCancellable {
        KeyboardManager.instance.$keyboardHeight.sink { [weak self] height in
            self?.hConstraint?.constant = height

            if noAnimation {
                return
            }
            
            let animationDuration = max(KeyboardManager.instance.animationDuration, 0.15)
            
            let options = UIView.AnimationOptions(rawValue: KeyboardManager.instance.curveRawValue << 16)
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: options) {
                if self?.window != nil {
                    self?.superview?.layoutIfNeeded()
                }
            }
        }
    }
}
