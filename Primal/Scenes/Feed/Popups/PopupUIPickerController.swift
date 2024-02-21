//
//  PopupUIPickerController.swift
//  Primal
//
//  Created by Pavle Stevanović on 20.2.24..
//

import Combine
import UIKit

final class PopupUIPickerController: UIViewController {
    let picker = UIPickerView()
    
    let applyButton = LargeRoundedButton(title: "Apply")
    let cancelButton = SimpleRoundedButton(title: "Cancel", accent: false)
    
    let options: [String]
    
    init(options: [String], startingIndex: Int, _ callback: @escaping (String) -> Void) {
        self.options = options
        super.init(nibName: nil, bundle: nil)
        
        picker.tintColor = .accent
        picker.dataSource = self
        picker.delegate = self
        picker.selectRow(startingIndex, inComponent: 0, animated: false)
        
        overrideUserInterfaceStyle = Theme.current.userInterfaceStyle
        
        setup()
        
        cancelButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        
        applyButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            callback(options[safe: picker.selectedRow(inComponent: 0)] ?? "")
            self.dismiss(animated: true)
        }), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PopupUIPickerController {
    func setup() {
        view.backgroundColor = .background4
        if let pc = presentationController as? UISheetPresentationController {
            pc.detents = [.custom(resolver: { _ in 353 })]
        }
        
        let pullBarParent = UIView()
        let pullBar = UIView()
        pullBarParent.addSubview(pullBar)
        pullBar.centerToSuperview().pinToSuperview(edges: .vertical)
        
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, applyButton])
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 16
        
        let stack = UIStackView(arrangedSubviews: [pullBarParent, SpacerView(height: 22), picker, SpacerView(height: 12), buttonStack, SpacerView(height: 12)])
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .top, padding: 16).pinToSuperview(edges: .horizontal, padding: 32)
        let botC = stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        botC.isActive = true
        botC.priority = .defaultHigh
        
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        pullBar.constrainToSize(width: 60, height: 5)
        pullBar.backgroundColor = .foreground.withAlphaComponent(0.8)
        pullBar.layer.cornerRadius = 2.5
    }
}

extension PopupUIPickerController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        options.count
    }
}

extension PopupUIPickerController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[safe: row]
    }
}
