//
//  FilesView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct FilesView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(AppSettingsService.self) private var appSettings

    @State private var files: [FileItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var sortOption: SortOption = .defaultOrder
    @State private var currentPage = 0
    @State private var totalPages = 1
    @State private var totalElements = 0
    @State private var safariURL: IdentifiableURL?
    private let pageSize = 50

    private var lang: String { settings.language.rawValue }

    private var sortedFiles: [FileItem] {
        var result = files
        switch sortOption {
        case .defaultOrder:  result.sort { $0.displayOrder < $1.displayOrder }
        case .alphabetical:  result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .mostRecent:    result.sort { $0.updatedAt > $1.updatedAt }
        }
        return result
    }

    var body: some View {
        Group {
            if isLoading && files.isEmpty {
                List { SkeletonListView(count: 6) }
                    .listStyle(.plain)
            } else if let err = errorMessage, files.isEmpty {
                ContentUnavailableView {
                    Label(Localizer.text("failed_to_load", lang: lang), systemImage: "exclamationmark.triangle")
                } description: {
                    Text(err)
                } actions: {
                    Button(Localizer.text("retry", lang: lang)) { Task { await loadData(page: 0) } }
                        .buttonStyle(.bordered)
                }
            } else if sortedFiles.isEmpty {
                ContentUnavailableView(
                    Localizer.text("files.empty", lang: lang),
                    systemImage: "folder"
                )
            } else {
                fileList
            }
        }
        .navigationTitle(Localizer.text("files.title", lang: lang))
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
            files = []
            currentPage = 0
            Task { await loadData(page: 0) }
        }
        .sheet(item: $safariURL) { item in
            SafariView(url: item.url)
                .ignoresSafeArea()
        }
    }

    private var fileList: some View {
        List {
            ForEach(sortedFiles) { file in
                FileCardView(file: file) {
                    if let url = URL(string: file.url) {
                        safariURL = IdentifiableURL(url: url)
                    }
                }
                .onAppear {
                    if file.id == sortedFiles.last?.id {
                        loadMoreIfNeeded()
                    }
                }
            }

            if totalElements > 0 {
                Text("\(min(files.count, totalElements)) \(Localizer.text("pagination.of", lang: lang)) \(totalElements)")
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
            let response: ApiListResponse<PagedData<FileItem>> = try await ApiService.shared.fetch(
                path: "cms/files",
                params: [
                    "page": "\(page)",
                    "size": "\(pageSize)",
                    "lang": lang
                ]
            )
            if page == 0 {
                files = response.data.content
            } else {
                files.append(contentsOf: response.data.content)
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
