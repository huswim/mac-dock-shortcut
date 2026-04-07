import AppKit
import ApplicationServices

enum DisplayMover {
    static func move(next: Bool) {
        guard AXIsProcessTrusted() else {
            let opts = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
            AXIsProcessTrustedWithOptions(opts)
            return
        }

        guard let app = NSWorkspace.shared.frontmostApplication else { return }
        let axApp = AXUIElementCreateApplication(app.processIdentifier)

        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(axApp, kAXFocusedWindowAttribute as CFString, &ref) == .success,
              let axWindow = ref as! AXUIElement? else { return }

        var posRef: CFTypeRef?, sizeRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(axWindow, kAXPositionAttribute as CFString, &posRef) == .success,
              AXUIElementCopyAttributeValue(axWindow, kAXSizeAttribute as CFString, &sizeRef) == .success,
              let posVal = posRef, let sizeVal = sizeRef else { return }

        var pos = CGPoint.zero
        var size = CGSize.zero
        AXValueGetValue(posVal as! AXValue, .cgPoint, &pos)
        AXValueGetValue(sizeVal as! AXValue, .cgSize, &size)

        let screens = NSScreen.screens
        guard screens.count > 1 else { return }

        // AX positions use CG coordinates: origin at top-left of main screen, Y increases downward.
        // NSScreen.frame uses AppKit coordinates: origin at bottom-left of main screen, Y increases upward.
        // Conversion: cgFrame.minY = mainScreenHeight - appkitFrame.maxY
        let mainH = screens[0].frame.height
        func cgFrame(_ s: NSScreen) -> CGRect {
            let f = s.frame
            return CGRect(x: f.minX, y: mainH - f.maxY, width: f.width, height: f.height)
        }

        let winRect = CGRect(origin: pos, size: size)
        let curIdx = screens.indices.first { cgFrame(screens[$0]).intersects(winRect) } ?? 0
        let tgtIdx = next
            ? (curIdx + 1) % screens.count
            : (curIdx - 1 + screens.count) % screens.count

        let src = cgFrame(screens[curIdx])
        let dst = cgFrame(screens[tgtIdx])

        // Preserve the window's pixel offset from its current screen's origin.
        var newPos = CGPoint(
            x: dst.minX + (pos.x - src.minX),
            y: dst.minY + (pos.y - src.minY)
        )
        // Clamp so the window remains fully on the target screen.
        newPos.x = max(dst.minX, min(newPos.x, dst.maxX - size.width))
        newPos.y = max(dst.minY, min(newPos.y, dst.maxY - size.height))

        if let v = AXValueCreate(.cgPoint, &newPos) {
            AXUIElementSetAttributeValue(axWindow, kAXPositionAttribute as CFString, v)
        }
    }
}
