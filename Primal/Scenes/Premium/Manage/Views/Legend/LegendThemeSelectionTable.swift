//
//  LegendThemeSelectionTable.swift
//  Primal
//
//  Created by Pavle Stevanović on 18.11.24..
//

import Combine
import UIKit

class LegendThemeSelectionTable: UIStackView {
    private let legendViews: [LegendThemeView] = [.init(theme: nil)] + LegendTheme.allCases.map { LegendThemeView(theme: $0) }
    
    @Published private(set) var selectedTheme: LegendTheme?
    
    private var currentlySelected: LegendThemeView? {
        didSet {
            oldValue?.isCurrent = false
            currentlySelected?.isCurrent = true
            selectedTheme = currentlySelected?.theme
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        let topStack = UIStackView(Array(legendViews.prefix(5)))
        topStack.spacing = 16
        
        let botStack = UIStackView(Array(legendViews.dropFirst(5)))
        botStack.spacing = 16
        
        axis = .vertical
        alignment = .center
        spacing = 16
        addArrangedSubview(topStack)
        addArrangedSubview(botStack)
        
        currentlySelected = legendViews.first
        legendViews.first?.isCurrent = true
        legendViews.forEach { view in
            view.addAction(.init(handler: { [weak self, weak view] _ in
                self?.currentlySelected = view
            }), for: .touchUpInside)
        }
    }
    
    func selectTheme(_ theme: LegendTheme?) {
        currentlySelected = legendViews.first(where: { $0.theme == theme })
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private class LegendThemeView: MyButton {
    var isCurrent: Bool = false {
        didSet {
            backgroundColor = isCurrent ? .foreground : .clear
        }
    }
    
    var backgroundView = SpacerView(width: 41, height: 41, color: .background)
    
    let theme: LegendTheme?
    init(theme: LegendTheme?) {
        self.theme = theme
        super.init(frame: .zero)
        
        constrainToSize(47)
        layer.cornerRadius = 47 / 2
        
        addSubview(backgroundView)
        backgroundView.centerToSuperview()
        backgroundView.layer.cornerRadius = 41 / 2
        
        if let theme {
            let gradientView = GradientView(colors: theme.colors).constrainToSize(35)
            gradientView.layer.cornerRadius = 35 / 2
            gradientView.layer.masksToBounds = true
            gradientView.gradientLayer.startPoint = theme.startPoint
            gradientView.gradientLayer.endPoint = theme.endPoint
            gradientView.gradientLayer.locations = theme.nsNumberLocations
            addSubview(gradientView)
            gradientView.centerToSuperview()
        } else {
            let imageView = UIImageView(image: UIImage(named: "noLegendTheme"))
            imageView.tintColor = .foreground5
            addSubview(imageView)
            imageView.centerToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
