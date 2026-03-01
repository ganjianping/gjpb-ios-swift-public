//
//  ThemeToggleButton.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct ThemeToggleButton: View {
    @Environment(SettingsStore.self) private var settings

    var body: some View {
        Button {
            settings.toggleTheme()
        } label: {
            Image(systemName: settings.theme == .light ? "moon.fill" : "sun.max.fill")
                .font(.body)
                .accessibilityLabel(
                    settings.theme == .light
                        ? Localizer.text("toggle.theme.dark", lang: settings.language.rawValue)
                        : Localizer.text("toggle.theme.light", lang: settings.language.rawValue)
                )
        }
    }
}
