//
//  RebyeApp.swift
//  Rebye
//
//  Created by Chau Nguyen on 7/1/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn
import Stripe

@main
struct RebyeApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userAuth: UserAuthModel = UserAuthModel.shared
    
    init() {
        STPAPIClient.shared.publishableKey = "pk_test_51LNoueEnfC2xSvf1BMYMcfoMUZGeC5IyWa3HkPxWRELnCVhLaTsT2P8IEAnCPkEFVy8WdvgsE2aht9dn8Hec5vPa00sq1X5239"
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userAuth)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Initialize firebase
        FirebaseApp.configure()
//        STPAPIClient.shared.publishableKey = "pk_test_51LNoueEnfC2xSvf1BMYMcfoMUZGeC5IyWa3HkPxWRELnCVhLaTsT2P8IEAnCPkEFVy8WdvgsE2aht9dn8Hec5vPa00sq1X5239"
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .black
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

