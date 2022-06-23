import Cocoa
import Security

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        do {
            let authHelper = try AuthorizationHelper()
            if !authHelper.isHelperInstalled() {
                NSLog("Installing helper tool")
                try authHelper.installHelper()
                NSLog("Helper tool installed successfully")
            }
            else {
                NSLog("Helper tool already installed")
            }
        }
        catch {
            NSLog("Failed to install helper tool: \(error)")
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        return true
    }
}
