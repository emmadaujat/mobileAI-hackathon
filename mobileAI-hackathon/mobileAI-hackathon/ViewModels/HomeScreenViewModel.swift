import SwiftUI
import Combine

@MainActor
final class HomeScreenViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var highlightedTileID: String? = nil
    @Published var isListening: Bool = false

    /// The master accessibility toggle from the brief: turns Tap-to-Explain
    /// and the voice assistant on or off everywhere. Backed by UserDefaults
    /// manually (rather than @AppStorage) so it reliably notifies SwiftUI
    /// even though this lives on a plain ObservableObject, not a View.
    @Published var assistEnabled: Bool {
        didSet { UserDefaults.standard.set(assistEnabled, forKey: "assistEnabled") }
    }
    @Published var useElevenLabs: Bool {
        didSet { UserDefaults.standard.set(useElevenLabs, forKey: "useElevenLabs") }
    }
    @Published var elevenLabsAPIKey: String {
        didSet { UserDefaults.standard.set(elevenLabsAPIKey, forKey: "elevenLabsAPIKey") }
    }

    private lazy var systemVoice = SystemTextToSpeechService()
    private lazy var elevenLabsVoice = ElevenLabsTextToSpeechService(apiKeyProvider: { [weak self] in self?.elevenLabsAPIKey })
    private let speech = SpeechRecognitionService()
    private let stuckDetector = StuckDetector()

    private var currentVoice: TextToSpeechServicing {
        useElevenLabs ? elevenLabsVoice : systemVoice
    }

    init() {
        let defaults = UserDefaults.standard
        self.assistEnabled = defaults.object(forKey: "assistEnabled") as? Bool ?? true
        self.useElevenLabs = defaults.bool(forKey: "useElevenLabs")
        self.elevenLabsAPIKey = defaults.string(forKey: "elevenLabsAPIKey") ?? ""
    }

    func onAppear() {
        guard messages.isEmpty else { return }
        greet()
    }

    func greet() {
        say("Good morning. What are you trying to do today?", statusLine: nil)
    }

    func startListening() {
        guard assistEnabled else { return }
        speech.requestPermissions { [weak self] granted in
            guard let self, granted else { return }
            self.isListening = true
            self.speech.startListening { [weak self] transcript in
                self?.isListening = false
                self?.handle(userSaid: transcript)
            }
        }
    }

    func stopListening() {
        speech.stopListening()
        isListening = false
    }

    /// For the simulator (no working microphone) or a noisy demo room — types
    /// the phrase in as if it were spoken.
    func simulateUserSaid(_ text: String) {
        handle(userSaid: text)
    }

    private func handle(userSaid text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        messages.append(ChatMessage(text: "You said: \"\(text)\"", statusLine: nil, isSpoken: false))

        guard let intent = IntentLibrary.match(text: text) else {
            say("I'm not sure yet — I only know a few things in this demo. Try \"I'm catching the train\".", statusLine: nil)
            return
        }

        stuckDetector.reset()
        say(intent.spokenResponse, statusLine: intent.statusLine)

        // Small delay so the "searching…" status line is readable before the
        // icon highlights, mirroring the Figma flow (frame 2 -> frame 3).
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 900_000_000)
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                self?.highlightedTileID = intent.targetTileID
            }
        }
    }

    /// Called when someone taps a tile. `wasHighlighted` tells us whether
    /// this was the app the assistant already pointed at.
    func tileTapped(_ tile: AppTile, wasHighlighted: Bool) {
        if wasHighlighted {
            stuckDetector.reset()
            say("Opening \(tile.displayName)…", statusLine: "** Opening \(tile.displayName) (simulated for this demo)")
            return
        }

        guard assistEnabled else { return }
        say(tile.explanation, statusLine: nil)

        if stuckDetector.registerUnresolvedTap() {
            offerHelp()
        }
    }

    private func offerHelp() {
        say("Looks like you might be stuck. Want me to help you find something? Tap the microphone and tell me what you're trying to do.",
            statusLine: "** Detected 3+ taps with no match — offering help")
    }

    private func say(_ text: String, statusLine: String?) {
        messages.append(ChatMessage(text: text, statusLine: statusLine, isSpoken: true))
        if assistEnabled {
            currentVoice.speak(text)
        }
    }
}
