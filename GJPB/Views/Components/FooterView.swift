//
//  FooterView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct FooterView: View {
    let lang: String
    @Environment(AppSettingsService.self) private var appSettings

    var body: some View {
        let year = Calendar.current.component(.year, from: Date())
        let company = appSettings.getValue(name: "app_company", lang: lang) ?? "GJP"
        let appName = appSettings.getValue(name: "app_name", lang: lang) ?? "GJPB"
        let version = appSettings.getValue(name: "app_version", lang: lang) ?? "1.0"

        Text("© \(String(year)) \(company) · \(appName) · v\(version)")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}
