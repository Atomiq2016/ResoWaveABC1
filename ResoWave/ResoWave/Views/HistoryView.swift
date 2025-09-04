import SwiftUI

struct HistoryView: View {
    private let dataStore = DataStore()

    var sessions: [SessionRecord] {
        dataStore.loadSessions().reversed()
    }

    var body: some View {
        List(sessions) { session in
            HStack {
                Text(session.date, style: .date)
                Spacer()
                Text("Score: \(session.score, specifier: "%.0f")")
            }
        }
        .navigationTitle("History")
    }
}
