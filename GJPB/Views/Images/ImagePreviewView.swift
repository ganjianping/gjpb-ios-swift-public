//
//  ImagePreviewView.swift
//  GJPB
//
//  Created by Gan Jianping on 28/2/26.
//

import SwiftUI

struct ImagePreviewView: View {
    let images: [MediaItem]
    let initialIndex: Int

    @State private var currentIndex: Int
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @Environment(\.dismiss) private var dismiss

    init(images: [MediaItem], initialIndex: Int) {
        self.images = images
        self.initialIndex = initialIndex
        self._currentIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Image
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                    ZoomableImageView(url: image.url)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Overlay controls
            VStack {
                // Top bar
                HStack {
                    Text("\(currentIndex + 1) / \(images.count)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black.opacity(0.5))
                        .clipShape(Capsule())

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.bold())
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Close")
                }
                .padding()

                Spacer()

                // Title
                if let title = images[safe: currentIndex]?.displayTitle {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.5))
                        .clipShape(Capsule())
                        .padding(.bottom)
                }
            }
        }
        .statusBarHidden()
        .gesture(
            DragGesture()
                .onChanged { value in
                    if abs(value.translation.height) > abs(value.translation.width) {
                        offset = value.translation
                    }
                }
                .onEnded { value in
                    if abs(value.translation.height) > 100 {
                        dismiss()
                    } else {
                        withAnimation { offset = .zero }
                    }
                }
        )
    }
}

// MARK: - Zoomable Image
struct ZoomableImageView: View {
    let url: String
    @State private var scale: CGFloat = 1.0

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(
                        MagnifyGesture()
                            .onChanged { value in
                                scale = max(1.0, value.magnification)
                            }
                            .onEnded { _ in
                                withAnimation { scale = 1.0 }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation {
                            scale = scale > 1.0 ? 1.0 : 3.0
                        }
                    }
            case .failure:
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.gray)
            default:
                ProgressView()
                    .tint(.white)
            }
        }
    }
}

// MARK: - Safe Array Access
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
