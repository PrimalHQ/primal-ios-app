//
//  TermsAndConditionsView.swift
//  Primal
//
//  Created by Pavle Stevanović on 21.2.24..
//

import UIKit
import SafariServices

final class TermsAndConditionsView: UIStackView, Themeable {
    private let whiteOverride: Bool
    
    private let firstRow = UILabel()
    private let and = UILabel()
    private let termsButton = UIButton()
    private let conditionsButton = UIButton()    
    
    static let termsURL = URL(string: "https://primal.net/terms")!
    static let conditionsURL = URL(string: "https://primal.net/conditions")!
    
    init(whiteOverride: Bool = false) {
        self.whiteOverride = whiteOverride
        let secondRow = UIStackView([termsButton, and, conditionsButton])
        super.init(axis: .vertical, [firstRow, secondRow])
        
        alignment = .center
        
        firstRow.text = "By proceeding you accept our"
        and.text = " and "
        termsButton.setTitle("Terms of Service", for: .normal)
        conditionsButton.setTitle("Privacy Policy", for: .normal)
        
        [firstRow, and].forEach {
            $0.font = .appFont(withSize: 15, weight: .regular)
        }
        
        [termsButton, conditionsButton].forEach {
            $0.titleLabel?.font = .appFont(withSize: 15, weight: .bold)
        }
        
        termsButton.addAction(.init(handler: { _ in
            RootViewController.instance.present(SFSafariViewController(url: Self.termsURL), animated: true)
        }), for: .touchUpInside)
        
        conditionsButton.addAction(.init(handler: { _ in
            RootViewController.instance.present(SFSafariViewController(url: Self.conditionsURL), animated: true)
        }), for: .touchUpInside)
        
        updateTheme()
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        if whiteOverride {
            firstRow.textColor = .white
            and.textColor = .white
            [termsButton, conditionsButton].forEach { $0.setTitleColor(.white, for: .normal) }
            return
        }
        
        firstRow.textColor = .foreground3
        and.textColor = .foreground3
        [termsButton, conditionsButton].forEach { $0.setTitleColor(.accent, for: .normal) }
    }
}
