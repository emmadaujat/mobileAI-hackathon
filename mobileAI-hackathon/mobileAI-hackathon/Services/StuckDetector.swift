import Foundation

/// Watches taps that don't lead anywhere useful and flags when someone looks
/// stuck, so the assistant can proactively offer help — the "tap 3+ times"
/// behaviour from the brief.
final class StuckDetector {
    private var tapTimestamps: [Date] = []
    private let threshold: Int
    private let window: TimeInterval
    private var cooldownUntil: Date = .distantPast

    init(threshold: Int = 3, window: TimeInterval = 8) {
        self.threshold = threshold
        self.window = window
    }

    /// Call every time the user taps something that *didn't* resolve their
    /// request (e.g. randomly tapping icons instead of using the assistant).
    /// Returns true the moment the threshold is crossed and we're not already
    /// in a cooldown period (so it doesn't nag repeatedly).
    @discardableResult
    func registerUnresolvedTap() -> Bool {
        let now = Date()
        tapTimestamps.append(now)
        tapTimestamps.removeAll { now.timeIntervalSince($0) > window }

        guard now > cooldownUntil, tapTimestamps.count >= threshold else { return false }

        cooldownUntil = now.addingTimeInterval(window * 2)
        tapTimestamps.removeAll()
        return true
    }

    /// Call when the user successfully gets help (e.g. an intent matched) so
    /// we don't fire again for taps that already led somewhere useful.
    func reset() {
        tapTimestamps.removeAll()
    }
}
