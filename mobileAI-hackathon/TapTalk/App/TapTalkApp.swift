//
//  TapTalkApp.swift
//  TapTalk
//

import SwiftUI

@main
struct TapTalkApp: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
        }
    }
}
