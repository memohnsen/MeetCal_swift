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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_UriFuFjiRHwcmgkTgoAgENezgcv", appUserID: "user_2vgHItHfCrbQXV3wpqUkKKOmfDL")
        
        return true
    }
}
