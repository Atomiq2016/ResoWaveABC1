import UIKit

struct Haptics {
    static func playPhaseChange() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
