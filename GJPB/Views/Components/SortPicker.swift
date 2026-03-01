//
//  SortPicker.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

enum SortOption: String, CaseIterable, Sendable {
    case defaultOrder
    case alphabetical
    case mostRecent

    func label(lang: String) -> String {
        switch self {
        case .defaultOrder: return Localizer.text("sort.default", lang: lang)
        case .alphabetical: return Localizer.text("sort.alpha", lang: lang)
        case .mostRecent:   return Localizer.text("sort.recent", lang: lang)
        }
    }
}

struct SortPicker: View {
    @Binding var selection: SortOption
    let lang: String

    var body: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    HStack {
                        Text(option.label(lang: lang))
                        if selection == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.body)
        }
    }
}
