//
//  AudiosView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct AudiosView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(AppSettingsService.self) private var appSettings
    @Environment(AudioPlayerStore.self) private var audioPlayer

    @State private var audios: [MediaItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var sortOption: SortOption = .defaultOrder
    @State private var currentPage = 0
    @State private var totalPages = 1
    @State private var totalElements = 0
    private let pageSize = 50

    private var lang: String { settings.language.rawValue }

    private var sortedAudios: [MediaItem] {
        var result = audios
        switch sortOption {
        case .defaultOrder:  result.sort { $0.displayOrder < $1.displayOrder }
        case .alphabetical:  result.sort { $0.displayTitle.localizedCaseInsensitiveCompare($1.displayTitle) == .orderedAscending }
        case .mostRecent:    result.sort { $0.updatedAt > $1.updatedAt }
        }
        return result
    }

    var body: some View {
        Group {
            if isLoading && audios.isEmpty {
                List { SkeletonListView(count: 8) }
                    .listStyle(.plain)
            } else if let err = errorMessage, audios.isEmpty {
                ContentUnavailableView {
                    Label(Localizer.text("failed_to_load", lang: lang), systemImage: "exclamationmark.triangle")
                } description: {
                    Text(err)
                } actions: {
                    Button(Localizer.text("retry", lang: lang)) { Task { await loadData(page: 0) } }
                        .buttonStyle(.bordered)
                }
            } else if sortedAudios.isEmpty {
                ContentUnavailableView(
                    Localizer.text("audios.empty", lang: lang),
                    systemImage: "headphones"
                )
            } else {
                audioList
            }
        }
        .navigationTitle(Localizer.text("audios.title", lang: lang))
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
            audios = []
            currentPage = 0
            Task { await loadData(page: 0) }
        }
    }

    private var audioList: some View {
        List {
            ForEach(sortedAudios) { audio in
                AudioCardView(
                    audio: audio,
                    isCurrentTrack: audioPlayer.currentTrack?.id == audio.id,
                    isPlaying: audioPlayer.currentTrack?.id == audio.id && audioPlayer.isPlaying
                ) {
                    audioPlayer.play(track: audio, playlist: sortedAudios)
                }
                .onAppear {
                    if audio.id == sortedAudios.last?.id {
                        loadMoreIfNeeded()
                    }
                }
            }

            if totalElements > 0 {
                Text("\(min(audios.count, totalElements)) \(Localizer.text("pagination.of", lang: lang)) \(totalElements)")
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

    private func loadMoreIfNeeded() {
        guard !isLoading, currentPage + 1 < totalPages else { return }
        Task { await loadData(page: currentPage + 1) }
    }

    private func loadData(page: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let response: ApiListResponse<PagedData<MediaItem>> = try await ApiService.shared.fetch(
                path: "cms/audios",
                params: [
                    "page": "\(page)",
                    "size": "\(pageSize)",
                    "lang": lang
                ]
            )
            if page == 0 {
                audios = response.data.content
            } else {
                audios.append(contentsOf: response.data.content)
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
