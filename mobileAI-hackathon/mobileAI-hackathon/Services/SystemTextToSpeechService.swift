import AVFoundation

/// Free, offline, works instantly with no API key — the default engine, and a
/// reliable fallback if ElevenLabs is unreachable (bad wifi at a demo venue,
/// no key entered yet, etc).
final class SystemTextToSpeechService: TextToSpeechServicing {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-AU") ?? AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}
