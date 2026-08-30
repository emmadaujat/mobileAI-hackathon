//
//  TaskPlannerState.swift
//  TapTalk
//
//  The state machine driven by TaskPlannerEngine, following the branches
//  described in the Tap Talk User Flow doc:
//  extract intent -> (missing slot -> conversational clarification) OR
//  (all slots filled -> direct action: open PTV) -> guided walkthrough ->
//  results -> back to listening.
//

import Foundation

enum TaskPlannerState: Equatable {
    /// Orb idle, nothing happening yet (e.g. right after onboarding).
    case idle
    /// TapTalk is speaking a prompt/question/confirmation aloud.
    case speaking(String)
    /// Microphone is open, transcribing the user's speech.
    case listening
    /// Foundation Models is extracting intent / deciding next step.
    case thinking
    /// Transition screen while PTV is being opened.
    case openingApp
    /// Inside the (simulated) PTV walkthrough, at a specific step.
    case guiding(PTVSimStep)

    static func == (lhs: TaskPlannerState, rhs: TaskPlannerState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.listening, .listening), (.thinking, .thinking),
             (.openingApp, .openingApp):
            return true
        case let (.speaking(a), .speaking(b)):
            return a == b
        case let (.guiding(a), .guiding(b)):
            return a == b
        default:
            return false
        }
    }
}
