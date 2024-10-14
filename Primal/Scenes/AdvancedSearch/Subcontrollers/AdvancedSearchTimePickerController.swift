//
//  AdvancedSearchTimePickerController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.10.24..
//

import UIKit

class AdvancedSearchTimePickerController: AdvancedSearchEnumPickerController<TimePickerOption> {
    override var currentValue: TimePickerOption {
        didSet {
            switch currentValue {
            case .custom:
                break
            default:
                customLabel.isHidden = true
            }
        }
    }
    
    let customLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let custom = EnumPickerSelectionView(name: "Custom")
        stack.addArrangedSubview(custom)
        custom.addAction(.init(handler: { [weak self] _ in
            self?.show(AdvancedSearchTimeRangeController(startingValue: (.distantPast, .now), callback: { dateStart, dateEnd in
                self?.callback(.custom(dateStart, dateEnd))
                self?.navigationController?.popToRootViewController(animated: true)
            }), sender: nil)
        }), for: .touchUpInside)
        
        customLabel.font = .appFont(withSize: 16, weight: .regular)
        customLabel.textColor = .accent
        customLabel.isHidden = true
        stack.addArrangedSubview(customLabel)
        stack.setCustomSpacing(16, after: custom)
        
        switch currentValue {
        case let .custom(start, end):
            currentlySelectedView = custom
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            
            customLabel.text = "\(formatter.string(from: start)) - \(formatter.string(from: end))"
            customLabel.isHidden = false
            customLabel.transform = .init(translationX: 12, y: 0)
        default:
            break
        }
    }
}

