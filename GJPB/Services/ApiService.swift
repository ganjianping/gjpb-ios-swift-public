//
//  ApiService.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import Foundation

enum ApiError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int, String)

    nonisolated var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        }
    }
}

final class ApiService: Sendable {
    static let shared = ApiService()

    private let baseURL = "https://www.ganjianping.com/blog/v1/public/"

    private init() {}

    func fetch<T: Codable>(path: String, params: [String: String]? = nil) async throws -> T {
        try Task.checkCancellation()

        guard var components = URLComponents(string: baseURL + path) else {
            throw ApiError.invalidURL
        }

        if let params = params, !params.isEmpty {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw ApiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Log request
        print("📡 [API REQUEST] \(request.httpMethod ?? "GET") \(url.absoluteString)")
        if let params = params, !params.isEmpty {
            print("📦 [API PARAMS] \(params)")
        }
        if let body = request.httpBody, let bodyStr = String(data: body, encoding: .utf8) {
            print("📤 [API BODY] \(bodyStr)")
        }

        do {
            try Task.checkCancellation()
            let (data, response) = try await URLSession.shared.data(for: request)

            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? -1

            // Log response
            print("✅ [API RESPONSE] \(statusCode) \(url.absoluteString)")
            if let responseStr = String(data: data, encoding: .utf8) {
                let preview = responseStr.count > 1000 ? String(responseStr.prefix(1000)) + "... (\(responseStr.count) chars)" : responseStr
                print("📥 [API DATA] \(preview)")
            }

            if !(200...299).contains(statusCode) {
                throw ApiError.serverError(statusCode, "HTTP \(statusCode)")
            }

            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ [API DECODE ERROR] \(url.absoluteString) — \(error)")
                throw ApiError.decodingError(error)
            }
        } catch is CancellationError {
            print("🚫 [API CANCELLED] \(url.absoluteString)")
            throw CancellationError()
        } catch let error as ApiError {
            print("❌ [API ERROR] \(url.absoluteString) — \(error.localizedDescription)")
            throw error
        } catch {
            print("❌ [API NETWORK ERROR] \(url.absoluteString) — \(error.localizedDescription)")
            throw ApiError.networkError(error)
        }
    }
}
