import Foundation

/// Anything that can turn text into audible speech implements this. Lets us
/// swap between Apple's free on-device voice and ElevenLabs without touching
/// any view code.
protocol TextToSpeechServicing {
    func speak(_ text: String)
    func stop()
}
