//
//  ArticlesView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct ArticlesView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(AppSettingsService.self) private var appSettings
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var articles: [ArticleSummary] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var sortOption: SortOption = .defaultOrder
    @State private var currentPage = 0
    @State private var totalPages = 1
    @State private var totalElements = 0
    private let pageSize = 50

    private var lang: String { settings.language.rawValue }

    private var sortedArticles: [ArticleSummary] {
        var result = articles
        switch sortOption {
        case .defaultOrder:  result.sort { $0.displayOrder < $1.displayOrder }
        case .alphabetical:  result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .mostRecent:    result.sort { $0.updatedAt > $1.updatedAt }
        }
        return result
    }

    private var columns: [GridItem] {
        if sizeClass == .regular {
            return [GridItem(.flexible()), GridItem(.flexible())]
        }
        return [GridItem(.flexible())]
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && articles.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            SkeletonGridView(count: 6)
                        }
                        .padding()
                    }
                } else if let err = errorMessage, articles.isEmpty {
                    ContentUnavailableView {
                        Label(Localizer.text("failed_to_load", lang: lang), systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(err)
                    } actions: {
                        Button(Localizer.text("retry", lang: lang)) { Task { await loadData(page: 0) } }
                            .buttonStyle(.bordered)
                    }
                } else if sortedArticles.isEmpty {
                    ContentUnavailableView(
                        Localizer.text("articles.empty", lang: lang),
                        systemImage: "doc.text"
                    )
                } else {
                    articleGrid
                }
            }
            .navigationTitle(Localizer.text("articles.title", lang: lang))
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
                articles = []
                currentPage = 0
                Task { await loadData(page: 0) }
            }
        }
    }

    private var articleGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(sortedArticles) { article in
                    NavigationLink(value: article.id) {
                        ArticleCardView(article: article)
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        if article.id == sortedArticles.last?.id {
                            loadMoreIfNeeded()
                        }
                    }
                }
            }
            .padding(.horizontal)

            // Item count
            if totalElements > 0 {
                Text("\(min(articles.count, totalElements)) \(Localizer.text("pagination.of", lang: lang)) \(totalElements)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }

            FooterView(lang: lang)
        }
        .navigationDestination(for: Int.self) { articleId in
            ArticleDetailView(articleId: articleId)
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
            let response: ApiListResponse<PagedData<ArticleSummary>> = try await ApiService.shared.fetch(
                path: "cms/articles",
                params: [
                    "page": "\(page)",
                    "size": "\(pageSize)",
                    "lang": lang
                ]
            )
            if page == 0 {
                articles = response.data.content
            } else {
                articles.append(contentsOf: response.data.content)
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
