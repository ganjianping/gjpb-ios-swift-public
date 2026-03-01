//
//  VideoCardView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI
import AVKit

struct VideoCardView: View {
    let video: MediaItem
    let isPlaying: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Video player or cover image
            if isPlaying, let url = URL(string: video.url) {
                VideoPlayer(player: AVPlayer(url: url))
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                // Cover image with play overlay
                ZStack {
                    AsyncImage(url: URL(string: video.coverImageUrl ?? video.thumbnailUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(Color.secondary.opacity(0.15))
                                .overlay(
                                    Image(systemName: "play.rectangle")
                                        .font(.largeTitle)
                                        .foregroundStyle(.secondary)
                                )
                        }
                    }
                    .frame(height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    // Play button overlay
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }
                .onTapGesture(perform: onTap)
                .accessibilityLabel("Play \(video.displayTitle)")
            }

            // Title & tags
            VStack(alignment: .leading, spacing: 4) {
                Text(video.displayTitle)
                    .font(.headline)
                    .lineLimit(2)

                if !video.tagList.isEmpty {
                    SmallTagView(tags: Array(video.tagList.prefix(4)))
                }
            }
        }
        .padding(.vertical, 4)
    }
}
