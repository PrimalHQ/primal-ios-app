//
//  KlipyManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 23.2.26..
//

import Combine
import Foundation

struct KlipyGIF: Codable {
    let id: String
    let content_description: String
    let media_formats: [String: KlipyMediaFormat]
    let tags: [String]?
    let created: Double?

    var tinygifURL: URL? { URL(string: media_formats["tinygif"]?.url ?? "") }
    var mediumgifURL: URL? { URL(string: media_formats["mediumgif"]?.url ?? "") }
    var gifURL: URL? { URL(string: media_formats["gif"]?.url ?? "") }
}

struct KlipyMediaFormat: Codable {
    let url: String
    let dims: [Int]
    let size: Int
}

struct KlipyResponse: Codable {
    let results: [KlipyGIF]
    let next: String?
}

final class KlipyManager {
    private static let clientKey = "FIGLamirp"
    private static let baseURL = "https://api.klipy.com/v2"
    private static let contentFilter = "medium"
    private static let mediaFilter = "gif,mediumgif,tinygif"

    private var apiKey: String { SecretsManager.instance.klipyApiKey }

    static let categories = [
        "Trending",
        "Yes",
        "No",
        "OMG",
        "Funny",
        "Sad",
        "Love",
        "Angry",
        "Dumb",
        "Terrible",
        "Wow",
        "Cringe",
        "LOL",
        "Savage",
        "Blessed"
    ]

    @Published var results: [KlipyGIF] = []
    @Published var isLoading = false

    private var nextCursor: String?
    private var currentQuery: String?
    private var cancellables = Set<AnyCancellable>()
    private var searchDebounceTimer: AnyCancellable?

    var hasMorePages: Bool { nextCursor != nil }

    init() {
        loadTrending()
    }

    // MARK: - Public API

    func loadTrending() {
        currentQuery = nil
        results = []
        nextCursor = nil
        fetchFeatured(pos: nil)
    }

    func search(_ query: String) {
        currentQuery = query
        results = []
        nextCursor = nil
        fetchSearch(query: query, pos: nil)
    }

    func searchDebounced(_ query: String, delay: TimeInterval = 0.4) {
        searchDebounceTimer?.cancel()
        searchDebounceTimer = Just(query)
            .delay(for: .seconds(delay), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.search(query)
            }
    }

    func loadNextPage() {
        guard let cursor = nextCursor, !isLoading else { return }

        if let query = currentQuery {
            fetchSearch(query: query, pos: cursor)
        } else {
            fetchFeatured(pos: cursor)
        }
    }

    func loadCategory(_ category: String) {
        if category == "Trending" {
            loadTrending()
        } else {
            search(category)
        }
    }

    func registerShare(gif: KlipyGIF) {
        var components = URLComponents(string: "\(Self.baseURL)/registershare")
        components?.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "client_key", value: Self.clientKey),
            URLQueryItem(name: "id", value: gif.id),
        ]

        if let query = currentQuery {
            components?.queryItems?.append(URLQueryItem(name: "q", value: query))
        }

        guard let url = components?.url else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }

    // MARK: - Private

    private func fetchFeatured(pos: String?) {
        let url = buildURL(endpoint: "featured", query: nil, pos: pos)
        performRequest(url: url)
    }

    private func fetchSearch(query: String, pos: String?) {
        let url = buildURL(endpoint: "search", query: query, pos: pos)
        performRequest(url: url)
    }

    private func buildURL(endpoint: String, query: String?, pos: String?) -> URL? {
        var components = URLComponents(string: "\(Self.baseURL)/\(endpoint)")
        var items = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "client_key", value: Self.clientKey),
            URLQueryItem(name: "contentfilter", value: Self.contentFilter),
            URLQueryItem(name: "media_filter", value: Self.mediaFilter),
            URLQueryItem(name: "limit", value: "30"),
        ]
        if let query {
            items.append(URLQueryItem(name: "q", value: query))
        }
        if let pos {
            items.append(URLQueryItem(name: "pos", value: pos))
        }
        components?.queryItems = items
        return components?.url
    }

    private func performRequest(url: URL?) {
        guard let url else { return }

        isLoading = true

        KlipyRequest(url: url)
            .publisher()
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("KlipyManager error: \(error)")
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }
                self.results.append(contentsOf: response.results)
                self.nextCursor = response.next
            }
            .store(in: &cancellables)
    }
}

struct KlipyRequest: Request {
    typealias ResponseData = KlipyResponse
    
    let body: Any? = nil
    let url: URL
}
