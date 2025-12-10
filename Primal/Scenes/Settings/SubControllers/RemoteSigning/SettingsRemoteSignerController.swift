//
//  SettingsRemoteSignerController.swift
//  Primal
//
//  Created by Pavle Stevanović on 8. 12. 2025..
//

import Combine
import UIKit
import PrimalShared

extension AppConnection: @retroactive Identifiable {
    
}

class SettingsRemoteSignerController: UIViewController, Themeable {
    
    enum TableItem: Hashable {
        case connection(AppConnection, ParsedUser)
    }
    
    var cancellables: Set<AnyCancellable> = []
    
    @Published var items: [AppConnection] = []
    
    let dataSource: UITableViewDiffableDataSource<SingleSection, TableItem>
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init() {
        dataSource = UITableViewDiffableDataSource<SingleSection, TableItem>(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .connection(let connection, let user):
                
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: RemoteSignerConnectionCell.reuseID,
                    for: indexPath
                )
                
                (cell as? RemoteSignerConnectionCell)?.configure(connection: connection, user: user)
                
                return cell
            }
        }

        
        super.init(nibName: nil, bundle: nil)
        
        title = "Connected Apps"
        
        updateTheme()
        navigationItem.backButtonDisplayMode = .default
        
        view.addSubview(tableView)
        tableView.pinToSuperview()
        tableView.delegate = self
        tableView.register(RemoteSignerConnectionCell.self, forCellReuseIdentifier: RemoteSignerConnectionCell.reuseID)
        
        Publishers.CombineLatest(LoginManager.instance.$loadedProfiles, RemoteSigningManager.instance.$activeConnections)
            .sink { [weak self] (profiles, connections) in
                var snapshot = NSDiffableDataSourceSnapshot<SingleSection, TableItem>()
                snapshot.appendSections([.main])
                snapshot.appendItems(connections.map { connection in
                    .connection(connection, profiles.first(where: { $0.data.pubkey == connection.userPubKey }) ?? .init(data: .init(pubkey: connection.userPubKey)))
                })
                self?.dataSource.apply(snapshot)
            }
            .store(in: &cancellables)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateTheme() {
        navigationItem.leftBarButtonItem = customBackButton
        
        tableView.backgroundColor = .background
        tableView.reloadData()
    }
}

extension SettingsRemoteSignerController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let connection = RemoteSigningManager.instance.activeConnections[safe: indexPath.row] else { return }
        show(SettingsConnectedAppController(appConnection: connection), sender: nil)
    }
}

extension AppConnection {
    func defaultImage(size: CGFloat, color: UIColor = .foreground3, background: UIColor = .foreground.withAlphaComponent(0.1)) -> UIImage? {
        return UIImage.create(letter: String(self.name?.first ?? "?"), size: size, color: color, backgroundColor: background)
    }
}

extension AppSession {
    func defaultImage(size: CGFloat, color: UIColor = .foreground3, background: UIColor = .foreground.withAlphaComponent(0.1)) -> UIImage? {
        return UIImage.create(letter: String(self.name?.first ?? "?"), size: size, color: color, backgroundColor: background)
    }
}

extension UIImage {
    /// Creates a circular image with a border and a centered string.
    static func create(
        letter: String,
        size: CGFloat,
        color: UIColor = .black,
        backgroundColor: UIColor = .white
    ) -> UIImage? {
        
        // 1. Define the canvas size
        let diameter = size
        let canvasSize = CGSize(width: diameter, height: diameter)
        
        let borderWidth: CGFloat = size * 0.75 * 0.05
        
        // 2. Initialize the renderer
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        
        return renderer.image { context in
            let ctx = context.cgContext
            
            // 3. Setup the bounding rectangle
            let rect = CGRect(origin: .zero, size: canvasSize)
            
            // FILL BACKGROUND
            ctx.setFillColor(backgroundColor.cgColor)
            ctx.fillEllipse(in: rect)
            
            // 4. Draw the Circle Border
            // We inset the rect by half the border width to ensure the stroke isn't clipped
            let borderInset = borderWidth / 2
            let borderRect = rect.insetBy(dx: borderInset, dy: borderInset)
            
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(borderWidth)
            ctx.addEllipse(in: borderRect)
            ctx.drawPath(using: .stroke)
            
            // 5. Configure Text Attributes
            // If no font provided, scale it to 50% of the circle diameter
            let actualFont = UIFont.appFont(withSize: diameter * 0.6, weight: .bold)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: actualFont,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: color
            ]
            
            // 6. Calculate Text Rect to Center Vertically
            // Strings draw from the top-left, so we must calculate the exact Y position
            let stringSize = letter.size(withAttributes: attributes)
            let textRect = CGRect(
                x: 0,
                y: (diameter - stringSize.height) / 2,
                width: diameter,
                height: stringSize.height
            )
            
            // 7. Draw the Text
            letter.draw(in: textRect, withAttributes: attributes)
        }
    }
}
