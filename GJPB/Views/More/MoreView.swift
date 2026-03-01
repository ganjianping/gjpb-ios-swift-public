//
//  MoreView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct MoreView: View {
    @Environment(SettingsStore.self) private var settings

    private var lang: String { settings.language.rawValue }

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    QuestionsView()
                } label: {
                    Label(Localizer.text("questions.title", lang: lang), systemImage: "questionmark.circle")
                }
                .accessibilityLabel(Localizer.text("questions.title", lang: lang))

                NavigationLink {
                    AudiosView()
                } label: {
                    Label(Localizer.text("audios.title", lang: lang), systemImage: "headphones")
                }
                .accessibilityLabel(Localizer.text("audios.title", lang: lang))

                NavigationLink {
                    VideosView()
                } label: {
                    Label(Localizer.text("videos.title", lang: lang), systemImage: "play.rectangle")
                }
                .accessibilityLabel(Localizer.text("videos.title", lang: lang))

                NavigationLink {
                    FilesView()
                } label: {
                    Label(Localizer.text("files.title", lang: lang), systemImage: "folder")
                }
                .accessibilityLabel(Localizer.text("files.title", lang: lang))
            }
            .navigationTitle(Localizer.text("more.title", lang: lang))
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ThemeToggleButton()
                    AccentColorPicker()
                    LanguageToggleButton()
                }
            }
        }
    }
}
