//
//  OfflineIndicator.swift
//  meetcal
//
//  Shows offline status and data freshness to users
//

import SwiftUI

struct OfflineIndicator: View {
    @StateObject private var networkMonitor = NetworkMonitor.shared
    let isUsingOfflineData: Bool
    let lastSynced: Date?

    var body: some View {
        if !networkMonitor.isConnected || isUsingOfflineData {
            HStack(spacing: 4) {
                Image(systemName: networkMonitor.isConnected ? "checkmark.icloud" : "wifi.slash")
                    .font(.caption)

                Text(statusText)
                    .font(.caption)
            }
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.1))
            .cornerRadius(8)
        }
    }

    private var statusText: String {
        if !networkMonitor.isConnected {
            return "Offline Mode"
        } else if isUsingOfflineData {
            if let lastSynced = lastSynced {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .abbreviated
                let relativeTime = formatter.localizedString(for: lastSynced, relativeTo: Date())
                return "Cached \(relativeTime)"
            }
            return "Using Cache"
        }
        return ""
    }

    private var statusColor: Color {
        if !networkMonitor.isConnected {
            return .orange
        } else if isUsingOfflineData {
            return .blue
        }
        return .secondary
    }
}

extension View {
    func offlineIndicator(isUsingOfflineData: Bool, lastSynced: Date? = nil) -> some View {
        self.modifier(OfflineIndicatorModifier(isUsingOfflineData: isUsingOfflineData, lastSynced: lastSynced))
    }
}

struct OfflineIndicatorModifier: ViewModifier {
    let isUsingOfflineData: Bool
    let lastSynced: Date?

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            OfflineIndicator(isUsingOfflineData: isUsingOfflineData, lastSynced: lastSynced)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

            content
        }
    }
}

struct OfflineBadge: View {
    @StateObject private var networkMonitor = NetworkMonitor.shared
    let isUsingOfflineData: Bool

    var body: some View {
        if !networkMonitor.isConnected || isUsingOfflineData {
            HStack(spacing: 2) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.caption2)
                Text("Offline")
                    .font(.caption2)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(networkMonitor.isConnected ? Color.blue : Color.orange)
            .cornerRadius(4)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        OfflineIndicator(
            isUsingOfflineData: false,
            lastSynced: nil
        )

        OfflineIndicator(
            isUsingOfflineData: true,
            lastSynced: Date().addingTimeInterval(-3600)
        )

        OfflineBadge(isUsingOfflineData: true)
    }
    .padding()
}
