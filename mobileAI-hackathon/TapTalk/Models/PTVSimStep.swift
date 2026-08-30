//
//  PTVSimStep.swift
//  TapTalk
//
//  Steps of the simulated PTV walkthrough (v1 stand-in for the real PTV app —
//  see ScreenGuidance/SimulatedPTVGuidanceService.swift). Each step pairs a
//  visual screen with the caption TapTalk speaks/shows at that point, taken
//  directly from the user flow doc's step-by-step script.
//

import Foundation

enum PTVSimScreen: Equatable {
    case forYou
    case journeyPlanner
    case destinationSearch
    case results
}

enum PTVSimStep: Equatable, CaseIterable {
    case forYouOpened
    case tapFrom
    case typeOrigin
    case tapToAndTypeDestination
    case selectingDestination
    case readyToSearch
    case showingResults

    var screen: PTVSimScreen {
        switch self {
        case .forYouOpened: return .forYou
        case .tapFrom, .typeOrigin, .readyToSearch: return .journeyPlanner
        case .tapToAndTypeDestination, .selectingDestination: return .destinationSearch
        case .showingResults: return .results
        }
    }

    /// The caption TapTalk overlays/speaks at this step. `origin`/`destination`
    /// are interpolated in so the walkthrough matches whatever the user
    /// actually said, not just the Box Hill -> Melbourne Central example.
    func caption(origin: String, destination: String) -> String {
        switch self {
        case .forYouOpened:
            return "You're in PTV now — tap Journey Planner."
        case .tapFrom:
            return "Now tap From."
        case .typeOrigin:
            return "Type in \(origin)."
        case .tapToAndTypeDestination:
            return "Now tap To and type \(destination)."
        case .selectingDestination:
            return "Tap \(destination) to add it as your destination."
        case .readyToSearch:
            return "Both fields are filled — tap Search to see your options."
        case .showingResults:
            return "Here's your journey — first service leaves shortly from Platform 2. Anything else you need help with?"
        }
    }

    var next: PTVSimStep? {
        let all = PTVSimStep.allCases
        guard let index = all.firstIndex(of: self), index + 1 < all.count else { return nil }
        return all[index + 1]
    }
}
