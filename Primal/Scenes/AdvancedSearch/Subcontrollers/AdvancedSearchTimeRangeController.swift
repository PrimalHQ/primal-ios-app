//
//  AdvancedSearchTimeRangeController.swift
//  Primal
//
//  Created by Pavle Stevanović on 11.10.24..
//

import UIKit

class AdvancedSearchTimeRangeController: UIViewController {
    let applyButton = UIButton.largeRoundedButton(title: "Apply")
    
    let stack = UIStackView(axis: .vertical, [])
    
    var currentValue: (Date, Date) {
        didSet {
            applyButton.isHidden = false
        }
    }
    
    let callback: ((Date, Date)) -> (Void)
    
    init(startingValue: (Date, Date), callback: @escaping ((Date, Date)) -> (Void)) {
        self.currentValue = startingValue
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
        title = "Custom Time Posted"
        
        let startDate = TimeRangeSelectionView(name: "Start Date", startingValue: currentValue.0)
        let endDate = TimeRangeSelectionView(name: "End Date", startingValue: currentValue.1)
        
        [startDate.datePicker, endDate.datePicker].forEach {
            $0.maximumDate = .now
        }
        
        startDate.datePicker.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.currentValue = (startDate.datePicker.date, self.currentValue.1)
        }), for: .valueChanged)
        
        endDate.datePicker.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            self.currentValue = (self.currentValue.0, endDate.datePicker.date)
        }), for: .valueChanged)

        stack.addArrangedSubview(startDate)
        stack.addArrangedSubview(endDate)
        
        view.addSubview(stack)
        stack.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .horizontal, padding: 20)
        
        view.addSubview(applyButton)
        applyButton.pinToSuperview(edges: [.bottom, .horizontal], padding: 20, safeArea: true)//.pinToSuperview(edges: 20, padding: )
        applyButton.isHidden = true
        applyButton.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            callback(currentValue)
        }), for: .touchUpInside)
    }
}

class TimeRangeSelectionView: UIView {
    let datePicker = UIDatePicker()
    
    init(name: String, startingValue: Date) {
        super.init(frame: .zero)
        
        let label = UILabel()
        label.font = .appFont(withSize: 16, weight: .regular)
        label.textColor = .foreground2
        label.text = name
        
        let stack = UIStackView(arrangedSubviews: [label, UIView(), datePicker])
        addSubview(stack)
        stack.pinToSuperview(edges: .horizontal, padding: 12).pinToSuperview(edges: .vertical, padding: 8)
        
        let border = SpacerView(height: 1, color: .background3)
        addSubview(border)
        border.pinToSuperview(edges: [.bottom, .horizontal])
        
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.tintColor = .accent
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
