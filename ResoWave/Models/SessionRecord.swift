import Foundation

struct SessionRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var config: BreathConfig
    var duration: TimeInterval
    var score: Double
    var notes: String?
}
