import SwiftUI

/// A single mock "app icon" on the simulated home screen. These are generic
/// SF Symbol tiles, not real app artwork, so the prototype doesn't depend on
/// (or infringe on) anyone else's icons.
struct AppTile: Identifiable, Equatable {
    let id: String
    let displayName: String
    let systemImage: String
    let tint: Color
    /// Short, plain-language description spoken when someone taps the icon
    /// once with Tap-to-Explain turned on.
    let explanation: String

    static let all: [AppTile] = [
        AppTile(id: "phone", displayName: "Phone", systemImage: "phone.fill", tint: .green,
                explanation: "This is Phone. Tap it to call someone in your contacts."),
        AppTile(id: "messages", displayName: "Messages", systemImage: "message.fill", tint: .green,
                explanation: "This is Messages. Tap it to read or send a text."),
        AppTile(id: "camera", displayName: "Camera", systemImage: "camera.fill", tint: .gray,
                explanation: "This is Camera. Tap it to take a photo."),
        AppTile(id: "photos", displayName: "Photos", systemImage: "photo.on.rectangle", tint: .pink,
                explanation: "This is Photos. Tap it to see pictures you've taken."),
        AppTile(id: "mail", displayName: "Mail", systemImage: "envelope.fill", tint: .blue,
                explanation: "This is Mail. Tap it to read your email."),
        AppTile(id: "weather", displayName: "Weather", systemImage: "cloud.sun.fill", tint: .cyan,
                explanation: "This is Weather. Tap it to see today's forecast."),
        AppTile(id: "music", displayName: "Music", systemImage: "music.note", tint: .red,
                explanation: "This is Music. Tap it to play a song."),
        AppTile(id: "maps", displayName: "Maps", systemImage: "map.fill", tint: .green,
                explanation: "This is Maps. Tap it to get directions somewhere."),
        AppTile(id: "ptv", displayName: "PTV", systemImage: "tram.fill", tint: .indigo,
                explanation: "This is PTV. Tap it to check train, tram and bus times in Melbourne."),
        AppTile(id: "health", displayName: "Health", systemImage: "heart.fill", tint: .red,
                explanation: "This is Health. Tap it to see your step count and health data."),
        AppTile(id: "settings", displayName: "Settings", systemImage: "gearshape.fill", tint: .gray,
                explanation: "This is Settings. Tap it to change how your phone works."),
        AppTile(id: "appstore", displayName: "App Store", systemImage: "bag.fill", tint: .blue,
                explanation: "This is the App Store. Tap it to download new apps.")
    ]
}
