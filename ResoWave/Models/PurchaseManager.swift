import StoreKit
import Foundation

@MainActor
class PurchaseManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isSubscribed: Bool = false
    private let productID = "resowave.monthly"

    func loadProducts() async {
        do {
            products = try await Product.products(for: [productID])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase() async throws -> Bool {
        guard let product = products.first else { return false }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                await updateSubscriptionStatus()
                return true
            }
        default:
            break
        }
        return false
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            print("Restore failed: \(error)")
        }
    }

    func updateSubscriptionStatus() async {
        var subscribed = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == productID  {
                    subscribed = true
                }
            }
        }
        isSubscribed = subscribed
    }
}
