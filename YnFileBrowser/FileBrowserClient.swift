import Foundation
import YnFileBrowserShared

class FileBrowserClient {
    var root: FileNode?

    var connection: NSXPCConnection {
        let connection = NSXPCConnection(
            machServiceName: "com.notlus.YnFileBrowser.Helper",
            options: .privileged)
        let interface = NSXPCInterface(with: FileBrowsing.self)

        let fileBrowserTypes = NSSet(array: [
            NSURL.self, NSArray.self, NSMutableArray.self, NSData.self, FileNode.self, NSString.self
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

        connection.remoteObjectInterface = interface
        connection.resume()
        return connection
    }

    func getFileMetadata(path: String, completion: @escaping (FileNode?) -> Void) {
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            NSLog("Error: \(error.localizedDescription)")
            self.root = FileNode(url: URL(string: "/dev/null")!)
        } as? FileBrowsing

        let url = URL(fileURLWithPath: path)
        service?.getFileMetadata(withURL: url, reply: { fileNode in
            guard let fileNode = fileNode else {
                NSLog("Failed to get file node")
                return
            }

            DispatchQueue.main.async {
                completion(fileNode)
            }
        })
    }

    func getContents(of fileNode: FileNode, completion: @escaping (Data?) -> Void) {
        guard let service = connection.remoteObjectProxyWithErrorHandler({ error in
            NSLog("Error: \(error.localizedDescription)")
        }) as? FileBrowsing else {
            completion(nil)
            return
        }

        service.getContents(of: fileNode, reply: { data in
            DispatchQueue.main.async {
                completion(data as? Data)
            }
        })
    }
}
