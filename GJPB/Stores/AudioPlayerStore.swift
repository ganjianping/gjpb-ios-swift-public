//
//  AudioPlayerStore.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import Foundation
import AVFoundation

@Observable
final class AudioPlayerStore {
    var currentTrack: MediaItem?
    var isPlaying = false
    var currentTime: Double = 0
    var duration: Double = 0
    var playlist: [MediaItem] = []
    var showSubtitles = false

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var endObserverTask: Task<Void, Never>?

    var hasTrack: Bool { currentTrack != nil }

    func play(track: MediaItem, playlist: [MediaItem]) {
        self.playlist = playlist
        playTrack(track)
    }

    func playTrack(_ track: MediaItem) {
        guard let url = URL(string: track.url) else { return }

        // Toggle play/pause if same track
        if currentTrack?.id == track.id {
            if isPlaying { pause() } else { resume() }
            return
        }

        cleanup()

        currentTrack = track
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        // Periodic time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let strongSelf = self else { return }
            Task { @MainActor in
                strongSelf.currentTime = time.seconds
                if let dur = strongSelf.player?.currentItem?.duration.seconds, !dur.isNaN {
                    strongSelf.duration = dur
                }
            }
        }

        // End-of-track observer using async notifications
        endObserverTask = Task { @MainActor [weak self] in
            guard let self else { return }
            let notifications = NotificationCenter.default.notifications(
                named: .AVPlayerItemDidPlayToEndTime, object: playerItem
            )
            for await _ in notifications {
                guard !Task.isCancelled else { break }
                self.playNext()
            }
        }

        setupAudioSession()
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func togglePlayPause() {
        if isPlaying { pause() } else { resume() }
    }

    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }

    func playNext() {
        guard !playlist.isEmpty, let current = currentTrack else { return }
        let others = playlist.filter { $0.id != current.id }
        if let next = others.randomElement() {
            playTrack(next)
        }
    }

    func playPrevious() {
        guard !playlist.isEmpty, let current = currentTrack else { return }
        let others = playlist.filter { $0.id != current.id }
        if let prev = others.randomElement() {
            playTrack(prev)
        }
    }

    func stop() {
        cleanup()
        currentTrack = nil
        isPlaying = false
        currentTime = 0
        duration = 0
    }

    private func cleanup() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
        endObserverTask?.cancel()
        endObserverTask = nil
        player?.pause()
        player = nil
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup error: \(error)")
        }
    }

    var formattedCurrentTime: String { formatTime(currentTime) }
    var formattedDuration: String { formatTime(duration) }

    private func formatTime(_ time: Double) -> String {
        guard !time.isNaN && !time.isInfinite else { return "0:00" }
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}
