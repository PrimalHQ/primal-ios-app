//
//  SettingsTranslationViewController.swift
//  Primal
//
//  Created for Lightning Bounties by johnson251718-Agent
//

import UIKit

class SettingsTranslationViewController: UIViewController, Themeable, SettingsController {
    
    let table = UITableView()
    let languages = TranslationService.supportedLanguages
    
    var selectedLanguageCode: String {
        get { TranslationService.shared.targetLanguage }
        set { TranslationService.shared.targetLanguage = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Translation"
        
        setupTable()
        updateTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        mainTabBarController?.setTabBarHidden(true, animated: animated)
    }
    
    func updateTheme() {
        view.backgroundColor = .background
        table.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
    }
    
    private func setupTable() {
        view.addSubview(table)
        table.pinToSuperview(safeArea: true)
        
        table.dataSource = self
        table.delegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.separatorStyle = .singleLine
        table.separatorColor = .foreground6
    }
}

extension SettingsTranslationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1 // Header info
        }
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "About"
        }
        return "Target Language"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .background2
        cell.textLabel?.textColor = .foreground
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Uses LibreTranslate (free, open-source)"
            cell.textLabel?.font = .appFont(withSize: 14, weight: .regular)
            cell.selectionStyle = .none
            cell.accessoryType = .none
        } else {
            let language = languages[indexPath.row]
            cell.textLabel?.text = language.name
            cell.textLabel?.font = .appFont(withSize: 16, weight: .regular)
            cell.selectionStyle = .default
            cell.accessoryType = language.code == selectedLanguageCode ? .checkmark : .none
            cell.tintColor = .accent
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            selectedLanguageCode = languages[indexPath.row].code
            tableView.reloadData()
        }
    }
}
