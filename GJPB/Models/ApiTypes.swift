//
//  ApiTypes.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import Foundation

struct ApiStatus: Codable, Sendable {
    let code: Int
    let message: String
    let errors: String?
}

struct ApiMeta: Codable, Sendable {
    let serverDateTime: String
}

struct ApiListResponse<T: Codable>: Codable {
    let status: ApiStatus
    let data: T
    let meta: ApiMeta?
}

struct PagedData<T: Codable>: Codable {
    let content: [T]
    let page: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
}

// Usage: ApiListResponse<PagedData<Website>>, etc.
// A constrained generic typealias is not used here to avoid
// actor-isolation conformance issues with Swift strict concurrency.
