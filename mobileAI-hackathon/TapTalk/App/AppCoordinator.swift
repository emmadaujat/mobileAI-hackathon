//
//  AppCoordinator.swift
//  TapTalk
//
//  Top-level navigation between onboarding and the live voice session.
//  Kept deliberately simple (one enum, one published property) since the
//  app has a linear onboarding flow rather than a deep navigation stack.
//

import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var route: AppRoute = .welcome
    @Published var userName: String = "Emma"

    /// Set once the user responds to the screen-recording / guidance
    /// permission prompt. TapTalk still functions without it in v1 (the
    /// simulated PTV walkthrough doesn't need real screen capture), but the
    /// choice is remembered so we can react to it once Phase 2 ships.
    @Published var didGrantScreenGuidancePermission = false

    func advanceFromWelcome() {
        route = .goodMorning
    }

    func advanceFromGoodMorning() {
        route = .screenPermission
    }

    func resolveScreenPermission(granted: Bool) {
        didGrantScreenGuidancePermission = granted
        route = .session
    }

    /// Also used as "end session"'s destination — SessionContainerView calls
    /// this once the engine has torn down, since there's no dedicated
    /// "session ended" screen in the mockups.
    func restartOnboarding() {
        route = .welcome
    }
}
