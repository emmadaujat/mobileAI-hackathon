
import Foundation

enum APIKeys {
    /// Reads from `Secrets.elevenLabsAPIKey` when that git-ignored file
    /// exists locally, otherwise falls back to an empty string (which makes
    /// `hasElevenLabsKey` false and routes speech-to-text to the on-device
    /// Apple fallback instead of crashing or failing outright).
    static let elevenLabsAPIKey: String = Secrets.elevenLabsAPIKey

    static var hasElevenLabsKey: Bool {
        !elevenLabsAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
