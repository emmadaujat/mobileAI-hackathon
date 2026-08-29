import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    /// Optional italic "system" line shown under the main message.
    let statusLine: String?
    let isSpoken: Bool
}
