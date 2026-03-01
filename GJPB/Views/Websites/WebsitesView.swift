//
//  WebsitesView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI
import SafariServices

struct WebsitesView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(AppSettingsService.self) private var appSettings

    @State private var websites: [Website] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var selectedTag: String?
    @State private var sortOption: SortOption = .defaultOrder
    @State private var safariURL: IdentifiableURL?

    private var lang: String { settings.language.rawValue }

    private var tags: [String] {
        appSettings.getTags(name: "website_tags", lang: lang)
    }

    private var filteredWebsites: [Website] {
        var result = websites.filter { $0.lang == lang }

        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(q) ||
                $0.description.lowercased().contains(q) ||
                $0.tags.lowercased().contains(q)
            }
        }

        if let tag = selectedTag {
            result = result.filter { $0.tagList.contains(tag) }
        }

        switch sortOption {
        case .defaultOrder:  result.sort { $0.displayOrder < $1.displayOrder }
        case .alphabetical:  result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .mostRecent:    result.sort { $0.updatedAt > $1.updatedAt }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && websites.isEmpty {
                    List { SkeletonListView(count: 8) }
                        .listStyle(.plain)
                } else if let err = errorMessage, websites.isEmpty {
                    ContentUnavailableView {
                        Label(Localizer.text("failed_to_load", lang: lang), systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(err)
                    } actions: {
                        Button(Localizer.text("retry", lang: lang)) { Task { await loadData() } }
                            .buttonStyle(.bordered)
                    }
                } else if filteredWebsites.isEmpty {
                    ContentUnavailableView(
                        Localizer.text("websites.empty", lang: lang),
                        systemImage: "globe"
                    )
                } else {
                    websiteList
                }
            }
            .navigationTitle(Localizer.text("websites.title", lang: lang))
            .searchable(text: $searchText, prompt: Text(Localizer.text("search.placeholder", lang: lang)))
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    SortPicker(selection: $sortOption, lang: lang)
                    ThemeToggleButton()
                    AccentColorPicker()
                    LanguageToggleButton()
                }
            }
            .refreshable { await loadData() }
            .task { await loadData() }
            .sheet(item: $safariURL) { item in
                SafariView(url: item.url)
                    .ignoresSafeArea()
            }
        }
    }

    private var websiteList: some View {
        List {
            TagFilterView(tags: tags, selectedTag: $selectedTag, lang: lang)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            ForEach(filteredWebsites) { website in
                WebsiteCardView(website: website)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let url = URL(string: website.url) {
                            safariURL = IdentifiableURL(url: url)
                        }
                    }
                    .accessibilityLabel("\(website.name), \(website.description)")
            }

            FooterView(lang: lang)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

    private func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: ApiListResponse<PagedData<Website>> = try await ApiService.shared.fetch(
                path: "cms/websites",
                params: ["page": "0", "size": "500"]
            )
            websites = response.data.content
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Helpers
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
