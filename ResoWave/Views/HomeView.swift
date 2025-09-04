import SwiftUI

struct HomeView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingHistory = false
    @State private var startingSession = false
    private let dataStore = DataStore()

    var lastScore: Double? {
        dataStore.loadSessions().last?.score
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("ResoWave")
                    .font(.largeTitle.bold())

                if let score = lastScore {
                    Text("Last Score: \(score, specifier: "%.0f")")
                        .font(.title2)
                } else {
                    Text("No sessions yet")
                        .foregroundColor(.secondary)
                }

                Button("Start Session") {
                    startingSession = true
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)

                Button("History") {
                    showingHistory = true
                }
                .padding(.horizontal)

                Spacer()
            }
            .sheet(isPresented: $startingSession) {
                SessionView(isTeaser: !purchaseManager.isSubscribed)
                    .environmentObject(purchaseManager)
            }
            .sheet(isPresented: $showingHistory) {
                NavigationView {
                    HistoryView()
                }
            }
        }
    }
}
