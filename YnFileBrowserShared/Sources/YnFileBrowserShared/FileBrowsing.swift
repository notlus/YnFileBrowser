import Foundation

/// A protocol for file browsing operations.
///
/// This protocol is implemented by the ``FileBrowserService`` XPC service. Clients use the protocol
/// to perform file browsing operations using the XPC service.
@objc public protocol FileBrowsing {
    ///  Get the metadata for the specified URL
    /// - Parameters:
    ///   - url: The file URL
    ///   - reply: Either a ``FileNode`` or `nil`
    func getFileMetadata(withURL url: URL, reply: @escaping (FileNode?) -> Void)

    /// Get the contents of a file as data
    /// - Parameters:
    ///   - fileNode: A `FileNode` representing a file
    ///   - reply: On success the reply callback will contain the file data or `nil`
    func getContents(of fileNode: FileNode, reply: @escaping (NSData?) -> Void)

    /// Get a `FileHandle` to the specified URL
    /// - Parameters:
    ///   - url: The file URL
    ///   - reply: Either a ``FileHandle`` for the requested URL, or `nil`
    func getFileHandle(for fileNode: FileNode, reply: @escaping (FileHandle?) -> Void)
}
