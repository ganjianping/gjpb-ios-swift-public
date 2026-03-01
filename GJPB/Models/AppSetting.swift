//
//  AppSetting.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import Foundation

struct AppSetting: Codable, Identifiable, Sendable {
    var id: String { "\(name)_\(lang)" }
    let name: String
    let value: String
    let lang: String
}
