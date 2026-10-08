import AppKit
import Carbon.HIToolbox

enum AppLaunchContext {
    static func shouldShowSettings(event: NSAppleEventDescriptor?, arguments: [String]) -> Bool {
        if arguments.contains("--background") {
            return false
        }
        guard let event, event.eventID == kAEOpenApplication else { return true }
        let launchReason = event.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue
        return launchReason != keyAELaunchedAsLogInItem && launchReason != keyAELaunchedAsServiceItem
    }
}
