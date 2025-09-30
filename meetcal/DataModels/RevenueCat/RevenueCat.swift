//
//  RevenueCat.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/27/25.
//

import RevenueCat
import RevenueCatUI
import SwiftUI
import UIKit
import Combine
import Clerk

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_UriFuFjiRHwcmgkTgoAgENezgcv")

        return true
    }
}

class CustomerInfoManager: ObservableObject {
    @Published var customerInfo: CustomerInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasProAccess = false

    @MainActor
    func loginToRevenueCat(clerkUserId: String) async {
        do {
            let (customerInfo, _) = try await Purchases.shared.logIn(clerkUserId)
            self.customerInfo = customerInfo
            hasProAccess = !customerInfo.entitlements.active.isEmpty
        } catch {
            errorMessage = error.localizedDescription
            print("Error logging in to RevenueCat: \(error)")
        }
    }

    @MainActor
    func logoutFromRevenueCat() async {
        do {
            let customerInfo = try await Purchases.shared.logOut()
            self.customerInfo = customerInfo
            hasProAccess = false
        } catch {
            errorMessage = error.localizedDescription
            print("Error logging out from RevenueCat: \(error)")
        }
    }

    @MainActor
    func fetchCustomerInfo() async {
        isLoading = true
        errorMessage = nil

        do {
            let customerInfo = try await Purchases.shared.customerInfo()

            self.customerInfo = customerInfo

            if !customerInfo.entitlements.active.isEmpty {
                hasProAccess = true
            } else {
                hasProAccess = false
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching customer info: \(error)")
        }

        isLoading = false
    }
}
