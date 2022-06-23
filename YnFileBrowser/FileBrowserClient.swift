import Foundation
import YnFileBrowserShared

class FileBrowserClient {
    var root: FileNode?

    var connection: NSXPCConnection {
        let connection = NSXPCConnection(machServiceName: "com.notlus.YnFileBrowser.Helper", options: .privileged)
        let interface = NSXPCInterface(with: FileBrowsing.self)

        let fileBrowserTypes = NSSet(array: [NSURL.self, NSArray.self, NSMutableArray.self, FileNode.self, NSString.self]) as Set
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
            for: #selector(FileBrowsing.getChildren(of:reply:)),
            argumentIndex: 0,
            ofReply: true)

        connection.remoteObjectInterface = interface
        connection.resume()
        return connection
    }

    func getFileMetadata(path: String, completion: @escaping (FileNode?) -> Void) {
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            NSLog("Error: \(error.localizedDescription)")
            self.root = FileNode(url: NSURL(string: "/dev/null")!)
        } as? FileBrowsing

        let url = URL(string: path)!
        service?.getFileMetadata(withURL: url as NSURL, reply: { fileNode in
            guard let fileNode = fileNode else {
                print("Failed to get file node")
                return
            }

            DispatchQueue.main.async {
                completion(fileNode)
            }
        })
    }

    func getFile(path: String) {
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            NSLog("Error: \(error.localizedDescription)")
        } as? FileBrowsing

        let url = URL(fileURLWithPath: path)

        service?.openFileForReading(withURL: url as NSURL, reply: { fileHandle in
            if let fileHandle = fileHandle {
                print("got handle")
                if #available(macOS 10.15.4, *) {
                    let data = try? fileHandle.readToEnd()
                    if let data = data {
                        print("got file data:", data.count)
                    }
                }
                else {
                    // TODO:
                    // Fallback on earlier versions
                }
            }
            else {
                print("Failed to receive file handle")
            }
        })
    }
}
