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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_UriFuFjiRHwcmgkTgoAgENezgcv", appUserID: "user_2vgHItHfCrbQXV3wpqUkKKOmfDL")
        
        return true
    }
}

class CustomerInfoManager: ObservableObject {
    @Published var customerInfo: CustomerInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasProAccess = false
    
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
            print(customerInfo)
            print(hasProAccess)
        } catch {
            errorMessage = error.localizedDescription
            print("Error fetching customer info: \(error)")
        }
        
        isLoading = false
    }
}
