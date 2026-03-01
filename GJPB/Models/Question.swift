//
//  Question.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import Foundation

struct Question: Codable, Identifiable, Sendable {
    let id: String
    let question: String
    let answer: String
    let tags: String
    let lang: String
    let displayOrder: Int
    let updatedAt: String

    var tagList: [String] {
        tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }
}
