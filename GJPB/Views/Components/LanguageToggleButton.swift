//
//  LanguageToggleButton.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct LanguageToggleButton: View {
    @Environment(SettingsStore.self) private var settings

    var body: some View {
        Button {
            settings.toggleLanguage()
        } label: {
            Text(settings.language == .EN ? "中" : "EN")
                .font(.body.bold())
                .accessibilityLabel(
                    Localizer.text("toggle.language.toChinese", lang: settings.language.rawValue)
                )
        }
    }
}
