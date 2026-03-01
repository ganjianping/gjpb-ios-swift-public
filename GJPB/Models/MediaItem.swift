//
//  MediaItem.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import Foundation

struct MediaItem: Codable, Identifiable, Sendable {
    let id: String
    let name: String?
    let title: String?
    let subtitle: String?
    let description: String?
    let url: String
    let thumbnailUrl: String?
    let originalUrl: String?
    let coverImageUrl: String?
    let coverImageOriginalUrl: String?
    let altText: String?
    let captionsUrl: String?
    let tags: String
    let artist: String?
    let lang: String
    let displayOrder: Int
    let updatedAt: String

    var tagList: [String] {
        tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    var displayTitle: String {
        title ?? name ?? "Untitled"
    }
}
