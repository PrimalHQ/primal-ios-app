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

struct RequestErrorResponse: Codable {
    var error: String
}

enum RequestError: Error {
    case noData
}

protocol Request {
    associatedtype ResponseData: Codable
    var url: URL { get }
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
                    let responseData = try decoder.decode(ResponseData.self, from: data)
                    promise(.success(responseData))
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
