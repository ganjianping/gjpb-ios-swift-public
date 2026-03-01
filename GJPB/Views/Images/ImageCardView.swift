//
//  ImageCardView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct ImageCardView: View {
    let image: MediaItem

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: image.thumbnailUrl ?? image.url)) { phase in
                switch phase {
                case .success(let img):
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Rectangle()
                        .fill(Color.secondary.opacity(0.15))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        )
                }
            }
            .frame(minHeight: 100)
            .clipped()

            // Title overlay
            if let title = image.title ?? image.name, !title.isEmpty {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .foregroundStyle(.primary)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .aspectRatio(1, contentMode: .fill)
        .accessibilityLabel(image.displayTitle)
    }
}
