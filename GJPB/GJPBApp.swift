//
//  GJPBApp.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

@main
struct GJPBApp: App {
    @State private var settingsStore = SettingsStore()
    @State private var audioPlayerStore = AudioPlayerStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settingsStore)
                .environment(audioPlayerStore)
                .environment(AppSettingsService.shared)
                .preferredColorScheme(settingsStore.theme.colorScheme)
                .tint(settingsStore.themeColor.color)
                .task {
                    await AppSettingsService.shared.fetchIfNeeded()
                }
        }
    }
}
