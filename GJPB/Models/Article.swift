//
//  Article.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import Foundation

struct ArticleSummary: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let originalUrl: String
    let sourceName: String
    let coverImageOriginalUrl: String?
    let coverImageUrl: String?
    let tags: String
    let lang: String
    let displayOrder: Int
    let updatedAt: String

    var tagList: [String] {
        tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
}

struct ArticleDetail: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let originalUrl: String
    let sourceName: String
    let coverImageOriginalUrl: String?
    let coverImageUrl: String?
    let tags: String
    let lang: String
    let displayOrder: Int
    let updatedAt: String
    let content: String
    let coverImageFilename: String?
    let createdBy: String
    let updatedBy: String
    let isActive: Bool
    let createdAt: String

    var tagList: [String] {
        tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
}
