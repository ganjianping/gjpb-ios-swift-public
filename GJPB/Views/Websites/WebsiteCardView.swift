//
//  WebsiteCardView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct WebsiteCardView: View {
    let website: Website

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Logo
            AsyncImage(url: URL(string: website.logoUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.05))
            )

            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text(website.name)
                    .font(.headline)
                    .lineLimit(1)

                // Description
                Text(website.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                // Tags
                if !website.tagList.isEmpty {
                    SmallTagView(tags: website.tagList)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
