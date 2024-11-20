//
//  PremiumManageMediaController.swift
//  Primal
//
//  Created by Pavle Stevanović on 15.11.24..
//

import Combine
import UIKit
import GenericJSON

struct MediaManagementStatsResponse: Codable {
    var video: Int
    var image: Int
    var other: Int
    var free: Int
    
    static let empty: MediaManagementStatsResponse = .init(video: 0, image: 0, other: 0, free: 105792474213)
}

struct MediaManagementData: Codable {
    var url: String
    var size: Int
    var mimetype: String
    var created_at: Double
}

class PremiumManageMediaController: UITableViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    
    var stats: MediaManagementStatsResponse? { didSet { tableView.reloadData() } }
    
    var media: [MediaManagementData] = []
    var imageMetadata: [String: Primal.MediaMetadata.Resource] = [:]
    var thumbnails: [String: String] = [:]
    
    var didReachEnd = false
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        navigationItem.leftBarButtonItem = customBackButton
        title = "Media Management"
        
        loadMore()
        
        tableView.register(PremiumManageMediaStatsCell.self, forCellReuseIdentifier: "stats")
        tableView.register(PremiumManageMediaHeaderCell.self, forCellReuseIdentifier: "header")
        tableView.register(PremiumManageMediaDataCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .none
        
        guard let event = NostrObject.create(content: "", kind: 30078) else { return }

        SocketRequest(name: "membership_media_management_stats", payload: ["event_from_user": event.toJSON()])
            .publisher()
            .compactMap({
                guard let event = $0.events.first(where: { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.userMediaStats.rawValue }) else { return nil }
                return event["content"]?.stringValue?.decode()
            })
            .receive(on: DispatchQueue.main)
            .assign(to: \.stats, onWeak: self)
            .store(in: &cancellables)
        
    }
    
    func loadMore() {
        guard
            !isLoading,
            !didReachEnd,
            let event = NostrObject.create(content: "", kind: 30078)
        else { return }
        
        var payload: [String: JSON] = ["event_from_user": event.toJSON()]
        
        if let lastTime = media.last?.created_at {
            payload["until"] = .number(lastTime)
            payload["offset"] = .number(1)
        }
        
        isLoading = true
        
        SocketRequest(name: "membership_media_management_uploads", payload: .object(payload))
            .publisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] res in
                guard
                    let self,
                    let event = res.events.first(where: { Int($0["kind"]?.doubleValue ?? 0) == NostrKind.userMediaData.rawValue }),
                    let media: [MediaManagementData] = event["content"]?.stringValue?.decode(),
                    !media.isEmpty
                else {
                    self?.didReachEnd = true
                    return
                }
                
                self.media += media
                
                for metadata in res.mediaMetadata {
                    for resource in metadata.resources {
                        imageMetadata[resource.url] = resource
                    }
                    for url in (metadata.thumbnails ?? [:]).keys {
                        thumbnails[url] = metadata.thumbnails?[url] ?? thumbnails[url]
                    }
                }
                
                self.tableView.reloadData()
                
                isLoading = false
            })
            .store(in: &cancellables)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return media.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "stats", for: indexPath)
                (cell as? PremiumManageMediaStatsCell)?.updateWithStats(stats ?? .empty)
                return cell
            }
            return tableView.dequeueReusableCell(withIdentifier: "header", for: indexPath)
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let media = media[indexPath.row]
        var url = thumbnails[media.url] ?? media.url
        
        url = imageMetadata[url]?.url(for: .small)?.absoluteString ?? url
        
        if let cell = cell as? PremiumManageMediaDataCell {
            cell.setData(imageURL: url, isVideo: media.url.isVideoURL, size: media.size, date: .init(timeIntervalSince1970: media.created_at))
            cell.delegate = self
        }
        
        if indexPath.row > self.media.count - 10 {
            loadMore()
        }
        
        cell.updateBackground(isLast: self.media.count - 1 == indexPath.row)
            
        return cell
    }
}

extension PremiumManageMediaController: PremiumManageMediaDataCellDelegate {
    func copyButtonPressedInCell(_ cell: PremiumManageMediaDataCell) {
        guard
            let index = tableView.indexPath(for: cell)?.row,
            let url = media[safe: index]?.url
        else { return }
        UIPasteboard.general.string = url
        RootViewController.instance.view.showToast("Link copied!", extraPadding: 20)
    }
    
    func deleteButtonPressedInCell(_ cell: PremiumManageMediaDataCell) {
        guard
            let index = tableView.indexPath(for: cell)?.row,
            let media = media[safe: index]
        else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: media.created_at))
        
        let alert = UIAlertController(title: "Are you sure?", message: "Delete \(media.url.isVideoURL ? "Video" : "Image") from \(dateString)?", preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Delete", style: .destructive) { [weak self] _ in
            
            guard let self, let urlDicString = ["url": media.url].encodeToString(), let obj = NostrObject.create(content: urlDicString, kind: 30078) else { return }
            
            self.media.remove(at: index)
            tableView.reloadData()
            
            SocketRequest(name: "membership_media_management_delete", payload: ["event_from_user": obj.toJSON()])
                .publisher()
                .sink { res in
                    print(res.message)
                }
                .store(in: &cancellables)
        })
        present(alert, animated: true)
    }
}
