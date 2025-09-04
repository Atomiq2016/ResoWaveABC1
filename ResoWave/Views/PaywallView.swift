import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    let onPurchaseSuccess: () -> Void
    @State private var purchasing = false
    @State private var restoring = false

    var product: Product? {
        purchaseManager.products.first
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Unlock Full Sessions")
                .font(.title)

            Text("Subscribe for unlimited breathing sessions.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            if let price = product?.displayPrice {
                Text("Only \(price) per month")
            }

            Button(action: {
                Task {
                    purchasing = true
                    defer { purchasing = false }
                    if (try? await purchaseManager.purchase()) == true {
                        onPurchaseSuccess()
                    }
                }
            }) {
                Text(purchasing ? "Purchasing..." : "Subscribe")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(purchasing)

            Button(action: {
                Task {
                    restoring = true
                    await purchaseManager.restore()
                    restoring = false
                }
            }) {
                Text(restoring ? "Restoring..." : "Restore Purchases")
            }
            .disabled(restoring)
        }
        .padding()
    }
}
