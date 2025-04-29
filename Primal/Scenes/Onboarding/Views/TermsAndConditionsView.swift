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
    private let privacyButton = UIButton()    
    
    static let termsURL = URL(string: "https://primal.net/terms")!
    static let privacyURL = URL(string: "https://primal.net/privacy")!
    
    init(whiteOverride: Bool = false) {
        self.whiteOverride = whiteOverride
        let secondRow = UIStackView([termsButton, and, privacyButton])
        super.init(frame: .zero)
        
        [firstRow, secondRow].forEach { addArrangedSubview($0) }
        
        axis = .vertical
        alignment = .center
        
        firstRow.text = "By proceeding you accept our"
        and.text = " and "
        termsButton.setTitle("Terms of Service", for: .normal)
        privacyButton.setTitle("Privacy Policy", for: .normal)
        
        [firstRow, and].forEach {
            $0.font = .appFont(withSize: 15, weight: .regular)
        }
        
        [termsButton, privacyButton].forEach {
            $0.titleLabel?.font = .appFont(withSize: 15, weight: .bold)
        }
        
        termsButton.addAction(.init(handler: { _ in
            RootViewController.instance.present(SFSafariViewController(url: Self.termsURL), animated: true)
        }), for: .touchUpInside)
        
        privacyButton.addAction(.init(handler: { _ in
            RootViewController.instance.present(SFSafariViewController(url: Self.privacyURL), animated: true)
        }), for: .touchUpInside)
        
        updateTheme()
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        let color = whiteOverride ? UIColor.white : .foreground3
        
        firstRow.textColor = color
        and.textColor = color
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(withSize: 15, weight: .bold),
            .foregroundColor: color,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        termsButton.setAttributedTitle(NSAttributedString(string: "Terms of Service", attributes: attributes), for: .normal)
        privacyButton.setAttributedTitle(NSAttributedString(string: "Privacy Policy", attributes: attributes), for: .normal)
    }
}
