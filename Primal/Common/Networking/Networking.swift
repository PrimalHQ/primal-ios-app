//
//  Networking.swift
//  Primal
//
//  Created by Pavle D Stevanović on 26.4.23..
//

import Combine
import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

protocol Request {
    associatedtype ResponseData: Codable
    var url: URL { get }
}

struct RequestErrorResponse: Codable {
    var error: String
}

enum RequestError: Error {
    case noData
}

struct TwitterUserRequest: Request {
    typealias ResponseData = Response
    
    var username: String
    
    var url: URL { URL(string: "https://media.primal.net/api/twitter/\(username)")! }
    
    struct Response: Codable {
        var avatar: String
        var banner: String
        var bio: String
        var username: String
    }
}

extension Request {
    func publisher() -> AnyPublisher<ResponseData, Error> {
        Future { promise in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error {
                    promise(.failure(error))
                    return
                }
                guard let data else {
                    promise(.failure(RequestError.noData))
                    return
                }
                
                let decoder = JSONDecoder()

                do {
                    let exampleData = try decoder.decode(ResponseData.self, from: data)
                    promise(.success(exampleData))
                } catch {
                    if let errorData = try? decoder.decode(RequestErrorResponse.self, from: data) {
                        promise(.failure(errorData.error))
                    } else {
                        promise(.failure(error))
                    }
                }
            }
            .resume()
        }
        .eraseToAnyPublisher()
    }
}
