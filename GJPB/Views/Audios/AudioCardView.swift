//
//  AudioCardView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct AudioCardView: View {
    let audio: MediaItem
    let isCurrentTrack: Bool
    let isPlaying: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Cover image
            AsyncImage(url: URL(string: audio.coverImageUrl ?? audio.thumbnailUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    Image(systemName: "music.note")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 56, height: 56)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Title & Artist
            VStack(alignment: .leading, spacing: 4) {
                Text(audio.displayTitle)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                    .foregroundStyle(isCurrentTrack ? Color.accentColor : .primary)

                if let artist = audio.artist, !artist.isEmpty {
                    Text(artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if !audio.tagList.isEmpty {
                    SmallTagView(tags: Array(audio.tagList.prefix(3)))
                }
            }

            Spacer()

            // Play/Pause button
            Button(action: onTap) {
                Image(systemName: isCurrentTrack && isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isPlaying ? "Pause \(audio.displayTitle)" : "Play \(audio.displayTitle)")
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
