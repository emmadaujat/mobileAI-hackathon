# TapGuide

An accessibility layer for people who find the iPhone's icons, jargon and small text hard to navigate — elderly users, people who are new to smartphones, or anyone who just wants a plain-language voice to talk them through it.

Turn a toggle on and: tap any icon once and it speaks what it does in plain English; tell it out loud what you're trying to do ("I'm catching the train") and it finds and highlights the right app; tap around lost for three taps in a row and it notices and offers to help.

This is a hackathon prototype. It is **not** a replacement for VoiceOver and is currently **English only** — see Limitations below.

## How this maps to the Figma flow

1. **Frame 1** — on launch, the assistant bubble greets you: *"Good morning. What are you trying to do today?"* (spoken aloud).
2. **Frame 2** — you tap the mic and say what you're trying to do (or type it in Settings → "Try it without a microphone" for a quiet room / the simulator). The bubble replies and shows an italic status line, e.g. `** Searching phone for PTV app…`.
3. **Frame 3** — the matching app icon highlights with a glow. Tapping it "opens" it (simulated — see Limitations).

Off to the side, every tap that *doesn't* resolve into a match is tracked; three of those in ~8 seconds triggers the assistant to proactively offer help, unprompted.

## Project structure

```
mobileAI-hackathon/                    Xcode project + workspace (real .xcodeproj, not generated)
  mobileAI-hackathon/                  Xcode's synchronized source root — anything dropped in
                                        here is picked up automatically, no manual file refs needed
    App/            App entry point (TapGuideApp)
    Models/         AppTile (icon grid), Intent (keyword → app + response), ChatMessage
    Services/       TextToSpeechServicing protocol + System (AVSpeechSynthesizer) and
                     ElevenLabs implementations, on-device SpeechRecognitionService (STT),
                     StuckDetector (the "3 taps" logic)
    ViewModels/      HomeScreenViewModel — all the state and orchestration
    Views/           HomeScreenView (mock home screen), AppIconTileView, AssistantBubbleView,
                     SettingsView (the accessibility toggle + ElevenLabs key)
    Assets.xcassets
```

## Setup

Nothing to generate — it's a real `.xcodeproj`. Just:

```bash
open mobileAI-hackathon/mobileAI-hackathon.xcodeproj
```

Signing is already set to an Apple Development team, so it should build straight to the simulator or a device. Build target is iOS 26+ (matches the project's current deployment target).

## Adding your ElevenLabs key

No rebuild needed — run the app, tap the gear icon → **Settings**, turn on "Use ElevenLabs voice", and paste your key from [elevenlabs.io](https://elevenlabs.io). Leave it off (or the key blank) and it falls back automatically to the free, offline, built-in iPhone voice — handy if venue wifi is unreliable during a demo.

`ElevenLabsTextToSpeechService.swift` defaults to the "Rachel" voice ID; swap `voiceID` for whichever voice you've picked in the ElevenLabs dashboard.

## Demo script

1. Launch → hear the greeting.
2. Settings → "Try it without a microphone" → type `I'm catching the train` → Send. Watch the PTV icon highlight; hear the response.
3. Tap the (now highlighted) PTV icon → hear "Opening PTV…".
4. To show off Tap-to-Explain: tap any *other* icon once → it speaks a plain-language description instead of opening.
5. To show off stuck-detection: rapidly tap 3 different icons that don't match anything → the assistant interrupts unprompted to offer help.
6. Real mic flow: tap the microphone button in the bubble, say a phrase out loud (needs mic + speech recognition permission, and a physical device or a simulator with a working audio input configured).

## Limitations (deliberate scope cuts for a prototype, not oversights)

- **Not a screen reader.** This is a plain-language companion for sighted users who are unfamiliar or overwhelmed, not a replacement for VoiceOver — a blind user's needs are much deeper than this covers, and we've said so rather than overclaiming.
- **English only.** No localisation yet.
- **Apps don't actually open.** iOS deliberately does not let third-party apps hook into the real system home screen or detect taps in other apps — that's a sandboxing rule, not a bug. "Opening PTV…" is simulated inside this app's own mock home screen, which is what the Figma frames show. A real production version would instead be a genuine home-screen *widget* + deep links (`ptv://` if PTV ever ships one, or Shortcuts) rather than trying to replace the home screen.
- **Intent matching is keyword-based**, not a real NLU/LLM — fine for a demo script, not for open-ended requests.

## Prize alignment

- **Most impactful social good** — directly targets a real, common problem (elderly relatives and phone-unfamiliar people needing plain-language, in-the-moment help) with a working, testable interaction, not just a mockup.
- **Best beginner hack** — small, readable file-per-responsibility structure (a protocol + two interchangeable TTS backends, a plain keyword matcher, a simple tap-timestamp stuck-detector) that's easy to explain end-to-end in a 3-minute demo.
- **People's choice** — the highlight/glow animation and speech bubble are built to closely match the Figma mockup, so the live demo looks like the pitch deck.
- **Best project built with ElevenLabs** — ElevenLabs is a first-class, swappable voice engine (`ElevenLabsTextToSpeechService`), with a graceful same-app fallback so a demo never goes silent even if the key or wifi fails.

## Next steps after the hackathon

- Real on-device or server LLM for intent understanding instead of keywords.
- Investigate a genuine VoiceOver-compatible mode for blind/low-vision users, built with accessibility consultants rather than assumed.
- Additional languages via ElevenLabs' multilingual models + localized `Intent` scripts.
- Home Screen widget + Shortcuts integration so "opening an app" can become real deep-linking where the target app supports it.
