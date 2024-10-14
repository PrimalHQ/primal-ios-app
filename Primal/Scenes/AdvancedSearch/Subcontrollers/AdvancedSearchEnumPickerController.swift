//
//  AdvancedSearchEnumPickerController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.10.24..
//

import UIKit

class AdvancedSearchEnumPickerController<T: PickableEnum> : UIViewController {
    var currentValue: T
    
    var currentlySelectedView: EnumPickerSelectionView? {
        didSet {
            oldValue?.isSelected = false
            currentlySelectedView?.isSelected = true
        }
    }
    
    let applyButton = UIButton.largeRoundedButton(title: "Apply")
    
    let stack = UIStackView(axis: .vertical, [])
    
    let callback: (T) -> (Void)
    init(currentValue: T, callback: @escaping (T) -> (Void)) {
        self.currentValue = currentValue
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background4
        navigationItem.leftBarButtonItem = backButtonWithColor(.foreground2)
        title = T.name
        
        for option in T.allCases {
            let subview = EnumPickerSelectionView(name: option.name)
            if option == currentValue {
                currentlySelectedView = subview
            }
            subview.addAction(.init(handler: { [weak self] _ in
                self?.currentValue = option
                self?.applyButton.isHidden = false
                self?.currentlySelectedView = subview
            }), for: .touchUpInside)
            stack.addArrangedSubview(subview)
        }
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .horizontal, padding: 20)
        
        view.addSubview(applyButton)
        applyButton.pinToSuperview(edges: [.bottom, .horizontal], padding: 20, safeArea: true)//.pinToSuperview(edges: 20, padding: )
        applyButton.isHidden = true
        applyButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            navigationController?.popViewController(animated: true)
            callback(currentValue)
        }), for: .touchUpInside)
    }
}

class EnumPickerSelectionView: MyButton {
    let checkmarkIcon = UIImageView(image: UIImage(named: "checkmarkSearch"))
    
    override var isSelected: Bool {
        didSet {
            checkmarkIcon.isHidden = !isSelected
        }
    }
    
    override var isPressed: Bool {
        didSet {
            alpha = isPressed ? 0.8 : 1
        }
    }
    
    init(name: String) {
        super.init(frame: .zero)
        
        let label = UILabel()
        label.font = .appFont(withSize: 16, weight: .regular)
        label.textColor = .foreground2
        label.text = name
        
        let stack = UIStackView(arrangedSubviews: [label, UIView(), checkmarkIcon])
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .vertical, padding: 16)
        stack.alignment = .center
        
        let border = SpacerView(height: 1, color: .background3)
        addSubview(border)
        border.pinToSuperview(edges: [.bottom, .horizontal])
        
        checkmarkIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        checkmarkIcon.isHidden = true
        checkmarkIcon.tintColor = .foreground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
