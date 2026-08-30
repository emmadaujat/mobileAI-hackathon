# TapTalk
TapTalk is a conversational, voice-first iOS companion that guides you through using your phone - not just a command executor like Siri, but a guide that stays with you until the task is actually done. It is aimed at people who find smartphones harder to navigate than they "should" be — elderly users who never grew up with touchscreens, teenagers on their first iPhone, or anyone who finds a grid of icons overwhelming. Instead of a manual to read or a one-shot command executor like Siri, the idea is a voice that stays with you: you say what you're trying to do, it figures out the plan, and it walks you through it step by step until the task is actually done.

Tell it your goal out loud - say something like "I'm catching the train" and TapTalk listens, works out what you're trying to do, and opens the right app for you.
It stays with you, screen by screen - once you're in the app, TapTalk watches what's on your screen and speaks the next step out loud (e.g. "Tap Journey Planner"), then waits for the next screen and does it again, a real loop, not a one-shot answer.
Tap-to-Explain - tap any app icon and TapTalk speaks a short, plain-language explanation of what it does.
Stuck detection - tap around without success three times in a row, and TapTalk notices and proactively offers help, without waiting to be asked. Every response is spoken aloud, so it's genuinely a voice guiding you, not just text on screen. 

The version in this repo focuses that idea on one concrete task: planning a trip with PTV (Public Transport Victoria). You say something like "I need to get to Melbourne Central," TapTalk asks a follow-up question if it's missing your origin, then talks you through opening PTV's Journey Planner and filling it in, one screen at a time.

## What works today

The full conversational loop runs end-to-end, in the Simulator or on a physical device:

1. **Onboarding** — a short Welcome → Good morning → "let TapTalk see your screen?" permission flow.
2. **Listening** — TapTalk records your voice and transcribes it. It prefers ElevenLabs Scribe (once you add an API key — see Setup below) and automatically falls back to Apple's on-device speech recognizer if no key is configured or a request fails.
3. **Understanding** — your transcript is parsed into a structured intent (destination / origin / transport mode) by Apple's on-device Foundation Models framework, when the device/Simulator supports it. Where Foundation Models isn't available, or a generation call fails at runtime, a small deterministic keyword parser steps in instead, so the app is demoable on any hardware.
4. **Asking a follow-up** — if you only gave a destination ("I'm heading to Flinders Street"), TapTalk asks one natural follow-up question for whatever's missing, rather than guessing.
5. **Confirming, then guiding** — once it has enough to act, TapTalk speaks a short confirmation line, then hands you into a simulated PTV Journey Planner screen built inside TapTalk itself. Each step highlights the thing you need to tap (the Journey Planner tile, the From field, the destination search, Search), TapTalk narrates that step aloud, and tapping the highlighted element advances to the next one — a real multi-turn loop, not a single response.
6. Text-to-speech throughout is Apple's `AVSpeechSynthesizer`, and the audio session is configured once per conversation (rather than being switched on and off every turn) so playback and recording can alternate reliably without repeatedly tearing down the audio hardware route.

## Tech stack

- **SwiftUI**, targeting iOS 26, built in Xcode 26.6.
- **ElevenLabs Scribe** (REST API) for speech-to-text, with **`SFSpeechRecognizer`** (on-device/Apple-server Speech framework) as an automatic fallback.
- **`AVAudioEngine`** + **`AVAudioSession`** for microphone capture, amplitude-based silence detection, and a single persistent `.playAndRecord` session shared across the whole conversation.
- **Apple's `FoundationModels`** framework for on-device intent extraction and natural-language follow-up/confirmation lines, using `@Generable`/`@Guide` to get structured output directly from the model.
- A **deterministic keyword-based parser** (`KeywordFallbackBrain`) as the fallback brain when Foundation Models isn't available or fails at generation time.
- **`AVSpeechSynthesizer`** for text-to-speech output.
- **Combine** / `ObservableObject` for state management (`TaskPlannerEngine` is the central state machine driving the whole conversation).
- **Vision** (`VNRecognizeTextRequest`) and **ReplayKit** (`RPBroadcastSampleHandler`) — written for real on-screen OCR guidance, but not currently wired into the app; see Limitations.

## Current limitations

This section is the honest map between the original pitch and what's actually in this codebase right now.

**The "PTV screen" you're guided through is a mockup, not the real PTV app.** TapTalk never actually opens PTV or reads its real screen today. `Views/PTVSim/` is a hand-built recreation of PTV's Journey Planner screens inside TapTalk's own UI, and `PTVSimulationViewModel` advances through it purely from on-screen taps you make inside TapTalk — there's no computer vision involved in the working demo.

**Real screen-watching is written but not wired up, and can't run as-is.** `Services/ScreenGuidance/ReplayKitVisionGuidanceService.swift` contains real, non-trivial Vision OCR code (it reads frames and searches for on-screen text matches), and `TapTalkBroadcastExtension/SampleHandler.swift` contains a real ReplayKit broadcast handler that writes captured frames to a shared App Group container for it to read. Neither is reachable from the app today: the Xcode project currently defines a single target (the main "TapTalk" app) — there is no actual Broadcast Upload Extension target configured, no App Group entitlement set up on either side, and nothing in `TaskPlannerEngine` calls into `ScreenGuidanceService` (it only ever uses the simulated walkthrough). Wiring this up means adding a real extension target in Xcode, adding the App Group capability to both targets, and testing on a physical device — the Simulator can't run a system broadcast at all.

**Opening the real PTV app is unverified and unused.** `Services/AppLauncher/PTVLauncher.swift` implements a genuine Universal Link → custom URL scheme → App Store fallback chain, but its URLs are best guesses (PTV's real deep-link scheme isn't publicly documented) and nothing in the app currently calls it.

**TapTalk only handles one kind of request.** It's scoped to "help me plan a PTV journey" — origin, destination, transport mode. It isn't a general "help me use any app" assistant yet; that's the direction described in What's Next, not something this build attempts.

**No test target is actually wired up.** `TapTalkTests/JourneyIntentTests.swift` and `KeywordFallbackBrainTests.swift` exist on disk with real test cases, but the Xcode project defines only the one app target — there's no XCTest target currently building or running them. They'd need a proper test target added in Xcode before `⌘U` does anything.

**Cosmetic leftovers from the pre-pivot name.** The app's display name and both system permission-prompt strings (microphone, speech recognition) are still auto-generated from build settings that say "TapGuide" rather than "TapTalk" — worth fixing in Xcode's target settings (Info tab / `INFOPLIST_KEY_*` build settings) before a real demo, since a user will see "TapGuide" in the OS's own permission dialog.

## Project structure

```
mobileAI-hackathon/                    Xcode project + workspace (a real .xcodeproj, not generated)
  TapTalk.xcodeproj/
  TapTalk/                             Main app target (the only target that currently builds)
    App/                               Entry point, root router, AppCoordinator
    Models/                            JourneyIntent, PTVSimStep, TaskPlannerState, etc.
    Services/
      Speech/                          ElevenLabs Scribe STT, Apple Speech fallback, TTS,
                                        shared persistent AVAudioSession coordinator
      Intelligence/                    Foundation Models brain + keyword fallback brain
      AppLauncher/                     PTVLauncher — written, not currently called
      ScreenGuidance/                  Real screen-reading Vision/ReplayKit code — written, not wired up
      Permissions/                     Mic + speech recognition permission requests
      Shared/                          APIKeys.swift (safe to commit) + Secrets.swift (your real
                                        key, git-ignored — see Setup)
    ViewModels/                        TaskPlannerEngine (the conversation state machine),
                                        PTVSimulationViewModel
    Views/
      Onboarding/                      Welcome, Good morning, screen-permission prompt
      Voice/                           The listening/speaking screens, opening-PTV transition
      PTVSim/                          The simulated PTV walkthrough screens
      Components/                      Design system + shared UI
  TapTalkBroadcastExtension/           Phase 2 broadcast extension source — not a real Xcode target yet
  Shared/                              IPC bridge code shared between the app and the (future) extension
  TapTalkTests/                        Test source files — not currently attached to a test target
```

## Setup

1. Clone/open the project: `open TapTalk.xcodeproj`.
2. In Xcode, select the TapTalk target → **Signing & Capabilities** → set your own development team.
3. Add your ElevenLabs key: copy `TapTalk/Services/Shared/Secrets.swift.example` to `Secrets.swift` in the same folder, and paste your real key in. `Secrets.swift` is listed in `.gitignore` at the repo root and is never committed — that's deliberate, so pushing this repo never leaks a real key. Without a key, TapTalk automatically uses the on-device Apple Speech recognizer instead; the app is fully usable either way.
4. Build & run the `TapTalk` scheme on a Simulator or a physical device (iOS 26+). A physical device is required to test real microphone input reliably and to eventually exercise anything under `ScreenGuidance`/`TapTalkBroadcastExtension`.

## What's next

- Replace the keyword fallback with real, more capable language understanding so TapTalk can handle open-ended requests rather than a scripted flow — and extend it beyond PTV journeys to a general "help me use any app" assistant.
- Finish wiring up real screen-reading: add an actual Broadcast Upload Extension target in Xcode, configure the App Group entitlement on both targets, and connect `TaskPlannerEngine` to `ReplayKitVisionGuidanceService` instead of the simulated walkthrough — testable only on a physical device.
- Confirm PTV's real deep-link scheme (or partner with PTV) so `PTVLauncher` can open the actual app instead of a guess.
- A genuinely VoiceOver-compatible mode for blind and low-vision users, designed with accessibility consultants — the current design targets sighted users who are unfamiliar or overwhelmed, not screen-reader users.
- More languages, using ElevenLabs' multilingual voices.
- A real Home Screen widget + Shortcuts integration.
- Add a proper XCTest target so the existing test files actually run, and re-test against Xcode/iOS GA releases once 26 is out of beta.
- User testing with the people TapTalk is actually for: elderly users and people new to iPhone.
