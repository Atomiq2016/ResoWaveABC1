import SwiftUI
import StoreKit

@main
struct ResoWaveApp: App {
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(purchaseManager)
                .task {
                    await purchaseManager.loadProducts()
                    await purchaseManager.updateSubscriptionStatus()
                }
        }
    }
}
