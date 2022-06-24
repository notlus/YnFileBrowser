import Foundation
import YnFileBrowserShared

class FileBrowserClient {
    var root: FileNode?
    let connection: NSXPCConnection
    let fileBrowsing: FileBrowsing?

    init() {
        connection = NSXPCConnection(
            machServiceName: "com.notlus.YnFileBrowser.Helper",
            options: .privileged)
        let interface = NSXPCInterface(with: FileBrowsing.self)

        let fileBrowserTypes = NSSet(array: [
            NSURL.self, NSArray.self, NSMutableArray.self, NSData.self, FileHandle.self, FileNode.self, NSString.self
        ]) as Set

        interface.setClasses(
            fileBrowserTypes,
            for: #selector(FileBrowsing.getFileMetadata(withURL:reply:)),
            argumentIndex: 0,
            ofReply: false)

        interface.setClasses(
            fileBrowserTypes,
            for: #selector(FileBrowsing.getFileMetadata(withURL:reply:)),
            argumentIndex: 0,
            ofReply: true)

        interface.setClasses(
            fileBrowserTypes,
            for: #selector(FileBrowsing.getContents(of:reply:)),
            argumentIndex: 0,
            ofReply: false)

        interface.setClasses(
            fileBrowserTypes,
            for: #selector(FileBrowsing.getContents(of:reply:)),
            argumentIndex: 0,
            ofReply: true)

        interface.setClasses(
            fileBrowserTypes,
            for: #selector(FileBrowsing.getFileHandle(for:reply:)),
            argumentIndex: 0,
            ofReply: false)

        interface.setClasses(
            fileBrowserTypes,
            for: #selector(FileBrowsing.getFileHandle(for:reply:)),
            argumentIndex: 0,
            ofReply: true)

        connection.remoteObjectInterface = interface
        connection.resume()

        fileBrowsing = connection.remoteObjectProxyWithErrorHandler { error in
            NSLog("Error: \(error.localizedDescription)")
        } as? FileBrowsing
    }

    func getFileMetadata(path: String, completion: @escaping (FileNode?) -> Void) {
        let url = URL(fileURLWithPath: path)
        fileBrowsing?.getFileMetadata(withURL: url, reply: { fileNode in
            guard let fileNode = fileNode else {
                NSLog("Failed to get file node")
                return
            }

            DispatchQueue.main.async {
                completion(fileNode)
            }
        })
    }

    func getContentsOld(of fileNode: FileNode, completion: @escaping (Data?) -> Void) {
        fileBrowsing?.getContents(of: fileNode, reply: { data in
            DispatchQueue.main.async {
                completion(data as? Data)
            }
        })
    }

    func getContents(of fileNode: FileNode, completion: @escaping (Data?) -> Void) {
        fileBrowsing?.getFileHandle(for: fileNode, reply: { fileHandle in
            guard let fileHandle = fileHandle else {
                return
            }

            let data = fileHandle.readDataToEndOfFile()
            if #available(macOS 10.15, *) {
                try? fileHandle.close()
            }
            else {
                // Fallback on earlierdd versions
                fileHandle.closeFile()
            }

            DispatchQueue.main.async {
                completion(data)
            }
        })
    }
}
