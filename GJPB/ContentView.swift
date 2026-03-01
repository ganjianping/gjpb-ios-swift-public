//
//  ContentView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(SettingsStore.self) private var settings
    @Environment(AudioPlayerStore.self) private var audioPlayer

    private var lang: String { settings.language.rawValue }

    var body: some View {
        TabView {
            WebsitesView()
                .tabItem {
                    Label(Localizer.text("websites.title", lang: lang), systemImage: "globe")
                }

            ArticlesView()
                .tabItem {
                    Label(Localizer.text("articles.title", lang: lang), systemImage: "doc.text")
                }

            ImagesView()
                .tabItem {
                    Label(Localizer.text("images.title", lang: lang), systemImage: "photo")
                }

            MoreView()
                .tabItem {
                    Label(Localizer.text("more.title", lang: lang), systemImage: "ellipsis.circle")
                }
        }
        .safeAreaInset(edge: .bottom) {
            if audioPlayer.hasTrack {
                AudioPlayerBar()
            }
        }
    }
}
