//
//  VideosView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI
import AVKit

struct VideosView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(AppSettingsService.self) private var appSettings

    @State private var videos: [MediaItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var sortOption: SortOption = .defaultOrder
    @State private var currentPage = 0
    @State private var totalPages = 1
    @State private var totalElements = 0
    @State private var playingVideoId: String?
    private let pageSize = 50

    private var lang: String { settings.language.rawValue }

    private var sortedVideos: [MediaItem] {
        var result = videos
        switch sortOption {
        case .defaultOrder:  result.sort { $0.displayOrder < $1.displayOrder }
        case .alphabetical:  result.sort { $0.displayTitle.localizedCaseInsensitiveCompare($1.displayTitle) == .orderedAscending }
        case .mostRecent:    result.sort { $0.updatedAt > $1.updatedAt }
        }
        return result
    }

    var body: some View {
        Group {
            if isLoading && videos.isEmpty {
                List { SkeletonListView(count: 5) }
                    .listStyle(.plain)
            } else if let err = errorMessage, videos.isEmpty {
                ContentUnavailableView {
                    Label(Localizer.text("failed_to_load", lang: lang), systemImage: "exclamationmark.triangle")
                } description: {
                    Text(err)
                } actions: {
                    Button(Localizer.text("retry", lang: lang)) { Task { await loadData(page: 0) } }
                        .buttonStyle(.bordered)
                }
            } else if sortedVideos.isEmpty {
                ContentUnavailableView(
                    Localizer.text("videos.empty", lang: lang),
                    systemImage: "play.rectangle"
                )
            } else {
                videoList
            }
        }
        .navigationTitle(Localizer.text("videos.title", lang: lang))
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                SortPicker(selection: $sortOption, lang: lang)
                ThemeToggleButton()
                AccentColorPicker()
                LanguageToggleButton()
            }
        }
        .refreshable {
            currentPage = 0
            await loadData(page: 0)
        }
        .task { await loadData(page: 0) }
        .onChange(of: settings.language) {
            videos = []
            currentPage = 0
            Task { await loadData(page: 0) }
        }
    }

    private var videoList: some View {
        List {
            ForEach(sortedVideos) { video in
                videoRow(for: video)
            }

            if shouldShowPagination {
                Text(paginationSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            }

            FooterView(lang: lang)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

    private var shouldShowPagination: Bool {
        totalElements > 0
    }

    private var paginationSummary: String {
        let showing = min(videos.count, totalElements)
        let ofText = Localizer.text("pagination.of", lang: lang)
        return "\(showing) \(ofText) \(totalElements)"
    }

    private func videoRow(for video: MediaItem) -> some View {
        VideoCardView(
            video: video,
            isPlaying: playingVideoId == video.id
        ) {
            togglePlayback(for: video)
        }
        .onAppear {
            if isLastVideo(video) {
                loadMoreIfNeeded()
            }
        }
    }

    private func togglePlayback(for video: MediaItem) {
        playingVideoId = playingVideoId == video.id ? nil : video.id
    }

    private func isLastVideo(_ video: MediaItem) -> Bool {
        video.id == sortedVideos.last?.id
    }

    private func loadMoreIfNeeded() {
        guard !isLoading, currentPage + 1 < totalPages else { return }
        Task { await loadData(page: currentPage + 1) }
    }

    private func loadData(page: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let response: ApiListResponse<PagedData<MediaItem>> = try await ApiService.shared.fetch(
                path: "cms/videos",
                params: [
                    "page": "\(page)",
                    "size": "\(pageSize)",
                    "lang": lang
                ]
            )
            if page == 0 {
                videos = response.data.content
            } else {
                videos.append(contentsOf: response.data.content)
            }
            currentPage = response.data.page
            totalPages = response.data.totalPages
            totalElements = response.data.totalElements
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
