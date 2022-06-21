import Foundation
import YnFileBrowserShared

class FileBrowserService: NSObject, FileBrowsing {
    func getChildren(of fileNode: YnFileBrowserShared.FileNode, reply: @escaping ([FileNode]) -> Void) {
        guard fileNode.isDirectory else {
            NSLog("\(fileNode.url.absoluteString) is not a directory")
            reply([])
            return
        }

        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: fileNode.url as URL,
            includingPropertiesForKeys: nil) else {
            // Get immediate children
            NSLog("Failed to open URL:", fileNode.url as NSURL)
            reply([])
            return
        }

        let children = contents.map { FileNode(url: $0 as NSURL, children: []) }
        reply(children)
    }

    func getFileMetadata(withURL url: NSURL, reply: @escaping (FileNode?) -> Void) {
        let fileNode = FileNode(url: url, children: [])

        print(fileNode.description)
        reply(fileNode)
    }

    func openFileForReading(withURL url: NSURL, reply: @escaping (FileHandle?) -> Void) {
        // TODO: Is this check needed? What happens when you open a directory?
        if url.isFileURL {
            guard let handle = try? FileHandle(forReadingFrom: url as URL) else {
                reply(nil)
                return
            }

            reply(handle)
        }
        else {
            print("other URL:", url)
            reply(nil)
        }
    }
}

extension FileBrowserService: NSXPCListenerDelegate {
    func listener(_: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedObject = self
        newConnection.exportedInterface = NSXPCInterface(with: FileBrowsing.self)
        newConnection.resume()

        return true
    }
}
