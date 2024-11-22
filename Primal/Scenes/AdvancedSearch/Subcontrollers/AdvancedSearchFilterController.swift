//
//  AdvancedSearchFilterController.swift
//  Primal
//
//  Created by Pavle Stevanović on 16.10.24..
//

import Combine
import UIKit

enum FilterOrientation: String, PickableEnum {
    case any, horizontal, vertical
    
    var name: String { rawValue.capitalized }
    
    static var name: String { "Orientation" }
}

extension UIButton.Configuration {
    static func searchFilterButton(title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .background3
        config.cornerStyle = .capsule
        config.attributedTitle = .init(title, attributes: .init([
            .font: UIFont.appFont(withSize: 16, weight: .regular),
            .foregroundColor: UIColor.foreground
        ]))
        config.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        return config
    }
}

class AdvancedSearchFilterController: UIViewController {
    @Published var currentValues: SearchFilters
    
    let callback: (SearchFilters) -> Void
    
    private var cancellables: Set<AnyCancellable> = []
    let searchType: SearchType
    init(values: SearchFilters, type: SearchType, callback: @escaping (SearchFilters) -> Void) {
        self.currentValues = values
        searchType = type
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

extension AdvancedSearchFilterController {
    func setup() {
        title = "Search Filter"
        view.backgroundColor = .background4
        navigationItem.leftBarButtonItem = customBackButton
        
        let minDuration = FilterSliderView(title: "Min duration (seconds)", maxValue: 600, currentValue: currentValues.minduration ?? 0)
        let maxDuration = FilterSliderView(title: "Max duration (seconds)", maxValue: 600, currentValue: currentValues.maxduration ?? 0)
        
        let minWords = FilterSliderView(title: "Min read time (minutes)", maxValue: 20, currentValue: (currentValues.minwords ?? 0) / 238)
        let maxWords = FilterSliderView(title: "Max read time (minutes)", maxValue: 20, currentValue: (currentValues.maxwords ?? 0) / 238)
        
        let orientationButton = UIButton().constrainToSize(height: 36)
        
        let score = FilterSliderView(title: "Min content score", maxValue: 100, currentValue: currentValues.minscore ?? 0)
        let interactions = FilterSliderView(title: "Min interactions", maxValue: 100, currentValue: currentValues.mininteractions ?? 0)
        let likes = FilterSliderView(title: "Min likes", maxValue: 20, currentValue: currentValues.minlikes ?? 0)
        let zaps = FilterSliderView(title: "Min zaps", maxValue: 20, currentValue: currentValues.minzaps ?? 0)
        let replies = FilterSliderView(title: "Min replies", maxValue: 20, currentValue: currentValues.minreplies ?? 0)
        let reposts = FilterSliderView(title: "Min reposts", maxValue: 20, currentValue: currentValues.minreposts ?? 0)
        
        $currentValues.sink { values in
            orientationButton.configuration = .searchFilterButton(title: (values.orientation ?? "any").capitalized)
        }
        .store(in: &cancellables)
        
        minDuration.$currentValue
            .map { $0 == 0 ? nil : $0 }
            .assign(to: \.currentValues.minduration, onWeak: self)
            .store(in: &cancellables)
        
        maxDuration.$currentValue
            .map { $0 == 0 ? nil : $0 }
            .assign(to: \.currentValues.maxduration, onWeak: self)
            .store(in: &cancellables)
        
        minWords.$currentValue
            .map { $0 == 0 ? nil : $0 }
            .assign(to: \.currentValues.minwords, onWeak: self)
            .store(in: &cancellables)
        
        maxWords.$currentValue
            .map { $0 == 0 ? nil : $0 * 238 }
            .assign(to: \.currentValues.maxwords, onWeak: self)
            .store(in: &cancellables)
        
        score.$currentValue
            .map { $0 == 0 ? nil : $0 * 238 }
            .assign(to: \.currentValues.minscore, onWeak: self)
            .store(in: &cancellables)
        
        interactions.$currentValue
            .map { $0 == 0 ? nil : $0 }
            .assign(to: \.currentValues.mininteractions, onWeak: self)
            .store(in: &cancellables)
    
        likes.$currentValue
            .map { $0 == 0 ? nil : $0 }
            .assign(to: \.currentValues.minlikes, onWeak: self)
            .store(in: &cancellables)
    
        zaps.$currentValue
            .map { $0 == 0 ? nil : $0 }
            .assign(to: \.currentValues.minzaps, onWeak: self)
            .store(in: &cancellables)
        
        replies.$currentValue
            .map { $0 == 0 ? nil : $0 }
            .assign(to: \.currentValues.minreplies, onWeak: self)
            .store(in: &cancellables)
        
        reposts.$currentValue
            .map { $0 == 0 ? nil : $0 }
            .assign(to: \.currentValues.minreposts, onWeak: self)
            .store(in: &cancellables)
        
        let orientationLabel = UILabel()
        orientationLabel.text = "Orientation"
        orientationLabel.font = .appFont(withSize: 16, weight: .regular)
        orientationLabel.textColor = .foreground2
        let orientationRow = UIStackView([orientationLabel, UIView(), orientationButton])
        orientationRow.isLayoutMarginsRelativeArrangement = true
        orientationRow.layoutMargins = .init(top: 0, left: 0, bottom: 12, right: 0)
        
        let customBorder = SpacerView(height: 1, color: .background3)
        let customBorderParent = SpacerView(height: 25)
        customBorderParent.addSubview(customBorder)
        customBorder.centerToSuperview(axis: .vertical).pinToSuperview(edges: .horizontal)
        
        switch searchType {
        case .notes, .noteReplies, .readsComments:
            [orientationRow, minDuration, maxDuration, minWords, maxWords, customBorderParent].forEach { $0.isHidden = true }
        case .reads:
            [orientationRow, minDuration, maxDuration].forEach { $0.isHidden = true }
        case .images:
            [minDuration, maxDuration, minWords, maxWords].forEach { $0.isHidden = true }
        case .videos:
            [minWords, maxWords].forEach { $0.isHidden = true }
        case .sound:
            [orientationRow, minWords, maxWords].forEach { $0.isHidden = true }
        }
        
        let vStack = UIStackView(axis: .vertical, [
            orientationRow, minDuration, maxDuration, minWords, maxWords, customBorderParent,
            score, interactions, likes, zaps, replies, reposts
        ])
        
        let scroll = UIScrollView()
        scroll.addSubview(vStack)
        vStack.pinToSuperview()
        vStack.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        
        let apply = UIButton.largeRoundedButton(title: "Apply")
        let mainStack = UIStackView(axis: .vertical, [scroll, apply])
        mainStack.spacing = 20
        view.addSubview(mainStack)
        mainStack.pinToSuperview(padding: 20, safeArea: true)
        
        apply.addAction(.init(handler: { [weak self] _ in
            guard let self else { return }
            callback(currentValues)
            navigationController?.popViewController(animated: true)
        }), for: .touchUpInside)
        
        orientationButton.addAction(.init(handler: { [weak self] _ in
            let current = FilterOrientation(rawValue: self?.currentValues.orientation ?? "") ?? .any
            self?.show(AdvancedSearchEnumPickerController(currentValue: current, callback: { value in
                self?.currentValues.orientation = value == .any ? nil : value.rawValue
            }), sender: nil)
        }), for: .touchUpInside)
    }
}
