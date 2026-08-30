
//  PHASE 2 — not used by the v1 simulated-PTV flow.
//
//  A Broadcast Upload Extension runs in a completely separate OS process
//  from the main TapTalk app, so the two can't just share an in-memory
//  object. This file is the IPC bridge between them: the extension
//  (TapTalkBroadcastExtension/SampleHandler.swift) writes each captured
//  frame into the shared App Group container, then fires a Darwin
//  notification; the main app (ReplayKitVisionGuidanceService) observes that
//  notification and reads the frame back out to run Vision OCR on it.
//
//  Requires the `group.com.taptalk.shared` App Group to exist under your own
//  Apple Developer account and to be added to BOTH targets' entitlements
//  (already scaffolded in TapTalk.entitlements /
//  TapTalkBroadcastExtension.entitlements — update the identifier there if
//  you use a different group name).
//

import Foundation

enum SharedScreenBridge {
    static let appGroupID = "group.com.taptalk.shared"
    private static let newFrameNotificationName = "com.taptalk.screenguidance.newframe" as CFString

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    /// Where the broadcast extension drops the most recent frame as a JPEG.
    /// A single overwritten file (rather than a queue) is intentional —
    /// TapTalk only ever needs to react to "what does the screen look like
    /// right now", not process every frame.
    static var latestFrameURL: URL? {
        containerURL?.appendingPathComponent("latest_frame.jpg")
    }

    /// Called by the broadcast extension after writing a new frame.
    static func notifyNewFrameAvailable() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(newFrameNotificationName),
            nil, nil, true
        )
    }

    /// Called by the main app to be told whenever a new frame lands.
    /// Returns a token — keep it alive for as long as you want to keep
    /// observing; deinit-ing it (or calling `stopObservingNewFrames`) removes
    /// the observer.
    static func observeNewFrames(_ handler: @escaping () -> Void) -> DarwinNotificationToken {
        DarwinNotificationToken(name: newFrameNotificationName, handler: handler)
    }
}

/// Thin, safe wrapper around CFNotificationCenter's C-callback-based Darwin
/// notification API (which has no native closure support) so call sites can
/// use an ordinary Swift closure.
final class DarwinNotificationToken {
    private let name: CFString
    private let handler: () -> Void

    fileprivate init(name: CFString, handler: @escaping () -> Void) {
        self.name = name
        self.handler = handler

        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observerPointer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterAddObserver(center, observerPointer, { _, observer, _, _, _ in
            guard let observer else { return }
            let token = Unmanaged<DarwinNotificationToken>.fromOpaque(observer).takeUnretainedValue()
            token.handler()
        }, name, nil, .deliverImmediately)
    }

    deinit {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observerPointer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterRemoveObserver(center, observerPointer, CFNotificationName(name), nil)
    }
}
