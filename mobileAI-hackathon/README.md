# TapTalk

TapTalk is a voice-first iOS companion aimed at people who find smartphones harder to navigate than they "should" be — elderly users who never grew up with touchscreens, teenagers on their first iPhone, or anyone who finds a grid of icons overwhelming. Instead of a manual to read or a one-shot command executor like Siri, the idea is a voice that stays with you: you say what you're trying to do, it figures out the plan, and it walks you through it step by step until the task is actually done.

The version in this repo focuses that idea on one concrete task: planning a trip with PTV (Public Transport Victoria). You say something like "I need to get to Melbourne Central," TapTalk asks a follow-up question if it's missing your origin, then talks you through opening PTV's Journey Planner and filling it in, one screen at a time.

This README describes what's actually implemented and working today, separately from what's designed/scaffolded for a future phase — that distinction matters if you're picking this project back up, since a few of the more ambitious pieces from the original pitch (real screen-reading, tap-to-explain, stuck detection) are not present in the current codebase, for reasons explained below.

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

**Tap-to-Explain and stuck-detection don't exist in this codebase.** An earlier prototype of this idea ("TapGuide") had a mock home screen of app icons, a tap-anywhere-to-hear-what-it-does feature, and a detector that noticed three unresolved taps in a row and proactively offered help. That version was superseded when the project was reset to focus specifically on the PTV journey-planning flow, and its view files were removed — `AppIconTileView`, `AssistantBubbleView`, `HomeScreenView`, `StuckDetector`, and friends are gone. If those features matter for what you're presenting, they'd need to be rebuilt against the current architecture rather than restored.

**TapTalk only handles one kind of request.** It's scoped to "help me plan a PTV journey" — origin, destination, transport mode. It isn't a general "help me use any app" assistant yet; that's the direction described in What's Next, not something this build attempts.

**No test target is actually wired up.** `TapTalkTests/JourneyIntentTests.swift` and `KeywordFallbackBrainTests.swift` exist on disk with real test cases, but the Xcode project defines only the one app target — there's no XCTest target currently building or running them. They'd need a proper test target added in Xcode before `⌘U` does anything.

**Cosmetic leftovers from the pre-pivot name.** The app's display name and both system permission-prompt strings (microphone, speech recognition) are still auto-generated from build settings that say "TapGuide" rather than "TapTalk" — worth fixing in Xcode's target settings (Info tab / `INFOPLIST_KEY_*` build settings) before a real demo, since a user will see "TapGuide" in the OS's own permission dialog.

**Built on beta tooling.** This targets iOS 26.5 / Xcode 26.6, which were still beta during development, with Swift's newer "approachable concurrency" defaults enabled (every type is `@MainActor` by default unless marked otherwise). That default caused several real bugs during development — audio recording being forced onto the main actor from a real-time audio thread, in particular — which are fixed, but it's a sign this project is running ahead of stable tooling and may need re-testing against GA releases.

**No dark mode.** The app pins `.preferredColorScheme(.light)` deliberately, matching the current mockups.

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

### If Xcode starts showing errors that don't match the code

This project's source folders are set up as Xcode "file system synchronized groups" — files added or edited outside Xcode's own save (including anything edited by an AI assistant working directly on disk) can leave Xcode's cached understanding of the project stale, showing errors that don't reflect the actual code, or errors that come and go between builds. If that happens: quit Xcode completely, delete DerivedData for this project (`~/Library/Developer/Xcode/DerivedData/`, or Xcode → Settings → Locations → arrow next to Derived Data), then reopen and rebuild. A plain "Clean Build Folder" is not enough to clear this — it only clears compiled output, not Xcode's project-structure cache.

## What's next

- Replace the keyword fallback with real, more capable language understanding so TapTalk can handle open-ended requests rather than a scripted flow — and extend it beyond PTV journeys to a general "help me use any app" assistant.
- Finish wiring up real screen-reading: add an actual Broadcast Upload Extension target in Xcode, configure the App Group entitlement on both targets, and connect `TaskPlannerEngine` to `ReplayKitVisionGuidanceService` instead of the simulated walkthrough — testable only on a physical device.
- Confirm PTV's real deep-link scheme (or partner with PTV) so `PTVLauncher` can open the actual app instead of a guess.
- Decide whether Tap-to-Explain and stuck-detection from the earlier prototype are still part of the product vision; if so, rebuild them against the current architecture rather than the old one.
- A genuinely VoiceOver-compatible mode for blind and low-vision users, designed with accessibility consultants — the current design targets sighted users who are unfamiliar or overwhelmed, not screen-reader users.
- More languages, using ElevenLabs' multilingual voices.
- A real Home Screen widget + Shortcuts integration.
- Add a proper XCTest target so the existing test files actually run, and re-test against Xcode/iOS GA releases once 26 is out of beta.
- User testing with the people TapTalk is actually for: elderly users and people new to iPhone.
