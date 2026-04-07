import Carbon
import Foundation

enum ModifierOption {
    case controlOption
    case controlOnly

    var flags: UInt32 {
        switch self {
        case .controlOption: return UInt32(controlKey | optionKey)
        case .controlOnly:   return UInt32(controlKey)
        }
    }

    var symbols: String {
        switch self {
        case .controlOption: return "⌃⌥"
        case .controlOnly:   return "⌃"
        }
    }
}

class HotkeyManager {
    private var hotkeyRefs: [EventHotKeyRef?] = []
    private var eventHandlerRef: EventHandlerRef?
    var onHotkey: ((Int) -> Void)?

    // Virtual keycodes for number keys 1-9, 0 (not sequential!)
    private static let keycodes: [UInt32] = [
        18, // 1 - kVK_ANSI_1
        19, // 2 - kVK_ANSI_2
        20, // 3 - kVK_ANSI_3
        21, // 4 - kVK_ANSI_4
        23, // 5 - kVK_ANSI_5
        22, // 6 - kVK_ANSI_6
        26, // 7 - kVK_ANSI_7
        28, // 8 - kVK_ANSI_8
        25, // 9 - kVK_ANSI_9
        29, // 0 - kVK_ANSI_0
    ]

    private static let signature: FourCharCode = {
        let chars: [UInt8] = [0x44, 0x4B, 0x53, 0x48] // "DKSH"
        return FourCharCode(chars[0]) << 24 | FourCharCode(chars[1]) << 16 |
               FourCharCode(chars[2]) << 8 | FourCharCode(chars[3])
    }()

    func register(modifier: ModifierOption = .controlOption) {
        let modifiers = modifier.flags
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let callback: EventHandlerUPP = { _, event, userData -> OSStatus in
            guard let event = event, let userData = userData else {
                return OSStatus(eventNotHandledErr)
            }

            var hotkeyID = EventHotKeyID()
            let status = GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotkeyID
            )

            guard status == noErr else { return status }

            let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            let index = Int(hotkeyID.id)

            DispatchQueue.main.async {
                manager.onHotkey?(index)
            }

            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            selfPtr,
            &eventHandlerRef
        )

        for (index, keycode) in Self.keycodes.enumerated() {
            let hotkeyID = EventHotKeyID(signature: Self.signature, id: UInt32(index))
            var hotkeyRef: EventHotKeyRef?

            RegisterEventHotKey(keycode, modifiers, hotkeyID, GetApplicationEventTarget(), 0, &hotkeyRef)
            hotkeyRefs.append(hotkeyRef)
        }
    }

    func unregister() {
        for ref in hotkeyRefs {
            if let ref = ref {
                UnregisterEventHotKey(ref)
            }
        }
        hotkeyRefs.removeAll()

        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
            eventHandlerRef = nil
        }
    }

    deinit {
        unregister()
    }
}
