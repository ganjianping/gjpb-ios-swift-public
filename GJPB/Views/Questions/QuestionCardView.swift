//
//  QuestionCardView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct QuestionCardView: View {
    let question: Question
    let isDarkMode: Bool
    let accentColor: String

    @State private var isExpanded = false
    @State private var contentHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Question header (tap to expand)
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(question.question)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)

                        if !question.tagList.isEmpty {
                            SmallTagView(tags: question.tagList)
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(question.question), tap to \(isExpanded ? "collapse" : "expand")")

            // Answer (HTML)
            if isExpanded {
                HTMLContentView(
                    htmlContent: question.answer,
                    isDarkMode: isDarkMode,
                    accentColor: accentColor,
                    contentHeight: $contentHeight
                )
                .frame(height: contentHeight)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
    }
}
