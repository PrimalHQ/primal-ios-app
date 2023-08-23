//
//  FontSlider.swift
//  Primal
//
//  Created by Pavle D Stevanović on 15.8.23..
//

import UIKit

final class FontSliderParent: UIStackView {
    let slider: FontSlider
    
    init() {
        let slider = FontSlider()
        
        self.slider = slider
        let label1 = ThemeableLabel().setTheme {
            $0.text = "Aa"
            $0.font = .appFont(withSize: 16, weight: .medium)
            $0.textColor = .foreground3
        }
        
        let label2 = ThemeableLabel().setTheme {
            $0.text = "Aa"
            $0.font = .appFont(withSize: 20, weight: .medium)
            $0.textColor = .foreground3
        }
        
        super.init(frame: .zero)
        [label1, slider, label2].forEach { addArrangedSubview($0) }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class FontSlider: UIControl {
    let min = 0
    let max = 3
    var selectedNumber = 1 {
        didSet {
            print(selectedNumber)
            if oldValue != selectedNumber {
                updateSliderPosition()
            }
        }
    }
    
    lazy var stack = UIStackView([dotView()])
    var sliderIndicator = UIView().constrainToSize(24).dropShadow()
    var sliderXConstraint: NSLayoutConstraint?
    
    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstPos = touches.first?.location(in: self) else { return }
        impactGenerator.prepare()
        updateForTouchPosition(firstPos)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstPos = touches.first?.location(in: self) else { return }
        updateForTouchPosition(firstPos)
    }
}

private extension FontSlider {
    func updateForTouchPosition(_ pos: CGPoint) {
        let x = pos.x - 20 // 20 margin
        let width = bounds.width - 40 // 20 margin on both sides
        
        let stepSize = width / CGFloat(max - min)
        
        let newNumber = Int((x + (stepSize / 2)) / stepSize).clamp(min, max)
        if selectedNumber != newNumber {
            selectedNumber = newNumber
            sendActions(for: .valueChanged)
            impactGenerator.impactOccurred()
        }
    }
    
    func updateSliderPosition() {
        sliderXConstraint?.isActive = false
        
        sliderXConstraint = NSLayoutConstraint(
            item: sliderIndicator,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: stack,
            attribute: .trailing,
            multiplier: CGFloat(selectedNumber) / CGFloat(max - min) + 0.001, // 0.001 is needed because UIKit crashes if multiplier is 0
            constant: 0
        )
        sliderXConstraint?.isActive = true
    }
    
    func setup() {
        var lastLine: UIView?
        
        for _ in min..<max {
            let line = lineView()
            stack.addArrangedSubview(line)
            if let lastLine {
                line.widthAnchor.constraint(equalTo: lastLine.widthAnchor).isActive = true
            }
            lastLine = line
            stack.addArrangedSubview(dotView())
        }
        
        stack.alignment = .center
        addSubview(stack)
        stack.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 20)
        
        sliderIndicator.backgroundColor = .white
        sliderIndicator.layer.cornerRadius = 12
        stack.addSubview(sliderIndicator)
        sliderIndicator.centerToSuperview(axis: .vertical)
        updateSliderPosition()
        
        constrainToSize(height: 30)
    }
    
    func dotView() -> UIView {
        ThemeableView().setTheme({
            $0.backgroundColor = .foreground5
            $0.layer.cornerRadius = 2.5
        })
        .constrainToSize(5)
    }
    
    func lineView() -> UIView {
        ThemeableView().setTheme({
            $0.backgroundColor = .foreground5
        })
        .constrainToSize(height: 1)
    }
}
