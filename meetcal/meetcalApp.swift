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

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
                    .task {
                        clerk.configure(publishableKey: "pk_live_Y2xlcmsubWVldGNhbC5hcHAk")
                        try? await clerk.load()
                        
                        // Sync RevenueCat with Clerk user after initial load
                        await syncRevenueCatWithClerk()
                    }
                    .onChange(of: clerk.user) { oldUser, newUser in
                        Task {
                            await syncRevenueCatWithClerk()
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
