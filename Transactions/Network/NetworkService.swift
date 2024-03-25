//
//  NetworkService.swift
//  Transactions
//
//  Created by Ihor Myronishyn on 16.03.2024.
//

import Foundation

enum HTTPMethod: String {
    case get, put, post, delete
    
    var value: String {
        self.rawValue.uppercased()
    }
}

final class NetworkService {
    
    // MARK: - NetworkRequestError
    
    enum NetworkRequestError: Error {
        case invalidEndpointPath
        case invalidResponse
        case badStatusCode
        case decodingFailed
    }
    
    static let shared = NetworkService()
    
    // MARK: - Init
    
    private init() {
        // Empty.
    }
    
    // MARK: - Request
    
    func request<T>(link: String, method: HTTPMethod, decode decodable: T.Type) async throws -> T where T : Decodable {
        return try await withCheckedThrowingContinuation { continuation in
            if let link = URL(string: link) {
                Task {
                    var request = URLRequest(url: link)
                    request.httpMethod = method.value
                    
                    do {
                        let (data, response) = try await URLSession.shared.data(for: request)
                        let range = 200 ..< 300
                        
                        if let response = response as? HTTPURLResponse, range.contains(response.statusCode) {
                            if let result = try? JSONDecoder().decode(T.self, from: data) {
                                continuation.resume(with: .success(result))
                            } else {
                                continuation.resume(with: .failure(NetworkRequestError.decodingFailed))
                            }
                        } else {
                            continuation.resume(with: .failure(NetworkRequestError.badStatusCode))
                        }
                    } catch {
                        continuation.resume(with: .failure(NetworkRequestError.invalidResponse))
                    }
                }
            } else {
                continuation.resume(with: .failure(NetworkRequestError.invalidEndpointPath))
            }
        }
    }
}
