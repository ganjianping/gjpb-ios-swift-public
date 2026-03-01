//
//  ArticleCardView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct ArticleCardView: View {
    let article: ArticleSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover image
            AsyncImage(url: URL(string: article.coverImageUrl ?? article.coverImageOriginalUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Rectangle()
                        .fill(Color.secondary.opacity(0.1))
                        .overlay(
                            Image(systemName: "doc.text")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        )
                }
            }
            .frame(height: 160)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                // Summary
                Text(article.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                // Tags + date footer
                HStack {
                    if !article.tagList.isEmpty {
                        SmallTagView(tags: Array(article.tagList.prefix(3)))
                    }
                    Spacer()
                    Text(formatDate(article.updatedAt))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(12)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .accessibilityElement(children: .combine)
    }

    private func formatDate(_ dateStr: String) -> String {
        // Try to parse and format nicely; fallback to first 10 chars
        String(dateStr.prefix(10))
    }
}
