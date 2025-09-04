import AVFoundation
import Foundation

class MicBreathDetector: ObservableObject {
    @Published var currentPhase: BreathPhase = .idle

    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private let bufferSize: AVAudioFrameCount = 1024
    private let sampleRate: Double = 44100
    private let smoothingFactor: Float = 0.8
    private var smoothedRMS: Float = 0
    private let highThreshold: Float = 0.1 // Adjust based on testing
    private let lowThreshold: Float = 0.05
    private var isActiveBreath = false
    private var lastPhaseChangeTime: TimeInterval = 0
    private var previousDerivative: Float = 0

    func startDetection() throws {
        audioEngine = AVAudioEngine()
        guard let engine = audioEngine else { return }

        inputNode = engine.inputNode
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)

        try engine.inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, time in
            self?.processBuffer(buffer)
        }

        try engine.start()
    }

    func stopDetection() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
    }

    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)

        // Compute RMS
        var sum: Float = 0
        for i in 0..<frameLength {
            sum += channelData[i] * channelData[i]
        }
        let rms = sqrt(sum / Float(frameLength))

        // Smooth RMS
        smoothedRMS = smoothingFactor * smoothedRMS + (1 - smoothingFactor) * rms

        // Hysteresis for active breath
        if smoothedRMS > highThreshold {
            isActiveBreath = true
        } else if smoothedRMS < lowThreshold {
            isActiveBreath = false
        }

        if isActiveBreath {
            // Compute short-time derivative (envelope velocity)
            let derivative = rms - previousDerivative // Simplified; use more frames in production
            previousDerivative = rms

            // Zero-crossing rate (ZCR)
            var zcr = 0
            for i in 1..<frameLength {
                if (channelData[i-1] > 0 && channelData[i] <= 0) || (channelData[i-1] < 0 && channelData[i] > 0) {
                    zcr += 1
                }
            }
            let normalizedZCR = Float(zcr) / Float(frameLength)

            // Classify inhale/exhale
            let isInhale = derivative > 0 && normalizedZCR > 0.1 // Thresholds need tuning

            currentPhase = isInhale ? .inhale : .exhale

            // Fallback to alternation if ambiguous
            let now = Date().timeIntervalSince1970
            if now - lastPhaseChangeTime > 2 { // If stuck too long
                currentPhase = (currentPhase == .inhale) ? .exhale : .inhale
            }

            if currentPhase != .idle {
                lastPhaseChangeTime = now
            }
        } else {
            currentPhase = .idle
        }
    }
}
