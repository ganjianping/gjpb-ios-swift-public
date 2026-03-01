//
//  AccentColorPicker.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct AccentColorPicker: View {
    @Environment(SettingsStore.self) private var settings

    var body: some View {
        Menu {
            ForEach(AccentColorOption.allCases, id: \.self) { option in
                Button {
                    settings.setThemeColor(option)
                } label: {
                    HStack {
                        Image(systemName: settings.themeColor == option ? "checkmark.circle.fill" : "circle.fill")
                            .foregroundStyle(option.color)
                        Text(option.displayName)
                    }
                }
            }
        } label: {
            Image(systemName: "paintpalette")
                .font(.body)
        }
    }
}
