import Speech
import AVFoundation
import Combine

/// Converts the user's spoken request into text using Apple's on-device
/// Speech framework. Free, works without ElevenLabs, no API key required.
final class SpeechRecognitionService: ObservableObject {
    @Published var transcript: String = ""
    @Published var isListening: Bool = false
    @Published var permissionDenied: Bool = false

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-AU")) ?? SFSpeechRecognizer(locale: .current)
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { speechStatus in
            AVAudioApplication.requestRecordPermission { micGranted in
                DispatchQueue.main.async {
                    let granted = speechStatus == .authorized && micGranted
                    self.permissionDenied = !granted
                    completion(granted)
                }
            }
        }
    }

    func startListening(onFinalResult: @escaping (String) -> Void) {
        guard let recognizer, recognizer.isAvailable else { return }
        stopListening()

        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
        isListening = true

        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            // Speech's callback can arrive on a background queue — hop to
            // main explicitly before touching @Published state or calling
            // back into the (MainActor-isolated) view model.
            DispatchQueue.main.async {
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                    if result.isFinal {
                        onFinalResult(self.transcript)
                        self.stopListening()
                    }
                }
                if error != nil {
                    self.stopListening()
                }
            }
        }
    }

    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        task = nil
        request = nil
        isListening = false
    }
}
