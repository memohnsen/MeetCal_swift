//
//  RevenueCat.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/27/25.
//

import RevenueCat
import RevenueCatUI
import SwiftUI
import Combine
import Clerk

class CustomerInfoManager: ObservableObject {
    @Published var customerInfo: CustomerInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasProAccess = false

    @AppStorage("cached_pro_access") private var cachedProAccess: Bool = false
    @AppStorage("last_subscription_check") private var lastSubCheck: Double = 0

    private let cacheValidityDays: Double = 3
    private let secondsPerDay: Double = 86400

    init() {
        hasProAccess = cachedProAccess
    }

    private func isCacheValid() -> Bool {
        let currentTime = Date().timeIntervalSince1970
        let cacheAge = currentTime - lastSubCheck
        return cacheAge < (cacheValidityDays * secondsPerDay)
    }

    private func updateCache(hasAccess: Bool) {
        cachedProAccess = hasAccess
        hasProAccess = hasAccess
        lastSubCheck = Date().timeIntervalSince1970
    }

    @MainActor
    func loginToRevenueCat(clerkUserId: String) async {
        do {
            let (customerInfo, _) = try await Purchases.shared.logIn(clerkUserId)
            self.customerInfo = customerInfo
            let hasAccess = !customerInfo.entitlements.active.isEmpty
            updateCache(hasAccess: hasAccess)
        } catch {
            errorMessage = error.localizedDescription
            #if DEBUG
            print("Error logging in to RevenueCat: \(error)")
            #endif
        }
    }

    @MainActor
    func logoutFromRevenueCat() async {
        do {
            let customerInfo = try await Purchases.shared.logOut()
            self.customerInfo = customerInfo
            updateCache(hasAccess: false)
        } catch {
            errorMessage = error.localizedDescription
            #if DEBUG
            print("Error logging out from RevenueCat: \(error)")
            #endif
        }
    }

    @MainActor
    func fetchCustomerInfo() async {
        if isCacheValid() && !NetworkMonitor.shared.isConnected {
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let customerInfo = try await Purchases.shared.customerInfo()

            self.customerInfo = customerInfo

            let wasProUser = hasProAccess
            let currentHasAccess = !customerInfo.entitlements.active.isEmpty

            updateCache(hasAccess: currentHasAccess)

            if currentHasAccess && !wasProUser {
                AnalyticsManager.shared.trackSubscriptionStarted(tier: "pro")
            } else if !currentHasAccess && wasProUser {
                AnalyticsManager.shared.trackSubscriptionCancelled()
            }

            AnalyticsManager.shared.setSubscriptionStatus(hasProAccess ? "pro" : "free")
        } catch {
            if isCacheValid() {
                hasProAccess = cachedProAccess
            }
            errorMessage = error.localizedDescription
            #if DEBUG
            print("Error fetching customer info: \(error)")
            #endif
        }

        isLoading = false
    }
}
