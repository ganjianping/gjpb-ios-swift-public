//
//  FileItem.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import Foundation

struct FileItem: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let description: String?
    let url: String
    let originalUrl: String?
    let tags: String
    let lang: String
    let displayOrder: Int
    let updatedAt: String

    var tagList: [String] {
        tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
}
