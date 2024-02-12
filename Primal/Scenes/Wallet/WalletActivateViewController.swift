//
//  WalletActivateViewController.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.10.23..
//

import Combine
import UIKit

final class WalletActivateViewController: UIViewController {
    
    private let descLabel = UILabel()
    private let nameInput = UITextField()
    private let emailInput = UITextField()
    private let codeInput = UITextField()
    private let dateButton = UIButton()
    private let datePicker = UIDatePicker()
    
    private lazy var firstScreenStack = UIStackView(axis: .vertical, [
        descLabel,                  SpacerView(height: 16, priority: .required), SpacerView(height: 20),
        inputParent(nameInput),     SpacerView(height: 16, priority: .required), SpacerView(height: 8),
        inputParent(emailInput),    SpacerView(height: 16, priority: .required), SpacerView(height: 8),
        inputParent(dateButton),    SpacerView(height: 16, priority: .required), SpacerView(height: 8),
        countryRow
    ])
    
    private let countryInput = UITextField()
    private let stateInput = UITextField()
    private lazy var countryRow = UIStackView([inputParent(countryInput), inputParent(stateInput)])
    
    private let countryPicker = UIPickerView()
    private let statePicker = UIPickerView()
    
    private let confirmButton = LargeRoundedButton(title: "Next")
    
    private var date: Date? {
        didSet {
            updateDateButton()
        }
    }
    
    private var isWaitingForCode = false {
        didSet {
            UIView.transition(with: view, duration: 0.3) {
                self.firstScreenStack.isHidden = self.isWaitingForCode
                self.firstScreenStack.alpha = self.isWaitingForCode ? 0 : 1
                
                self.codeInput.superview?.isHidden = !self.isWaitingForCode
                self.codeInput.superview?.alpha = self.isWaitingForCode ? 1 : 0
                
                self.descLabel.text = self.isWaitingForCode ? "We emailed your activation code.\nPlease enter it below:" : "Activating your wallet is easy!\nAll we need is your name\nand email address:"
                self.confirmButton.title = self.isWaitingForCode ? "Finish" : "Next"
                self.confirmButton.isEnabled = !self.isWaitingForCode
            }
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
}

private extension WalletActivateViewController {
    func setup() {
        title = "Activate Wallet"
        navigationItem.leftBarButtonItem = customBackButton
        view.backgroundColor = .background
        
        let icon = UIImageView(image: UIImage(named: "walletFilledLarge"))
        icon.tintColor = .foreground
        icon.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        icon.contentMode = .scaleAspectFit
        
        let iconParent = UIView()
        iconParent.addSubview(icon)
        icon.pinToSuperview(edges: .vertical).centerToSuperview()
        
        let iconStack = UIStackView(axis: .vertical, [iconParent, SpacerView(height: 32)])
        let spacerStack = UIStackView(axis: .vertical, [SpacerView(height: 16, priority: .required), SpacerView(height: 16)])
        let mainStack = UIStackView(axis: .vertical, [SpacerView(height: 32), iconStack, firstScreenStack, inputParent(codeInput), spacerStack, confirmButton])
        mainStack.distribution = .equalSpacing
        view.addSubview(mainStack)
        mainStack.pinToSuperview(edges: .top, safeArea: true).pinToSuperview(edges: .horizontal, padding: 36)
        mainStack.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -24).isActive = true
        
        stateInput.superview?.isHidden = true
        codeInput.superview?.isHidden = true
        codeInput.superview?.alpha = 0
        
        descLabel.text = "Activating your wallet is easy!\nWe just need a few details below:"
        descLabel.font = .appFont(withSize: 18, weight: .semibold)
        descLabel.textColor = .foreground
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        [nameInput, emailInput, codeInput, countryInput, stateInput].forEach {
            $0.font = .appFont(withSize: 18, weight: .bold)
            $0.textColor = .foreground
            $0.returnKeyType = .done
            $0.delegate = self
        }
        
        [
            (nameInput, "your name"),
            (emailInput, "your email address"),
            (codeInput, "activation code"),
            (countryInput, "country of residence"),
            (stateInput, "state")
        ].forEach { field, text in
            field.attributedPlaceholder = NSAttributedString(string: text, attributes: [
                .font: UIFont.appFont(withSize: 18, weight: .regular),
                .foregroundColor: UIColor.foreground4
            ])
        }
        
        countryRow.spacing = 12
        countryRow.distribution = .fillEqually
        
        dateButton.contentHorizontalAlignment = .leading
        
        nameInput.keyboardType = .namePhonePad
        emailInput.keyboardType = .emailAddress
        codeInput.keyboardType = .numberPad
        countryInput.inputView = countryPicker
        stateInput.inputView = statePicker
        
        nameInput.autocapitalizationType = .words
        emailInput.autocapitalizationType = .none
        
        countryPicker.dataSource = self
        statePicker.dataSource = self
        countryPicker.delegate = self
        statePicker.delegate = self
        
        updateDateButton()
        
        dateButton.addAction(.init(handler: { [weak self] _ in
            self?.showDatePopup()
        }), for: .touchUpInside)
        
        codeInput.addAction(.init(handler: { [weak self] _ in
            self?.confirmButton.isEnabled = self?.codeInput.text?.count == 6
        }), for: .editingChanged)
        
        confirmButton.addAction(.init(handler: { [weak self] _ in
            self?.confirmButtonPressed()
        }), for: .touchUpInside)
    }
    
    func confirmButtonPressed() {
        guard isWaitingForCode else {
            completeFirstScreen()
            return
        }
        
        guard let code = codeInput.text, code.count == 6 else { codeInput.becomeFirstResponder(); return }
        
        codeInput.resignFirstResponder()
        codeInput.isUserInteractionEnabled = false
        confirmButton.isEnabled = false
        
        PrimalWalletRequest(type: .activate(code: code)).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                guard let self else { return }
                
                self.codeInput.isUserInteractionEnabled = true
                
                guard let newAddress = res.newAddress else {
                    self.codeInput.text = ""
                    self.codeInput.becomeFirstResponder()
                    return
                }
                
                self.confirmButton.isEnabled = true
                
                WalletManager.instance.didJustCreateWallet = true
                WalletManager.instance.isLoadingWallet = false
                WalletManager.instance.userHasWallet = true
                
                self.present(WalletTransferSummaryController(.walletActivated(newAddress: newAddress)), animated: true) {
                    self.navigationController?.viewControllers.remove(object: self)
                }
                
                guard let profile = IdentityManager.instance.user?.profileData else { return }
                profile.lud16 = newAddress
                IdentityManager.instance.updateProfile(profile) { success in
                    if !success {
                        RootViewController.instance.showErrorMessage("Unable to update profile lud16 address to \(newAddress)")
                    } else {
                        IdentityManager.instance.requestUserProfile()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func completeFirstScreen() {
        guard let name = nameInput.text, !name.isEmpty else { nameInput.becomeFirstResponder(); return }
        guard let email = emailInput.text, !email.isEmpty else { emailInput.becomeFirstResponder(); return }
        guard let date else { showDatePopup(); return }
        guard let country = countryInput.text, !country.isEmpty else { countryInput.becomeFirstResponder(); return }

        guard email.isEmail else {
            emailInput.becomeFirstResponder()
            emailInput.selectAll(nil)
            return
        }
        
        var state = stateInput.text
        if country == Self.unitedStatesName {
            if state?.isEmpty != false {
                stateInput.becomeFirstResponder()
                return
            }
        } else {
            state = nil
        }
        
        resignAllInput()
        
        isWaitingForCode = true
        
        let countryCode = Self.countryDic[country] ?? country
        let stateCode = Self.statesDic[state ?? ""] ?? state
        
        PrimalWalletRequest(type: .activationCode(name: name, email: email, date: date, country: countryCode, state: stateCode)).publisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] res in
                if let error = res.message {
                    self?.isWaitingForCode = false
                    
                    let alert = UIAlertController(title: "Warning", message: error, preferredStyle: .alert)
                    alert.addAction(.init(title: "OK", style: .default) { _ in
                        self?.navigationController?.popToRootViewController(animated: true)
                        self?.mainTabBarController?.switchToTab(.home)
                    })
                    self?.present(alert, animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
    func inputParent(_ input: UIView) -> UIView {
        let view = UIView()
        view.addSubview(input)
        input.pinToSuperview(edges: .horizontal, padding: 20).centerToSuperview(axis: .vertical)
        
        view.backgroundColor = .background3
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
            dateButton.setTitleColor(.foreground4, for: .normal)
            dateButton.titleLabel?.font = .appFont(withSize: 18, weight: .regular)
            return
        }
        
        let formatter = DateFormatter()
        if let format = DateFormatter.dateFormat(fromTemplate: "yMMMMd", options: 0, locale: Locale.current) {
            formatter.dateFormat = format
        }
        
        dateButton.setTitle(formatter.string(from: date), for: .normal)
        dateButton.setTitleColor(.foreground, for: .normal)
        dateButton.titleLabel?.font = .appFont(withSize: 18, weight: .bold)
    }
    
    func showDatePopup() {
        resignAllInput()
        
        let picker = PopupDatePickerController(starting: .now) { [weak self] date in
            self?.date = date
        }
        present(picker, animated: true)
    }
    
    func resignAllInput() {
        [nameInput, emailInput, countryInput, stateInput].forEach { $0.resignFirstResponder() }
    }
}

extension WalletActivateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension WalletActivateViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == countryPicker {
            return Self.countries.count
        }
        return Self.states.count
    }
}

extension WalletActivateViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == countryPicker {
            return Self.countries[row]
        }
        return Self.states[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == countryPicker {
            countryInput.text = Self.countries[row]
            stateInput.superview?.isHidden = Self.countries[row] != Self.unitedStatesName
            return
        }
        let stateCode = Self.states[row]
        stateInput.text = stateCode
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
    static let states: [String] = [""] + statesDic.sorted(by: { $0.key < $1.key }).map { $0.key }
    
    static let countryDic: [String: String] = RegionInfo.allCountries.reduce(into: [:], { $0[$1.label] = $1.code })
    static let countries: [String] = ["", unitedStatesName] + countryDic.filter({ $0.key != unitedStatesName}).sorted(by: { $0.key < $1.key }).map { $0.key }
}
