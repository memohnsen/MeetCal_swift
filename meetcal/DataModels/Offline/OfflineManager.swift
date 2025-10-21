//
//  OfflineManager.swift
//  meetcal
//
//  Manages offline data fetching strategy with smart caching
//

import Foundation
import SwiftData

@MainActor
class OfflineManager {
    static let shared = OfflineManager()

    var cacheValidityDuration: TimeInterval = 3600

    private init() {}

    // MARK: - Cache Strategy

    func isCacheFresh(lastSynced: Date?) -> Bool {
        guard let lastSynced = lastSynced else { return false }
        let elapsed = Date().timeIntervalSince(lastSynced)
        return elapsed < cacheValidityDuration
    }

    func shouldUseOfflineData(
        hasOfflineData: Bool,
        lastSynced: Date?,
        forceOffline: Bool = false
    ) -> Bool {
        if forceOffline {
            return hasOfflineData
        }

        if !NetworkMonitor.shared.isConnected {
            return hasOfflineData
        }

        if hasOfflineData && isCacheFresh(lastSynced: lastSynced) {
            return true
        }

        return false
    }

    // MARK: - Generic Fetch with Fallback

    func fetchWithFallback<T>(
        networkFetch: () async throws -> T,
        offlineFetch: () throws -> T,
        hasOfflineData: Bool,
        lastSynced: Date?
    ) async throws -> T {
        if shouldUseOfflineData(
            hasOfflineData: hasOfflineData,
            lastSynced: lastSynced
        ) {
            return try offlineFetch()
        }

        do {
            return try await networkFetch()
        } catch {
            if hasOfflineData {
                return try offlineFetch()
            } else {
                throw error
            }
        }
    }

    // MARK: - Error Classification

    enum FetchError: LocalizedError {
        case networkUnavailable
        case noOfflineDataAvailable
        case offlineDataCorrupted
        case supabaseError(Error)

        var errorDescription: String? {
            switch self {
            case .networkUnavailable:
                return "No network connection available"
            case .noOfflineDataAvailable:
                return "No offline data available. Please connect to internet and download data."
            case .offlineDataCorrupted:
                return "Offline data is corrupted. Please re-download."
            case .supabaseError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }

    func classifyError(_ error: Error) -> FetchError {
        if !NetworkMonitor.shared.isConnected {
            return .networkUnavailable
        }

        return .supabaseError(error)
    }
}

// MARK: - SwiftData Helpers

extension OfflineManager {
    func getLastSyncedDate<T: PersistentModel>(
        for entityType: T.Type,
        in context: ModelContext,
        predicate: Predicate<T>? = nil
    ) -> Date? {
        var descriptor = FetchDescriptor<T>()
        if let predicate = predicate {
            descriptor.predicate = predicate
        }
        descriptor.fetchLimit = 1

        guard let entities = try? context.fetch(descriptor),
              let firstEntity = entities.first else {
            return nil
        }

        return (firstEntity as? any LastSyncedProtocol)?.lastSynced
    }

    func hasOfflineData<T: PersistentModel>(
        for entityType: T.Type,
        in context: ModelContext,
        predicate: Predicate<T>? = nil
    ) -> Bool {
        var descriptor = FetchDescriptor<T>()
        if let predicate = predicate {
            descriptor.predicate = predicate
        }
        descriptor.fetchLimit = 1

        let results = try? context.fetch(descriptor)
        return !(results?.isEmpty ?? true)
    }
}

// MARK: - Protocol for Entities with lastSynced

protocol LastSyncedProtocol {
    var lastSynced: Date { get }
}

// Note: Entity conformances are declared in their respective entity files
// to avoid circular dependencies during SwiftData initialization
