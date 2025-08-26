//
//  PopupReportContentController.swift
//  Primal
//
//  Created by Pavle Stevanović on 24.4.25..
//

import UIKit

enum ReportReason: String, CaseIterable {
    case nudity
    case profanity
    case illegal
    case spam
    case impersonation
    case other
}

class PopupReportContentController: UIViewController {
    
    let optionViews = ReportReason.allCases.map { ReportPickerSelectionView(name: $0.rawValue.capitalized) }
    
    let reference: PostingReferenceObject
    init(_ reference: PostingReferenceObject) {
        self.reference = reference
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var currentReason: ReportReason?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black.withAlphaComponent(0.4)
        
        let mainView = UIView()
        mainView.backgroundColor = .background3
        mainView.layer.cornerRadius = 16
        
        view.addSubview(mainView)
        mainView.pinToSuperview(edges: .horizontal, padding: 32).centerToSuperview()
        
        let subtitle = UILabel("All reports posted will be publicly visible", color: .foreground, font: .appFont(withSize: 16, weight: .regular))
        subtitle.numberOfLines = 0
        
        let cancelButton = UIButton(configuration: .coloredButton("Dismiss", color: .accent2))
        let reportButton = UIButton(configuration: .coloredButton("Report", color: .foreground4))
        reportButton.isEnabled = false
        
        zip(optionViews, ReportReason.allCases).forEach { view, reason in
            view.addAction(.init(handler: { [weak view, weak self] _ in
                self?.currentReason = reason
                self?.optionViews.forEach { $0.isSelected = false }
                view?.isSelected = true
                reportButton.isEnabled = true
                reportButton.configuration = .coloredButton("Report", color: .accent2)
            }), for: .touchUpInside)
        }
        
        let stack = UIStackView(axis: .vertical, [
            UILabel("Report abuse", color: .foreground, font: .appFont(withSize: 22, weight: .regular)), SpacerView(height: 8),
            subtitle, SpacerView(height: 8),
        ] + optionViews + [UIStackView([UIView(), cancelButton, reportButton])])
        
        mainView.addSubview(stack)
        stack.pinToSuperview(edges: .all, padding: 20)
        
        cancelButton.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }), for: .touchUpInside)
        
        reportButton.addAction(.init(handler: { [weak self] _ in
            guard let self, let currentReason, let event = NostrObject.reportNote(currentReason, reference) else { return }
            
            dismiss(animated: true, completion: nil)
            
            PostingManager.instance.sendEvent(event, { _ in })
        }), for: .touchUpInside)
    }
}

class ReportPickerSelectionView: MyButton {
    let checkmarkIcon = SpacerView(width: 10, height: 10)
    
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
        label.textColor = .foreground
        label.text = name
        
        let circle = SpacerView(width: 16, height: 16)
        circle.layer.borderColor = UIColor.foreground.cgColor
        circle.layer.borderWidth = 1
        circle.layer.cornerRadius = 8
        
        checkmarkIcon.isHidden = true
        checkmarkIcon.backgroundColor = .accent
        checkmarkIcon.layer.cornerRadius = 5
        
        circle.addSubview(checkmarkIcon)
        checkmarkIcon.centerToSuperview()
        
        let stack = UIStackView(arrangedSubviews: [circle, label])
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .vertical, padding: 16)
        stack.alignment = .center
        stack.spacing = 10
        
        let border = SpacerView(height: 1, color: .background3)
        addSubview(border)
        border.pinToSuperview(edges: [.bottom, .horizontal])
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
