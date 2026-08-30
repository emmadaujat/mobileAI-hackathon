//
//  SampleHandler.swift
//  TapTalkBroadcastExtension
//
//  PHASE 2 — see the header comment in
//  TapTalk/Services/ScreenGuidance/ReplayKitVisionGuidanceService.swift for
//  the full picture of what this extension is for and what's still required
//  to make it work end to end. Not wired into the v1 app, not testable in
//  the Simulator, and not exercised anywhere in this sandbox build.
//
//  This is the principal class of the Broadcast Upload Extension target
//  (see TapTalkBroadcastExtension/Info.plist's NSExtensionPrincipalClass).
//  iOS instantiates it only once the user starts a system-wide screen
//  broadcast for TapTalk via the system broadcast picker
//  (RPSystemBroadcastPickerView, presented from the main app). It then
//  receives every captured frame while the broadcast is active.
//
//  It runs in its own process, sandboxed separately from the main app, so
//  it can only talk back to TapTalk via the shared App Group container +
//  Darwin notifications (see SharedScreenBridge, which is compiled into
//  this target too — add it to this target's "Compile Sources" if you're
//  wiring the project up by hand instead of via XcodeGen).
//
import ReplayKit
import CoreMedia
import CoreImage

class SampleHandler: RPBroadcastSampleHandler {
    private let ciContext = CIContext()
    /// Throttle: PTV's UI doesn't need 30-60fps analysis — a frame every
    /// ~500ms is plenty for "did the user reach a new screen" and keeps
    /// battery/CPU use in the extension's tight memory budget reasonable.
    private var lastWriteTime: CFAbsoluteTime = 0
    private let minimumWriteInterval: CFTimeInterval = 0.5

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        // Nothing to set up — SharedScreenBridge resolves its container URL lazily.
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video else { return }

        let now = CFAbsoluteTimeGetCurrent()
        guard now - lastWriteTime >= minimumWriteInterval else { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let url = SharedScreenBridge.latestFrameURL else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let colorSpace = ciImage.colorSpace,
              let jpegData = ciContext.jpegRepresentation(of: ciImage, colorSpace: colorSpace) else { return }

        do {
            try jpegData.write(to: url, options: .atomic)
            SharedScreenBridge.notifyNewFrameAvailable()
            lastWriteTime = now
        } catch {
            // Best-effort — dropping an occasional frame is fine.
        }
    }

    override func broadcastFinished() {
        // Nothing to tear down.
    }
}
