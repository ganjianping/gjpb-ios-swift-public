//
//  SkeletonView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

// MARK: - Card Skeleton
struct SkeletonCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 120)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.2))
                .frame(height: 16)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 200, height: 12)
        }
        .redacted(reason: .placeholder)
    }
}

// MARK: - List Skeleton
struct SkeletonListView: View {
    let count: Int

    init(count: Int = 5) {
        self.count = count
    }

    var body: some View {
        ForEach(0..<count, id: \.self) { _ in
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 14)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 150, height: 12)
                }
            }
            .redacted(reason: .placeholder)
        }
    }
}

// MARK: - Grid Skeleton
struct SkeletonGridView: View {
    let count: Int

    init(count: Int = 6) {
        self.count = count
    }

    var body: some View {
        ForEach(0..<count, id: \.self) { _ in
            SkeletonCardView()
        }
    }
}
