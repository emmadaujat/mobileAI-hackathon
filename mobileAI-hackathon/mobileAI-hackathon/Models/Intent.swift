import Foundation

/// A scripted "what are you trying to do" scenario the assistant can recognise.
struct Intent: Identifiable {
    let id = UUID()
    let keywords: [String]
    let targetTileID: String
    /// Spoken out loud in the bubble.
    let spokenResponse: String
    /// Shown in italics as a quiet "what the AI is doing" status line — not
    /// spoken, mirrors the "** Searching phone for PTV app...." line in the
    /// Figma flow.
    let statusLine: String
}

enum IntentLibrary {
    static let all: [Intent] = [
        Intent(keywords: ["train", "tram", "bus", "commute", "ptv", "public transport"],
               targetTileID: "ptv",
               spokenResponse: "Catching the train? No worries — living in Melbourne, you'll want the PTV app.",
               statusLine: "** Searching phone for PTV app…"),
        Intent(keywords: ["call", "phone", "ring", "speak to"],
               targetTileID: "phone",
               spokenResponse: "Sure — let's make a call. I've found the Phone app for you.",
               statusLine: "** Searching phone for Phone app…"),
        Intent(keywords: ["text", "message", "sms"],
               targetTileID: "messages",
               spokenResponse: "Got it — let's send a message. Here's Messages.",
               statusLine: "** Searching phone for Messages app…"),
        Intent(keywords: ["photo", "picture", "selfie"],
               targetTileID: "camera",
               spokenResponse: "Let's take a photo — here's your Camera.",
               statusLine: "** Searching phone for Camera app…"),
        Intent(keywords: ["weather", "rain", "forecast", "cold", "hot"],
               targetTileID: "weather",
               spokenResponse: "Checking the weather — here's the Weather app.",
               statusLine: "** Searching phone for Weather app…"),
        Intent(keywords: ["music", "song", "listen"],
               targetTileID: "music",
               spokenResponse: "Time for some music — here's the Music app.",
               statusLine: "** Searching phone for Music app…"),
        Intent(keywords: ["direction", "map", "navigate", "route"],
               targetTileID: "maps",
               spokenResponse: "Let's get you there — here's Maps.",
               statusLine: "** Searching phone for Maps app…")
    ]

    /// Very small keyword matcher — good enough for a scripted hackathon demo.
    /// Swap this out for a proper on-device classifier or an LLM call later.
    static func match(text: String) -> Intent? {
        let lowered = text.lowercased()
        return all.first { intent in
            intent.keywords.contains { lowered.contains($0) }
        }
    }
}
