//
//  meetcalApp.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import SwiftUI
import SwiftData
import Clerk
import Combine
import FirebaseCore


@main
struct meetcalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var clerk = Clerk.shared
    @StateObject private var customerManager = CustomerInfoManager()

    @AppStorage("cached_user_id") private var cachedUserId: String = ""
    @AppStorage("cached_auth_valid") private var cachedAuthValid: Bool = false
    @AppStorage("last_auth_check") private var lastAuthCheck: Double = 0

    private let authCacheValidityDays: Double = 3
    private let secondsPerDay: Double = 86400

    private func isAuthCacheValid() -> Bool {
        let currentTime = Date().timeIntervalSince1970
        let cacheAge = currentTime - lastAuthCheck
        return cacheAge < (authCacheValidityDays * secondsPerDay)
    }

    private func updateAuthCache(userId: String?, isValid: Bool) {
        cachedUserId = userId ?? ""
        cachedAuthValid = isValid
        lastAuthCheck = Date().timeIntervalSince1970
    }

    var isUserAuthenticated: Bool {
        if let user = clerk.user {
            return true
        }
        return cachedAuthValid && isAuthCacheValid() && !cachedUserId.isEmpty
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            AdaptiveRecordEntity.self,
            AmericanRecordEntity.self,
            MeetDetailsEntity.self,
            MeetsEntity.self,
            NatRankingsEntity.self,
            QTEntity.self,
            RankingsEntity.self,
            ResultsEntity.self,
            SavedEntity.self,
            ScheduleEntity.self,
            SchedDetailsEntity.self,
            StandardsEntity.self,
            StartListEntity.self,
            WorldRecordsEntity.self,
            WSOEntity.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.clerk, clerk)
                    .environmentObject(customerManager)
                    .environment(\.isUserAuthenticated, isUserAuthenticated)
                    .task {
                        let clerkKey = Bundle.main.object(forInfoDictionaryKey: "CLERK_PUBLISHABLE_KEY") as! String
                        clerk.configure(publishableKey: clerkKey)
                        try? await clerk.load()

                        await syncRevenueCatWithClerk()
                    }
                    .onChange(of: clerk.user) { oldUser, newUser in
                        Task {
                            await syncRevenueCatWithClerk()
                        }

                        if let newUser = newUser, oldUser == nil {
                            updateAuthCache(userId: newUser.id, isValid: true)
                            AnalyticsManager.shared.identifyUser(userId: newUser.id)
                            AnalyticsManager.shared.trackUserSignedIn(method: "clerk")
                        } else if newUser == nil, oldUser != nil {
                            updateAuthCache(userId: nil, isValid: false)
                            AnalyticsManager.shared.trackUserSignedOut()
                        } else if let newUser = newUser {
                            updateAuthCache(userId: newUser.id, isValid: true)
                        }
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }

    @MainActor
    private func syncRevenueCatWithClerk() async {
        if let userId = clerk.user?.id {
            // User is signed in, log them into RevenueCat
            await customerManager.loginToRevenueCat(clerkUserId: userId)
        } else {
            // User is signed out, log them out of RevenueCat
            await customerManager.logoutFromRevenueCat()
        }
    }
}
