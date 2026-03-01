//
//  ImagesView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct ImagesView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(AppSettingsService.self) private var appSettings
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var images: [MediaItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var sortOption: SortOption = .defaultOrder
    @State private var currentPage = 0
    @State private var totalPages = 1
    @State private var totalElements = 0
    @State private var selectedImageIndex: Int?
    private let pageSize = 50

    private var lang: String { settings.language.rawValue }

    private var sortedImages: [MediaItem] {
        var result = images
        switch sortOption {
        case .defaultOrder:  result.sort { $0.displayOrder < $1.displayOrder }
        case .alphabetical:  result.sort { $0.displayTitle.localizedCaseInsensitiveCompare($1.displayTitle) == .orderedAscending }
        case .mostRecent:    result.sort { $0.updatedAt > $1.updatedAt }
        }
        return result
    }

    private var columns: [GridItem] {
        let count = sizeClass == .regular ? 5 : 3
        return Array(repeating: GridItem(.flexible(), spacing: 4), count: count)
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && images.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 4) {
                            SkeletonGridView(count: 12)
                        }
                        .padding(4)
                    }
                } else if let err = errorMessage, images.isEmpty {
                    ContentUnavailableView {
                        Label(Localizer.text("failed_to_load", lang: lang), systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(err)
                    } actions: {
                        Button(Localizer.text("retry", lang: lang)) { Task { await loadData(page: 0) } }
                            .buttonStyle(.bordered)
                    }
                } else if sortedImages.isEmpty {
                    ContentUnavailableView(
                        Localizer.text("images.empty", lang: lang),
                        systemImage: "photo"
                    )
                } else {
                    imageGrid
                }
            }
            .navigationTitle(Localizer.text("images.title", lang: lang))
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
                images = []
                currentPage = 0
                Task { await loadData(page: 0) }
            }
            .fullScreenCover(item: $selectedImageIndex) { index in
                ImagePreviewView(
                    images: sortedImages,
                    initialIndex: index
                )
            }
        }
    }

    private var imageGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(sortedImages.enumerated()), id: \.element.id) { index, image in
                    ImageCardView(image: image)
                        .onTapGesture {
                            selectedImageIndex = index
                        }
                        .onAppear {
                            if image.id == sortedImages.last?.id {
                                loadMoreIfNeeded()
                            }
                        }
                }
            }
            .padding(4)

            if totalElements > 0 {
                Text("\(min(images.count, totalElements)) \(Localizer.text("pagination.of", lang: lang)) \(totalElements)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }

            FooterView(lang: lang)
        }
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
                path: "cms/images",
                params: [
                    "page": "\(page)",
                    "size": "\(pageSize)",
                    "lang": lang
                ]
            )
            if page == 0 {
                images = response.data.content
            } else {
                images.append(contentsOf: response.data.content)
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

// Make Int conform to Identifiable for fullScreenCover
extension Int: @retroactive Identifiable {
    public var id: Int { self }
}
