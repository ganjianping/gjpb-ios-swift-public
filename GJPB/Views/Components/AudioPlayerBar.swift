//
//  AudioPlayerBar.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct AudioPlayerBar: View {
    @Environment(AudioPlayerStore.self) private var audioPlayer

    var body: some View {
        if let track = audioPlayer.currentTrack {
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: audioPlayer.duration > 0
                                ? geo.size.width * CGFloat(audioPlayer.currentTime / audioPlayer.duration)
                                : 0
                            )
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let width = geo.size.width
                                let ratio = max(0, min(1, Double(value.location.x / width)))
                                audioPlayer.seek(to: audioPlayer.duration * ratio)
                            }
                    )
                }
                .frame(height: 3)

                HStack(spacing: 12) {
                    // Cover art
                    AsyncImage(url: URL(string: track.coverImageUrl ?? track.thumbnailUrl ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            Image(systemName: "music.note")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    // Title & Artist
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.displayTitle)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                        if let artist = track.artist, !artist.isEmpty {
                            Text(artist)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Time
                    Text("\(audioPlayer.formattedCurrentTime) / \(audioPlayer.formattedDuration)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()

                    // Controls
                    HStack(spacing: 16) {
                        Button { audioPlayer.playPrevious() } label: {
                            Image(systemName: "backward.fill")
                                .accessibilityLabel("Previous")
                        }

                        Button { audioPlayer.togglePlayPause() } label: {
                            Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title3)
                                .accessibilityLabel(audioPlayer.isPlaying ? "Pause" : "Play")
                        }

                        Button { audioPlayer.playNext() } label: {
                            Image(systemName: "forward.fill")
                                .accessibilityLabel("Next")
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .background(.ultraThinMaterial)
        }
    }
}
