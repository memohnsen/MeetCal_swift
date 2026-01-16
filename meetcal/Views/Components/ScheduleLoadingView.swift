//
//  ScheduleLoadingView.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/9/25.
//

import SwiftUI

struct ScheduleLoadingView: View {
    var body: some View {
        List {
            ForEach(0..<2, id: \.self) { sectionIndex in
                Section(header: ScheduleLoadingHeader()) {
                    ForEach(0..<3, id: \.self) { _ in
                        ScheduleLoadingRow()
                    }
                }
                .textCase(nil)
                .id(sectionIndex)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
    }
}

private struct ScheduleLoadingHeader: View {
    var body: some View {
        SkeletonBlock(width: 120, height: 14, cornerRadius: 6)
            .padding(.vertical, 6)
    }
}

private struct ScheduleLoadingRow: View {
    var body: some View {
        HStack(spacing: 12) {
            SkeletonBlock(width: 75, height: 40, cornerRadius: 10)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonBlock(width: 170, height: 14, cornerRadius: 6)
                SkeletonBlock(width: 220, height: 12, cornerRadius: 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 6)
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
    ScheduleLoadingView()
}
