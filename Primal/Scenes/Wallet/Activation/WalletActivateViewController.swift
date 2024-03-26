//
//  WalletActivateViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.10.23..
//

import Combine
import UIKit

class WalletActivateViewController: UIViewController {    
    var iconTextColor: UIColor { .foreground }
    var inputBackgroundColor: UIColor { .background3 }
    var inputTextColor: UIColor { .foreground }
    var inputPlaceholderColor: UIColor { .foreground4 }
    var confirmButton: UIControl { confButton }
    
    private let descLabel = UILabel()
    private let firstNameInput = UITextField()
    private let lastNameInput = UITextField()
    private let emailInput = UITextField()
    
    private let dateButton = UIButton()
    
    let terms = TermsAndConditionsView()
    
    private lazy var firstScreenStack = UIStackView(axis: .vertical, [
        descLabel,                  SpacerView(height: 28, priority: .required),
        inputParent(firstNameInput),SpacerView(height: 16, priority: .required),
        inputParent(lastNameInput), SpacerView(height: 16, priority: .required),
        inputParent(emailInput),    SpacerView(height: 16, priority: .required),
        inputParent(dateButton),    SpacerView(height: 16, priority: .required),
        countryRow
    ])
    
    lazy var mainStack = UIStackView(axis: .vertical, [])
    
    private let countryInput = UITextField()
    private let stateInput = UITextField()
    private lazy var countryRow = UIStackView([inputParent(countryInput), inputParent(stateInput)])
    
    private let confButton = LargeRoundedButton(title: "Next")
    
    private var date: Date? {
        didSet {
            updateDateButton()
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    func showCodeController(_ email: String) {
        show(WalletActivationCodeController(email: email), sender: nil)
    }
}

private extension WalletActivateViewController {
    func setup() {
        title = "Activate Wallet"
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        let icon = UIImageView(image: UIImage(named: "walletFilledLarge"))
        icon.tintColor = iconTextColor
        icon.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        icon.contentMode = .scaleAspectFit
        
        let iconParent = UIView()
        iconParent.addSubview(icon)
        icon.pinToSuperview(edges: .vertical).centerToSuperview()
        
        let iconStack = UIStackView(axis: .vertical, [iconParent, SpacerView(height: 32)])
        [
            SpacerView(height: 32),
            iconStack,
            firstScreenStack,   SpacerView(height: 36),
            confirmButton,      SpacerView(height: 20),
            terms
        ].forEach { mainStack.addArrangedSubview($0) }
        mainStack.distribution = .equalSpacing
        
        let scroll = UIScrollView()
        scroll.addSubview(mainStack)
        view.addSubview(scroll)
        scroll.keyboardDismissMode = .onDrag
        
        mainStack.pinToSuperview(edges: .vertical).pinToSuperview(edges: .horizontal, padding: 36)
        mainStack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -72).isActive = true
        
        scroll.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .horizontal)
        scroll.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: 34).isActive = true
        
        stateInput.superview?.isHidden = true
        
        descLabel.text = "Activating your wallet is easy!\nWe just need a few details below:"
        descLabel.font = .appFont(withSize: 18, weight: .semibold)
        descLabel.textColor = iconTextColor
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        [firstNameInput, lastNameInput, emailInput, countryInput, stateInput].forEach {
            $0.font = .appFont(withSize: 18, weight: .bold)
            $0.textColor = inputTextColor
            $0.returnKeyType = .done
            $0.delegate = self
        }
        
        [
            (firstNameInput, "first name"),
            (lastNameInput, "last name"),
            (emailInput, "your email address"),
            (countryInput, "country of residence"),
            (stateInput, "state")
        ].forEach { field, text in
            field.attributedPlaceholder = NSAttributedString(string: text, attributes: [
                .font: UIFont.appFont(withSize: 18, weight: .regular),
                .foregroundColor: inputPlaceholderColor
            ])
        }
        
        countryRow.spacing = 12
        countryRow.distribution = .fillEqually
        
        dateButton.contentHorizontalAlignment = .leading
        
        firstNameInput.keyboardType = .namePhonePad
        emailInput.keyboardType = .emailAddress
        
        firstNameInput.autocapitalizationType = .words
        emailInput.autocapitalizationType = .none
        
        stateInput.isUserInteractionEnabled = false
        stateInput.superview?.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.showStatePopup()
        }))
        countryInput.isUserInteractionEnabled = false
        countryInput.superview?.addGestureRecognizer(BindableTapGestureRecognizer(action: { [weak self] in
            self?.showCountryPopup()
        }))
        
        updateDateButton()
        
        dateButton.addAction(.init(handler: { [weak self] _ in
            self?.showDatePopup()
        }), for: .touchUpInside)
        
        confirmButton.addAction(.init(handler: { [weak self] _ in
            self?.confirmButtonPressed()
        }), for: .touchUpInside)
    }
    
    func confirmButtonPressed() {
        guard let firstName = firstNameInput.text, !firstName.isEmpty else { firstNameInput.becomeFirstResponder(); return }
        guard let lastName = lastNameInput.text, !lastName.isEmpty else { lastNameInput.becomeFirstResponder(); return }
        guard let email = emailInput.text, !email.isEmpty else { emailInput.becomeFirstResponder(); return }
        guard let date else { showDatePopup(); return }
        
        if !date.is18YearsOld() {
            showErrorMessage("You need to be at least 18 years old.")
            return
        }
        
        guard let country = countryInput.text, !country.isEmpty else { showCountryPopup(); return }
        
        guard email.isEmail else {
            emailInput.becomeFirstResponder()
            emailInput.selectAll(nil)
            emailInput.selectAll(nil)
            return
        }
        
        var state = stateInput.text
        if country == Self.unitedStatesName {
            if state?.isEmpty != false {
                showStatePopup()
                return
            }
        } else {
            state = nil
        }
        
        resignAllInput()
        
        let countryCode = Self.countryDic[country] ?? country
        let stateCode = Self.statesDic[state ?? ""] ?? state
        
        confirmButton.isEnabled = false
        
        Connection.reconnect()
        
        PrimalWalletRequest(type: .activationCode(firstName: firstName, lastName: lastName, email: email, date: date, country: countryCode, state: stateCode)).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                if let error = res.message {
                    self?.showErrorMessage(error)
                } else {
                    self?.showCodeController(email)
                }
                
                self?.confirmButton.isEnabled = true
            }
            .store(in: &cancellables)
    }
    
    func inputParent(_ input: UIView) -> UIView {
        let view = UIView()
        view.addSubview(input)
        input.pinToSuperview(edges: .horizontal, padding: 20).centerToSuperview(axis: .vertical)
        
        view.backgroundColor = inputBackgroundColor
        view.constrainToSize(height: 48)
        view.layer.cornerRadius = 24
        
        view.addGestureRecognizer(BindableTapGestureRecognizer(action: {
            input.becomeFirstResponder()
        }))
        
        return view
    }
    
    func updateDateButton() {
        guard let date else {
            dateButton.setTitle("your date of birth", for: .normal)
            dateButton.setTitleColor(inputPlaceholderColor, for: .normal)
            dateButton.titleLabel?.font = .appFont(withSize: 18, weight: .regular)
            return
        }
        
        let formatter = DateFormatter()
        if let format = DateFormatter.dateFormat(fromTemplate: "yMMMMd", options: 0, locale: Locale.current) {
            formatter.dateFormat = format
        }
        
        dateButton.setTitle(formatter.string(from: date), for: .normal)
        dateButton.setTitleColor(inputTextColor, for: .normal)
        dateButton.titleLabel?.font = .appFont(withSize: 18, weight: .bold)
    }
    
    func showCountryPopup() {
        resignAllInput()
        
        let currentIndex = Self.countries.firstIndex(of: countryInput.text ?? "") ?? 0
        let picker = PopupUIPickerController(options: Self.countries, startingIndex: currentIndex) { [weak self] country in
            self?.countryInput.text = country
            self?.stateInput.superview?.isHidden = country != Self.unitedStatesName
        }
        present(picker, animated: true)
    }
    
    func showStatePopup() {
        resignAllInput()
        
        let currentIndex = Self.states.firstIndex(of: stateInput.text ?? "") ?? 0
        let picker = PopupUIPickerController(options: Self.states, startingIndex: currentIndex) { [weak self] state in
            self?.stateInput.text = state
        }
        present(picker, animated: true)
    }
    
    func showDatePopup() {
        resignAllInput()
        
        let picker = PopupDatePickerController(starting: date ?? .now) { [weak self] date in
            self?.date = date
        }
        present(picker, animated: true)
    }
    
    func resignAllInput() {
        [firstNameInput, emailInput, countryInput, stateInput].forEach { $0.resignFirstResponder() }
    }
}

extension WalletActivateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

struct RegionInfo {
    var label: String
    var code: String
    
    static let regionData: [String: [[String]]] = {
        guard
            let bundlePath = Bundle.main.path(forResource: "regions", ofType: "json"),
            let string = try? String(contentsOfFile: bundlePath)
        else { return [:] }
        return string.decode() ?? [:]
    }()
    
    static let allCountries: [RegionInfo] = {
        guard let countries = regionData["countries"] else { return [] }
        
        return countries.compactMap { array in
            guard let name = array.first, let code = array.last else { return nil }
            return .init(label: name, code: code)
        }
    }()
    
    static let allStates: [RegionInfo] = {
        guard let states = regionData["states"] else { return [] }
        
        return states.compactMap { array in
            guard let name = array.first, let code = array.last else { return nil }
            return .init(label: name, code: code)
        }
    }()
}

private extension WalletActivateViewController {
    private static let unitedStatesName = "United States of America"
    
    static let statesDic: [String: String] = RegionInfo.allStates.reduce(into: [:], { $0[$1.label] = $1.code })
    static let states: [String] = statesDic.sorted(by: { $0.key < $1.key }).map { $0.key }
    
    static let countryDic: [String: String] = RegionInfo.allCountries.reduce(into: [:], { $0[$1.label] = $1.code })
    static let countries: [String] = [unitedStatesName] + countryDic.filter({ $0.key != unitedStatesName}).sorted(by: { $0.key < $1.key }).map { $0.key }
}
