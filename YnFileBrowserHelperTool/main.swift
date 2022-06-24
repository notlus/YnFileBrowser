import Foundation

if getppid() != 1 {
    NSLog("Yn File Browser helper can only be started by launchd")
    exit(0)
}

NSLog("Starting Yn File Browser helper tool: PID \(getpid())")

let fileBrowserService = FileBrowserService()

let listener = NSXPCListener(machServiceName: "com.notlus.YnFileBrowser.Helper")
listener.delegate = fileBrowserService
listener.resume()

RunLoop.main.run()
