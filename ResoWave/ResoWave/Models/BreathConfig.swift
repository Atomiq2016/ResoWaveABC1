import Foundation

struct BreathConfig: Hashable, Codable {
    var inhale: TimeInterval
    var hold: TimeInterval
    var exhale: TimeInterval

    static let box = BreathConfig(inhale: 4, hold: 0, exhale: 4)
    static let relax = BreathConfig(inhale: 4, hold: 7, exhale: 8) // Nice-to-have second preset
}
