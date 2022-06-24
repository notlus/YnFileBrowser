import Foundation
import YnFileBrowserShared

class FileBrowserService: NSObject, FileBrowsing {
    func getChildren(of fileNode: YnFileBrowserShared.FileNode, reply: @escaping ([FileNode]) -> Void) {
        reply(getChildren(for: fileNode))
    }

    func getFileMetadata(withURL url: URL, reply: @escaping (FileNode?) -> Void) {
        let fileNode = FileNode(url: url)
        let children = getChildren(for: fileNode)
        fileNode.children = children

        print("Server:", fileNode.description)
        reply(fileNode)
    }

    func openFileForReading(withURL url: NSURL, reply: @escaping (FileHandle?) -> Void) {
        // TODO: Is this check needed? What happens when you open a directory?
        guard url.isFileURL, // {
              let handle = try? FileHandle(forReadingFrom: url as URL) else {
            reply(nil)
            return
        }
        reply(handle)
    }

    func getChildren(for fileNode: FileNode) -> [FileNode] {
        guard fileNode.isDirectory else {
            NSLog("\(fileNode.url.absoluteString) is not a directory")
            return []
        }

        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: fileNode.url as URL,
            includingPropertiesForKeys: nil) else {
            // Get immediate children
            NSLog("Failed to open URL: \(fileNode.url)")
            return []
        }

        let children = contents.map { FileNode(url: $0) }
        return children
    }
    
    func getContents(of fileNode: FileNode, reply: @escaping (NSData?) -> Void) {
        let fileData = NSData(contentsOf: fileNode.url)
        reply(fileData)
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
