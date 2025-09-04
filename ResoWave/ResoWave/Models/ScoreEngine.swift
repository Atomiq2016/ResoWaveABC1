import Foundation

class ScoreEngine {
    static func computeScore(expectedTimeline: [(TimeInterval, BreathPhase)], detectedPhases: [(TimeInterval, BreathPhase)], windowSize: TimeInterval = 5, step: TimeInterval = 0.5) -> Double {
        var scores: [Double] = []
        let tickInterval: TimeInterval = 0.1
        let numTicksPerWindow = Int(windowSize / tickInterval)

        for startIndex in stride(from: 0, to: expectedTimeline.count - numTicksPerWindow, by: Int(step / tickInterval)) {
            let endIndex = startIndex + numTicksPerWindow
            let expectedSlice = Array(expectedTimeline[startIndex..<endIndex])
            let detectedSlice = Array(detectedPhases[startIndex..<endIndex])

            let expectedVector = oneHotVector(from: expectedSlice)
            let detectedVector = oneHotVector(from: detectedSlice)

            let dotProduct = zip(expectedVector, detectedVector).reduce(0) { $0 + $1.0 * $1.1 }
            let normE = sqrt(expectedVector.reduce(0) { $0 + $1 * $1 })
            let normD = sqrt(detectedVector.reduce(0) { $0 + $1 * $1 })
            let cosineSim = dotProduct / (normE * normD + 1e-6)

            scores.append(100 * cosineSim)
        }

        let meanScore = scores.isEmpty ? 0 : scores.reduce(0, +) / Double(scores.count)

        // Penalties (placeholder)
        var penalties = 0.0

        return max(0, min(100, meanScore - penalties))
    }

    private static func oneHotVector(from timeline: [(TimeInterval, BreathPhase)]) -> [Double] {
        var vector: [Double] = []
        for (_, phase) in timeline {
            var oneHot = [0.0, 0.0, 0.0, 0.0]
            oneHot[phase.rawValue] = 1.0
            vector.append(contentsOf: oneHot)
        }
        return vector
    }
}
