//
//  ArticleDetailView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct ArticleDetailView: View {
    let articleId: Int

    @Environment(SettingsStore.self) private var settings
    @Environment(AppSettingsService.self) private var appSettings

    @State private var article: ArticleDetail?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var contentHeight: CGFloat = 400
    @State private var safariURL: IdentifiableURL?

    private var lang: String { settings.language.rawValue }

    var body: some View {
        Group {
            if isLoading && article == nil {
                ScrollView {
                    VStack(spacing: 16) {
                        SkeletonCardView()
                        SkeletonCardView()
                    }
                    .padding()
                }
            } else if let err = errorMessage, article == nil {
                ContentUnavailableView {
                    Label(Localizer.text("failed_to_load", lang: lang), systemImage: "exclamationmark.triangle")
                } description: {
                    Text(err)
                } actions: {
                    Button(Localizer.text("retry", lang: lang)) { Task { await loadArticle() } }
                        .buttonStyle(.bordered)
                }
            } else if let article = article {
                articleContent(article)
            }
        }
        .navigationTitle(article?.title ?? Localizer.text("articles.title", lang: lang))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ThemeToggleButton()
                LanguageToggleButton()
            }
        }
        .task { await loadArticle() }
        .sheet(item: $safariURL) { item in
            SafariView(url: item.url)
                .ignoresSafeArea()
        }
    }

    private func articleContent(_ article: ArticleDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Cover image
                AsyncImage(url: URL(string: article.coverImageUrl ?? article.coverImageOriginalUrl ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)

                // Title
                Text(article.title)
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)

                // Meta info
                VStack(alignment: .leading, spacing: 8) {
                    if !article.tagList.isEmpty {
                        SmallTagView(tags: article.tagList)
                    }

                    HStack {
                        if !article.sourceName.isEmpty {
                            Label(article.sourceName, systemImage: "link")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("Updated: \(String(article.updatedAt.prefix(10)))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // HTML Content
                HTMLContentView(
                    htmlContent: article.content,
                    isDarkMode: settings.theme == .dark,
                    accentColor: settings.themeColor.hex,
                    contentHeight: $contentHeight
                )
                .frame(height: contentHeight)

                // View Original button
                if !article.originalUrl.isEmpty {
                    Button {
                        if let url = URL(string: article.originalUrl) {
                            safariURL = IdentifiableURL(url: url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "safari")
                            Text(Localizer.text("articles.view_original", lang: lang))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.accentColor)
                }

                FooterView(lang: lang)
            }
            .padding()
        }
    }

    private func loadArticle() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: ApiListResponse<ArticleDetail> = try await ApiService.shared.fetch(
                path: "cms/articles/\(articleId)"
            )
            article = response.data
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
