//
//  FileCardView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct FileCardView: View {
    let file: FileItem
    let onDownload: () -> Void

    @Environment(SettingsStore.self) private var settings
    private var lang: String { settings.language.rawValue }

    var body: some View {
        HStack(spacing: 12) {
            // File icon
            Image(systemName: fileIcon(for: file.name))
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Name & description
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.body.weight(.medium))
                    .lineLimit(2)

                if let desc = file.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                if !file.tagList.isEmpty {
                    SmallTagView(tags: file.tagList)
                }
            }

            Spacer()

            // Download button
            Button(action: onDownload) {
                Image(systemName: "arrow.down.circle")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Localizer.text("file.download", lang: lang))
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: onDownload)
        .accessibilityElement(children: .combine)
    }

    private func fileIcon(for name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf":                                return "doc.fill"
        case "doc", "docx":                        return "doc.text.fill"
        case "xls", "xlsx":                        return "tablecells.fill"
        case "ppt", "pptx":                        return "rectangle.fill.on.rectangle.fill"
        case "zip", "gz", "tar", "rar":            return "doc.zipper"
        case "jpg", "jpeg", "png", "gif", "webp":  return "photo.fill"
        case "mp3", "wav", "m4a":                  return "music.note"
        case "mp4", "mov", "avi":                  return "film.fill"
        case "txt":                                return "doc.plaintext.fill"
        case "json", "xml", "csv":                 return "doc.text.fill"
        case "swift", "java", "py", "js":          return "chevron.left.forwardslash.chevron.right"
        default:                                   return "doc.fill"
        }
    }
}
