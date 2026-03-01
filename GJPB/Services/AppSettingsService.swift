//
//  AppSettingsService.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import Foundation

@Observable
final class AppSettingsService {
    static let shared = AppSettingsService()

    private(set) var settings: [AppSetting] = []
    private var hasFetched = false
    private let cacheKey = "gjpb.appSettings"

    private init() {
        loadFromCache()
    }

    func fetchIfNeeded() async {
        guard !hasFetched else { return }
        hasFetched = true

        do {
            let response: ApiListResponse<[AppSetting]> = try await ApiService.shared.fetch(path: "app-settings")
            self.settings = response.data
            saveToCache()
        } catch {
            print("Failed to fetch app settings: \(error)")
        }
    }

    func getValue(name: String, lang: String? = nil) -> String? {
        let filtered = settings.filter { $0.name == name }
        if let lang = lang, let match = filtered.first(where: { $0.lang == lang }) {
            return match.value
        }
        return filtered.first?.value
    }

    func getTags(name: String, lang: String? = nil) -> [String] {
        guard let value = getValue(name: name, lang: lang) else { return [] }
        return value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    private func loadFromCache() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return }
        if let cached = try? JSONDecoder().decode([AppSetting].self, from: data) {
            self.settings = cached
        }
    }

    private func saveToCache() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
}
