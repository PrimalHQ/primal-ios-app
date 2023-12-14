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
    
    private lazy var firstScreenStack = UIStackView(axis: .vertical, [
        descLabel,                  SpacerView(height: 16, priority: .required), SpacerView(height: 20),
        inputParent(nameInput),     SpacerView(height: 16, priority: .required), SpacerView(height: 8),
        inputParent(emailInput),    SpacerView(height: 16, priority: .required), SpacerView(height: 8),
        countryRow
    ])
    
    private let countryInput = UITextField()
    private let stateInput = UITextField()
    private lazy var countryRow = UIStackView([inputParent(countryInput), inputParent(stateInput)])
    
    private let countryPicker = UIPickerView()
    private let statePicker = UIPickerView()
    
    private let confirmButton = LargeRoundedButton(title: "Next")
    
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
            $0.font = .appFont(withSize: 18, weight: .regular)
            $0.textColor = .foreground
            $0.returnKeyType = .done
            $0.delegate = self
        }
        
        nameInput.placeholder = "your name"
        emailInput.placeholder = "your email address"
        codeInput.placeholder = "activation code"
        countryInput.placeholder = "country of residence"
        stateInput.placeholder = "state"
        
        stateInput.textAlignment = .center
        countryRow.spacing = 12
        
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
        
        codeInput.addAction(.init(handler: { [weak self] _ in
            self?.confirmButton.isEnabled = self?.codeInput.text?.count == 6
        }), for: .editingChanged)
        
        confirmButton.addAction(.init(handler: { [weak self] _ in
            self?.confirmButtonPressed()
        }), for: .touchUpInside)
    }
    
    func confirmButtonPressed() {
        guard isWaitingForCode else {
            guard let name = nameInput.text, !name.isEmpty else { nameInput.becomeFirstResponder(); return }
            guard let email = emailInput.text, !email.isEmpty else { emailInput.becomeFirstResponder(); return }
            guard let country = countryInput.text, !country.isEmpty else { countryInput.becomeFirstResponder(); return }

            guard email.isEmail else {
                emailInput.becomeFirstResponder()
                emailInput.selectAll(nil)
                return
            }
            
            var state = stateInput.text
            if country == "United States" {
                if state?.isEmpty != false {
                    stateInput.becomeFirstResponder()
                    return
                }
            } else {
                state = nil
            }
            
            nameInput.resignFirstResponder()
            emailInput.resignFirstResponder()
            countryInput.resignFirstResponder()
            stateInput.resignFirstResponder()
            
            isWaitingForCode = true
            
            PrimalWalletRequest(type: .activationCode(name: name, email: email, country: country, state: state)).publisher()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] res in
                    if let error = res.message {
                        self?.isWaitingForCode = false
                        self?.present(WalletTransferSummaryController(.failure(navTitle: "Error", title: "Activation failed", message: error)), animated: true)
                    }
                }
                .store(in: &cancellables)
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
    
    func inputParent(_ input: UITextField) -> UIView {
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
        return Self.states[row].1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == countryPicker {
            countryInput.text = Self.countries[row]
            stateInput.superview?.isHidden = Self.countries[row] != "United States"
            return
        }
        stateInput.text = Self.states[row].0
        
        if Self.states[row].0 == "NY" || Self.states[row].0 == "HI" {
            let alert = UIAlertController(
                title: "Warning",
                message: "Our apologies, we are not able to provide wallet features to users in the state of \(Self.states[row].1) at this time. We are working on adding \(Self.states[row].1) to the list of supported states. Please stay tuned to the announcements from Primal.",
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
                self.mainTabBarController?.switchToTab(.home)
            })
            present(alert, animated: true)
        }
    }
}

private extension WalletActivateViewController {
    static let states: [(String, String)] = [("", "")] + statesDic.sorted(by: { $0.key < $1.key })
    
    static let statesDic: [String: String] = [
        "AL": "Alabama",
        "AK": "Alaska",
        "AS": "American Samoa",
        "AZ": "Arizona",
        "AR": "Arkansas",
        "CA": "California",
        "CO": "Colorado",
        "CT": "Connecticut",
        "DE": "Delaware",
        "DC": "District Of Columbia",
        "FM": "Federated States Of Micronesia",
        "FL": "Florida",
        "GA": "Georgia",
        "GU": "Guam",
        "HI": "Hawaii",
        "ID": "Idaho",
        "IL": "Illinois",
        "IN": "Indiana",
        "IA": "Iowa",
        "KS": "Kansas",
        "KY": "Kentucky",
        "LA": "Louisiana",
        "ME": "Maine",
        "MH": "Marshall Islands",
        "MD": "Maryland",
        "MA": "Massachusetts",
        "MI": "Michigan",
        "MN": "Minnesota",
        "MS": "Mississippi",
        "MO": "Missouri",
        "MT": "Montana",
        "NE": "Nebraska",
        "NV": "Nevada",
        "NH": "New Hampshire",
        "NJ": "New Jersey",
        "NM": "New Mexico",
        "NY": "New York",
        "NC": "North Carolina",
        "ND": "North Dakota",
        "MP": "Northern Mariana Islands",
        "OH": "Ohio",
        "OK": "Oklahoma",
        "OR": "Oregon",
        "PW": "Palau",
        "PA": "Pennsylvania",
        "PR": "Puerto Rico",
        "RI": "Rhode Island",
        "SC": "South Carolina",
        "SD": "South Dakota",
        "TN": "Tennessee",
        "TX": "Texas",
        "UT": "Utah",
        "VT": "Vermont",
        "VI": "Virgin Islands",
        "VA": "Virginia",
        "WA": "Washington",
        "WV": "West Virginia",
        "WI": "Wisconsin",
        "WY": "Wyoming"
    ]
    
    static let countries: [String] = [
        "",
        "United States",
        "Afghanistan",
        "Åland Islands",
        "Albania",
        "Algeria",
        "American Samoa",
        "Andorra",
        "Angola",
        "Anguilla",
        "Antarctica",
        "Antigua and Barbuda",
        "Argentina",
        "Armenia",
        "Aruba",
        "Australia",
        "Austria",
        "Azerbaijan",
        "Bahamas",
        "Bahrain",
        "Bangladesh",
        "Barbados",
        "Belarus",
        "Belgium",
        "Belize",
        "Benin",
        "Bermuda",
        "Bhutan",
        "Bolivia",
        "Bosnia and Herzegovina",
        "Botswana",
        "Bouvet Island",
        "Brazil",
        "British Indian Ocean Territory",
        "Brunei Darussalam",
        "Bulgaria",
        "Burkina Faso",
        "Burundi",
        "Cambodia",
        "Cameroon",
        "Canada",
        "Cape Verde",
        "Cayman Islands",
        "Central African Republic",
        "Chad",
        "Chile",
        "China",
        "Christmas Island",
        "Cocos (Keeling) Islands",
        "Colombia",
        "Comoros",
        "Congo",
        "Congo, The Democratic Republic of the",
        "Cook Islands",
        "Costa Rica",
        "Cote D'Ivoire",
        "Croatia",
        "Cuba",
        "Cyprus",
        "Czech Republic",
        "Denmark",
        "Djibouti",
        "Dominica",
        "Dominican Republic",
        "Ecuador",
        "Egypt",
        "El Salvador",
        "Equatorial Guinea",
        "Eritrea",
        "Estonia",
        "Ethiopia",
        "Falkland Islands (Malvinas)",
        "Faroe Islands",
        "Fiji",
        "Finland",
        "France",
        "French Guiana",
        "French Polynesia",
        "French Southern Territories",
        "Gabon",
        "Gambia",
        "Georgia",
        "Germany",
        "Ghana",
        "Gibraltar",
        "Greece",
        "Greenland",
        "Grenada",
        "Guadeloupe",
        "Guam",
        "Guatemala",
        "Guernsey",
        "Guinea",
        "Guinea-Bissau",
        "Guyana",
        "Haiti",
        "Holy See (Vatican City State)",
        "Honduras",
        "Hong Kong",
        "Hungary",
        "Iceland",
        "India",
        "Indonesia",
        "Iran, Islamic Republic Of",
        "Iraq",
        "Ireland",
        "Isle of Man",
        "Israel",
        "Italy",
        "Jamaica",
        "Japan",
        "Jersey",
        "Jordan",
        "Kazakhstan",
        "Kenya",
        "Kiribati",
        "Korea, Democratic People's Republic of",
        "Korea, Republic of",
        "Kuwait",
        "Kyrgyzstan",
        "Lao People's Democratic Republic",
        "Latvia",
        "Lebanon",
        "Lesotho",
        "Liberia",
        "Libyan Arab Jamahiriya",
        "Liechtenstein",
        "Lithuania",
        "Luxembourg",
        "Macao",
        "Macedonia, North",
        "Madagascar",
        "Malawi",
        "Malaysia",
        "Maldives",
        "Mali",
        "Malta",
        "Marshall Islands",
        "Martinique",
        "Mauritania",
        "Mauritius",
        "Mayotte",
        "Mexico",
        "Micronesia, Federated States of",
        "Moldova, Republic of",
        "Monaco",
        "Mongolia",
        "Montenegro",
        "Montserrat",
        "Morocco",
        "Mozambique",
        "Myanmar",
        "Namibia",
        "Nauru",
        "Nepal",
        "Netherlands",
        "Netherlands Antilles",
        "New Caledonia",
        "New Zealand",
        "Nicaragua",
        "Niger",
        "Nigeria",
        "Niue",
        "Norfolk Island",
        "Northern Mariana Islands",
        "Norway",
        "Oman",
        "Pakistan",
        "Palau",
        "Palestinian Territory, Occupied",
        "Panama",
        "Papua New Guinea",
        "Paraguay",
        "Peru",
        "Philippines",
        "Pitcairn",
        "Poland",
        "Portugal",
        "Puerto Rico",
        "Qatar",
        "Reunion",
        "Romania",
        "Russian Federation",
        "Rwanda",
        "Saint Helena",
        "Saint Kitts and Nevis",
        "Saint Lucia",
        "Saint Pierre and Miquelon",
        "Saint Vincent and the Grenadines",
        "Samoa",
        "San Marino",
        "Sao Tome and Principe",
        "Saudi Arabia",
        "Senegal",
        "Serbia",
        "Seychelles",
        "Sierra Leone",
        "Singapore",
        "Slovakia",
        "Slovenia",
        "Solomon Islands",
        "Somalia",
        "South Africa",
        "South Georgia and the South Sandwich Islands",
        "Spain",
        "Sri Lanka",
        "Sudan",
        "Suriname",
        "Svalbard and Jan Mayen",
        "Swaziland",
        "Sweden",
        "Switzerland",
        "Syrian Arab Republic",
        "Taiwan, Province of China",
        "Tajikistan",
        "Tanzania, United Republic of",
        "Thailand",
        "Timor-Leste",
        "Togo",
        "Tokelau",
        "Tonga",
        "Trinidad and Tobago",
        "Tunisia",
        "Turkey",
        "Turkmenistan",
        "Turks and Caicos Islands",
        "Tuvalu",
        "Uganda",
        "Ukraine",
        "United Arab Emirates",
        "United Kingdom",
        "United States Minor Outlying Islands",
        "Uruguay",
        "Uzbekistan",
        "Vanuatu",
        "Venezuela",
        "Viet Nam",
        "Virgin Islands, British",
        "Virgin Islands, U.S.",
        "Wallis and Futuna",
        "Western Sahara",
        "Yemen",
        "Zambia",
        "Zimbabwe"
    ]
}
