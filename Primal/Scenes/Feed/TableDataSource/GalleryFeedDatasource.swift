//
//  GalleryFeedDatasource.swift
//  Primal
//
//  Created by Pavle Stevanović on 1.4.26..
//

import UIKit

enum GalleryFeedItem: Hashable {
    case note(content: ParsedContent, element: NoteFeedElement)
    case loading
}

extension NoteFeedElement {
    var galleryCellID: String {
        switch self {
        case .imageGallery: return GalleryFeedElementImageGalleryCell.galleryCellID
        case .zapGallery:   return GalleryFeedElementZapGalleryCell.galleryCellID
        case .reactions:    return GalleryFeedElementReactionsCell.galleryCellID
        case .text:         return GalleryFeedElementTextCell.galleryCellID
        default:            return GalleryFeedElementUserCell.galleryCellID
        }
    }
}

class GalleryFeedDatasource: UITableViewDiffableDataSource<SingleSection, GalleryFeedItem>, NoteFeedDatasource {
    var cells: [GalleryFeedItem] = [.loading]
    var cellCount: Int { cells.count }

    init(tableView: UITableView, delegate: FeedElementCellDelegate) {
        super.init(tableView: tableView) { [weak delegate] tableView, indexPath, item in
            let cell: UITableViewCell

            switch item {
            case .loading:
                cell = tableView.dequeueReusableCell(withIdentifier: "loading", for: indexPath)
                (cell as? SkeletonLoaderCell)?.loaderView.play()
            case let .note(content, element):
                cell = tableView.dequeueReusableCell(withIdentifier: element.galleryCellID, for: indexPath)
                HomeFeedDatasource.configureNoteCell(cell, content: content, element: element, delegate: delegate)
            }

            return cell
        }

        tableView.register(GalleryFeedElementUserCell.self, forCellReuseIdentifier: GalleryFeedElementUserCell.galleryCellID)
        tableView.register(GalleryFeedElementImageGalleryCell.self, forCellReuseIdentifier: GalleryFeedElementImageGalleryCell.galleryCellID)
        tableView.register(GalleryFeedElementZapGalleryCell.self, forCellReuseIdentifier: GalleryFeedElementZapGalleryCell.galleryCellID)
        tableView.register(GalleryFeedElementReactionsCell.self, forCellReuseIdentifier: GalleryFeedElementReactionsCell.galleryCellID)
        tableView.register(GalleryFeedElementTextCell.self, forCellReuseIdentifier: GalleryFeedElementTextCell.galleryCellID)
        tableView.register(SkeletonLoaderCell.self, forCellReuseIdentifier: "loading")

        defaultRowAnimation = .fade
    }

    func elementForIndexPath(_ indexPath: IndexPath) -> NoteFeedElement? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row] else { return nil }
        switch data {
        case .note(_, let element):
            return element
        default:
            return nil
        }
    }

    func postForIndexPath(_ indexPath: IndexPath) -> ParsedContent? {
        guard indexPath.section == 0, let data = cells[safe: indexPath.row] else { return nil }
        switch data {
        case .note(let content, _):
            return content
        default:
            return nil
        }
    }

    func setPosts(_ posts: [ParsedContent]) {
        cells = posts.flatMap { content -> [GalleryFeedItem] in
            var parts: [NoteFeedElement] = [.userInfo]
            if !content.mediaResources.isEmpty { parts.append(.imageGallery) }
            if !content.zaps.isEmpty { parts.append(.zapGallery(content.zaps)) }
            parts.append(.reactions)
            if !content.text.isEmpty { parts.append(.text) }
            return parts.map { .note(content: content, element: $0) }
        }

        if cells.isEmpty {
            cells.append(.loading)
        }

        var snapshot = NSDiffableDataSourceSnapshot<SingleSection, GalleryFeedItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cells)
        apply(snapshot, animatingDifferences: true)
    }
}
