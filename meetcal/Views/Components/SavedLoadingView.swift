//
//  SavedLoadingView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/9/25.
//

import SwiftUI

struct SavedLoadingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { _ in
                SavedLoadingCard()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

private struct SavedLoadingCard: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SkeletonBlock(width: 220, height: 16, cornerRadius: 6)

            SkeletonBlock(width: 200, height: 12, cornerRadius: 6)

            HStack(spacing: 10) {
                SkeletonBlock(width: 75, height: 40, cornerRadius: 10)
                SkeletonBlock(width: 140, height: 14, cornerRadius: 6)
            }

            SkeletonBlock(width: 240, height: 2, cornerRadius: 1)

            SkeletonBlock(width: 70, height: 12, cornerRadius: 6)
            SkeletonBlock(width: 160, height: 14, cornerRadius: 6)
            SkeletonBlock(width: 120, height: 14, cornerRadius: 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical)
        .background(colorScheme == .light ? Color.white : Color(.secondarySystemGroupedBackground))
        .cornerRadius(32)
    }
}

private struct SkeletonBlock: View {
    @Environment(\.colorScheme) private var colorScheme

    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        let baseColor = colorScheme == .light ? Color(.systemGray5) : Color(.systemGray4)

        Group {
            if let width {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(baseColor)
                    .frame(width: width, height: height)
            } else {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(baseColor)
                    .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
            }
        }
        .shimmering()
    }
}

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -0.6

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    let width = proxy.size.width
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .rotationEffect(.degrees(20))
                    .offset(x: phase * width * 2)
                }
                .clipped()
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 0.6
                }
            }
    }
}

private extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

#Preview {
    SavedLoadingView()
}
