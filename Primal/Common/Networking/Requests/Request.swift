//
//  Networking.swift
//  Primal
//
//  Created by Pavle D Stevanović on 26.4.23..
//

import Combine
import Foundation
import GenericJSON

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
    var body: Any? { get }
}

extension Request {
    func publisher() -> AnyPublisher<ResponseData, Error> {
        Future { promise in
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            
            if let body, let requestBody = try? JSONSerialization.data(withJSONObject: body) {
                request.httpMethod = "POST"
                request.httpBody = requestBody
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data else {
                    promise(.failure(error ?? RequestError.noData))
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
