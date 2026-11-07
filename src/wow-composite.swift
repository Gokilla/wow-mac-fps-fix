// wow-composite — keeps World of Warcraft on the "Composited" presentation path on macOS.
//
// While any World of Warcraft client is running, this agent shows a 2×2 px, ~invisible,
// click-through window above everything. Because another window overlaps the game,
// WindowServer cannot use "Direct" presentation and composites the game instead,
// which avoids the 120 → 60 → 40 FPS step-downs seen with Direct presentation.
// When WoW exits, the window is removed. Idle cost: one process-list check every 2 s.

import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

var overlays: [NSWindow] = []

func wowIsRunning() -> Bool {
    NSWorkspace.shared.runningApplications.contains { running in
        let path = running.executableURL?.path ?? ""
        return path.contains("/World of Warcraft") && path.contains(".app/Contents/MacOS/")
    }
}

func showOverlays() {
    guard overlays.isEmpty else { return }
    for screen in NSScreen.screens {
        let frame = screen.frame
        let window = NSWindow(
            contentRect: NSRect(x: frame.minX, y: frame.minY, width: 2, height: 2),
            styleMask: .borderless, backing: .buffered, defer: false)
        window.level = .screenSaver
        window.isOpaque = false
        window.backgroundColor = NSColor.black.withAlphaComponent(0.02)
        window.ignoresMouseEvents = true
        window.hasShadow = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        window.orderFrontRegardless()
        overlays.append(window)
    }
}

func hideOverlays() {
    overlays.forEach { $0.orderOut(nil) }
    overlays.removeAll()
}

Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
    wowIsRunning() ? showOverlays() : hideOverlays()
}
NotificationCenter.default.addObserver(
    forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
) { _ in
    // Displays changed (plugged / resolution): rebuild overlays on the new screen layout.
    if !overlays.isEmpty { hideOverlays(); showOverlays() }
}
if wowIsRunning() { showOverlays() }
app.run()
