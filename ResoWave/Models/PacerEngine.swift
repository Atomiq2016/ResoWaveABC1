import Foundation

enum BreathPhase: Int, Codable {
    case idle = 0
    case inhale = 1
    case hold = 2
    case exhale = 3
}

class PacerEngine: ObservableObject {
    let config: BreathConfig
    let sessionDuration: TimeInterval
    private let tickInterval: TimeInterval = 0.1 // 100ms

    init(config: BreathConfig, sessionDuration: TimeInterval) {
        self.config = config
        self.sessionDuration = sessionDuration
    }

    func generateExpectedTimeline() -> [(TimeInterval, BreathPhase)] {
        var timeline: [(TimeInterval, BreathPhase)] = []
        let cycleDuration = config.inhale + config.hold + config.exhale
        var currentTime: TimeInterval = 0

        while currentTime < sessionDuration {
            let cycleTime = currentTime.truncatingRemainder(dividingBy: cycleDuration)
            let phase: BreathPhase
            if cycleTime < config.inhale {
                phase = .inhale
            } else if cycleTime < config.inhale + config.hold {
                phase = .hold
            } else {
                phase = .exhale
            }
            timeline.append((currentTime, phase))
            currentTime += tickInterval
        }
        return timeline
    }
}
