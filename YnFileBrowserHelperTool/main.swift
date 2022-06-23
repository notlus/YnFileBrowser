import Foundation

let fileBrowserService = FileBrowserService()

let listener = NSXPCListener(machServiceName: "com.notlus.YnFileBrowser.Helper")
listener.delegate = fileBrowserService
listener.resume()

RunLoop.main.run()
