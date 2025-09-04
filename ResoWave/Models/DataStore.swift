import Foundation

class DataStore {
    private let fileName = "sessions.json"
    private let maxSessions = 100

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func saveSessions(_ sessions: [SessionRecord]) {
        let limitedSessions = Array(sessions.suffix(maxSessions))
        do {
            let data = try JSONEncoder().encode(limitedSessions)
            let fileURL = documentsURL.appendingPathComponent(fileName)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save sessions: \(error)")
        }
    }

    func loadSessions() -> [SessionRecord] {
        do {
            let fileURL = documentsURL.appendingPathComponent(fileName)
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([SessionRecord].self, from: data)
        } catch {
            print("Failed to load sessions: \(error)")
            return []
        }
    }
}
