//
//  QuestionsView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct QuestionsView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(AppSettingsService.self) private var appSettings

    @State private var questions: [Question] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var selectedTag: String?
    @State private var sortOption: SortOption = .defaultOrder

    private var lang: String { settings.language.rawValue }

    private var tags: [String] {
        appSettings.getTags(name: "question_tags", lang: lang)
    }

    private var filteredQuestions: [Question] {
        var result = questions.filter { $0.lang == lang }

        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.question.lowercased().contains(q) ||
                $0.answer.lowercased().contains(q) ||
                $0.tags.lowercased().contains(q)
            }
        }

        if let tag = selectedTag {
            result = result.filter { $0.tagList.contains(tag) }
        }

        switch sortOption {
        case .defaultOrder:  result.sort { $0.displayOrder < $1.displayOrder }
        case .alphabetical:  result.sort { $0.question.localizedCaseInsensitiveCompare($1.question) == .orderedAscending }
        case .mostRecent:    result.sort { $0.updatedAt > $1.updatedAt }
        }

        return result
    }

    var body: some View {
        Group {
            if isLoading && questions.isEmpty {
                List { SkeletonListView(count: 8) }
                    .listStyle(.plain)
            } else if let err = errorMessage, questions.isEmpty {
                ContentUnavailableView {
                    Label(Localizer.text("failed_to_load", lang: lang), systemImage: "exclamationmark.triangle")
                } description: {
                    Text(err)
                } actions: {
                    Button(Localizer.text("retry", lang: lang)) { Task { await loadData() } }
                        .buttonStyle(.bordered)
                }
            } else if filteredQuestions.isEmpty {
                ContentUnavailableView(
                    Localizer.text("questions.empty", lang: lang),
                    systemImage: "questionmark.circle"
                )
            } else {
                questionList
            }
        }
        .navigationTitle(Localizer.text("questions.title", lang: lang))
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
    }

    private var questionList: some View {
        List {
            TagFilterView(tags: tags, selectedTag: $selectedTag, lang: lang)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            ForEach(filteredQuestions) { question in
                QuestionCardView(
                    question: question,
                    isDarkMode: settings.theme == .dark,
                    accentColor: settings.themeColor.hex
                )
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
            let response: ApiListResponse<PagedData<Question>> = try await ApiService.shared.fetch(
                path: "cms/questions",
                params: ["page": "0", "size": "500"]
            )
            questions = response.data.content
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
