//
//  SettingsStore.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

// MARK: - Theme
enum AppTheme: String, CaseIterable, Sendable {
    case light, dark

    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Language
enum AppLanguage: String, CaseIterable, Sendable {
    case EN, ZH
}

// MARK: - Accent Color
enum AccentColorOption: String, CaseIterable, Sendable {
    case blue, purple, green, orange, red

    var color: Color {
        switch self {
        case .blue:   return Color(red: 0.231, green: 0.510, blue: 0.965)   // #3b82f6
        case .purple: return Color(red: 0.659, green: 0.333, blue: 0.969)   // #a855f7
        case .green:  return Color(red: 0.063, green: 0.725, blue: 0.506)   // #10b981
        case .orange: return Color(red: 0.976, green: 0.451, blue: 0.086)   // #f97316
        case .red:    return Color(red: 0.937, green: 0.267, blue: 0.267)   // #ef4444
        }
    }

    var hex: String {
        switch self {
        case .blue:   return "#3b82f6"
        case .purple: return "#a855f7"
        case .green:  return "#10b981"
        case .orange: return "#f97316"
        case .red:    return "#ef4444"
        }
    }

    var displayName: String { rawValue.capitalized }
}

// MARK: - Settings Store
@Observable
final class SettingsStore {
    var theme: AppTheme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: "gjpb.theme") }
    }

    var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "gjpb.language") }
    }

    var themeColor: AccentColorOption {
        didSet { UserDefaults.standard.set(themeColor.rawValue, forKey: "gjpb.themeColor") }
    }

    init() {
        // Theme
        if let saved = UserDefaults.standard.string(forKey: "gjpb.theme"),
           let t = AppTheme(rawValue: saved) {
            self.theme = t
        } else {
            self.theme = .light
        }

        // Language
        if let saved = UserDefaults.standard.string(forKey: "gjpb.language"),
           let l = AppLanguage(rawValue: saved) {
            self.language = l
        } else {
            let preferredLangs = Locale.preferredLanguages
            self.language = preferredLangs.first?.hasPrefix("zh") == true ? .ZH : .EN
        }

        // Accent Color
        if let saved = UserDefaults.standard.string(forKey: "gjpb.themeColor"),
           let c = AccentColorOption(rawValue: saved) {
            self.themeColor = c
        } else {
            self.themeColor = .blue
        }
    }

    func toggleTheme() {
        theme = theme == .light ? .dark : .light
    }

    func toggleLanguage() {
        language = language == .EN ? .ZH : .EN
    }

    func setThemeColor(_ color: AccentColorOption) {
        themeColor = color
    }
}
