//
//  CheckLud16Request.swift
//  Primal
//
//  Created by Pavle Stevanović on 28.3.24..
//

import Foundation
import Combine

struct CheckLud16Request: SimpleRequest {
    let lud16: String
    
    var url: URL {
        guard let urlString = lud16.lud16toLNUrl() else { return .desktopDirectory }
        return URL(string: urlString) ?? .desktopDirectory
    }
}

protocol SimpleRequest {
    var url: URL { get }
}

extension SimpleRequest {
    func publisher() -> AnyPublisher<Bool, Never> {
        Future { promise in
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
            .resume()
        }
        .eraseToAnyPublisher()
    }
}
