import AVFoundation

/// Calls the ElevenLabs text-to-speech API and plays back the returned audio.
/// See https://elevenlabs.io/docs/api-reference/text-to-speech for details.
final class ElevenLabsTextToSpeechService: NSObject, TextToSpeechServicing {
    private var player: AVAudioPlayer?
    private let session = URLSession(configuration: .default)
    private let apiKeyProvider: () -> String?
    private let voiceID: String
    private let fallback = SystemTextToSpeechService()

    /// - Parameters:
    ///   - apiKeyProvider: closure returning the current API key, so a key
    ///     typed into Settings mid-demo is picked up immediately without
    ///     rebuilding the app.
    ///   - voiceID: an ElevenLabs voice ID. "21m00Tcm4TlvDq8ikWAM" is the
    ///     default "Rachel" voice — swap for whichever voice you pick in the
    ///     ElevenLabs dashboard.
    init(apiKeyProvider: @escaping () -> String?, voiceID: String = "21m00Tcm4TlvDq8ikWAM") {
        self.apiKeyProvider = apiKeyProvider
        self.voiceID = voiceID
    }

    func speak(_ text: String) {
        guard let apiKey = apiKeyProvider(), !apiKey.isEmpty else {
            print("[ElevenLabs] No API key set — falling back to the built-in voice.")
            fallback.speak(text)
            return
        }

        guard let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceID)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")

        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_multilingual_v2",
            "voice_settings": ["stability": 0.5, "similarity_boost": 0.75]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self, let data, error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("[ElevenLabs] TTS request failed (\(error?.localizedDescription ?? "bad response")) — falling back to the built-in voice.")
                DispatchQueue.main.async { self?.fallback.speak(text) }
                return
            }
            DispatchQueue.main.async {
                self.play(data: data)
            }
        }.resume()
    }

    private func play(data: Data) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(data: data)
            player?.play()
        } catch {
            print("[ElevenLabs] Playback failed: \(error)")
        }
    }

    func stop() {
        player?.stop()
        fallback.stop()
    }
}
