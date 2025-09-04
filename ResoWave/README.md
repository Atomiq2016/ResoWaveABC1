# ResoWave (Xcode Project)

Open `ResoWave/ResoWave.xcodeproj` in Xcode 15+.

## Setup
- Select your Team in the target's **Signing & Capabilities** (Bundle ID: `com.example.ResoWave`).
- iOS Deployment Target: 16.0
- Supported platforms: iPhone + Simulator (Mac Catalyst disabled).
- Microphone usage is already set in `Info.plist`.

## StoreKit Local Testing
A `ResoWave.storekit` configuration is included with one product:
- `resowave.monthly` – Auto-renewable monthly subscription ($4.99)

To use it:
1. Edit the **ResoWave** scheme ➜ **Options** ➜ StoreKit Configuration File: select `ResoWave.storekit`.
2. Run on a simulator or device and use the StoreKit testing UI.

## Notes
- The pacer + mic detection are MVP-grade. Tune thresholds in `MicBreathDetector` on a real device.
- History saves to Documents as `sessions.json` (keeps up to 100 recent sessions).
- `PaywallView` uses StoreKit 2 APIs and will work with the StoreKit config or TestFlight.
