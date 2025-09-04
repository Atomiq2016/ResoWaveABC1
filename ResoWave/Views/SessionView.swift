import SwiftUI
import AVFoundation

struct SessionView: View {
    let isTeaser: Bool
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @State private var elapsed: TimeInterval = 0
    @State private var currentPhase: BreathPhase = .idle
    @State private var showingPaywall = false
    @State private var detectedPhases: [(TimeInterval, BreathPhase)] = []
    private let config = BreathConfig.box
    private let fullDuration: TimeInterval = 180 // 3 minutes
    private let teaserDuration: TimeInterval = 60
    private let pacer = PacerEngine(config: .box, sessionDuration: 180)
    private let detector = MicBreathDetector()
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    private let dataStore = DataStore()
    private var sessionDuration: TimeInterval { isTeaser ? teaserDuration : fullDuration }

    var body: some View {
        VStack(spacing: 20) {
            Text(currentPhaseDescription)
                .font(.largeTitle)

            Circle()
                .frame(width: 200, height: 200)
                .foregroundColor(phaseColor)
                .scaleEffect(scaleFactor)
                .animation(.easeInOut(duration: 0.1), value: elapsed)

            Text("Elapsed: \(elapsed, specifier: "%.1f")s")

            Button("End Session") {
                endSession()
            }
            .padding(.top, 12)
        }
        .padding()
        .onAppear { startSession() }
        .onDisappear { stopSession() }
        .onReceive(timer) { _ in tick() }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(onPurchaseSuccess: {
                showingPaywall = false
            })
            .environmentObject(purchaseManager)
        }
    }

    private func startSession() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                do {
                    try detector.startDetection()
                } catch {
                    print("Mic error: \(error)")
                }
            } else {
                print("Microphone permission not granted.")
            }
        }
    }

    private func stopSession() {
        detector.stopDetection()
        timer.upstream.connect().cancel()
    }

    private func tick() {
        elapsed += 0.1
        let timeline = pacer.generateExpectedTimeline()
        if !timeline.isEmpty {
            let idx = Int(elapsed / 0.1) % timeline.count
            currentPhase = timeline[idx].1
        }
        detectedPhases.append((elapsed, detector.currentPhase))
        Haptics.playPhaseChange()

        if elapsed >= sessionDuration {
            if isTeaser {
                showingPaywall = true
            } else {
                endSession()
            }
        }
    }

    private func endSession() {
        let expected = pacer.generateExpectedTimeline()
        let score = ScoreEngine.computeScore(expectedTimeline: expected, detectedPhases: detectedPhases)
        let record = SessionRecord(config: config, duration: elapsed, score: score)
        var sessions = dataStore.loadSessions()
        sessions.append(record)
        dataStore.saveSessions(sessions)
        dismiss()
    }

    private var currentPhaseDescription: String {
        switch currentPhase {
        case .inhale: return "Inhale"
        case .hold: return "Hold"
        case .exhale: return "Exhale"
        case .idle: return "Idle"
        }
    }

    private var phaseColor: Color {
        switch currentPhase {
        case .inhale: return .green
        case .hold: return .yellow
        case .exhale: return .blue
        case .idle: return .gray
        }
    }

    private var scaleFactor: CGFloat {
        switch currentPhase {
        case .inhale: return 1.2
        case .exhale: return 0.8
        default: return 1.0
        }
    }
}
