//
//  FileBrowsing.swift
//
//  Created by Jeffrey Sulton on 6/18/22.
//

import Foundation

/// A protocol for file browsing operations.
///
/// This protocol is implemented by the ``FileBrowserService`` XPC service. Clients use the protocol
/// to perform file browsing operations using the XPC service.
@objc public protocol FileBrowsing {
    /// Get a `FileHandle` to the specified URL
    /// - Parameters:
    ///   - url: The file URL
    ///   - reply: Either a ``FileHandle`` for the requested URL, or `nil`
    func openFileForReading(withURL url: NSURL, reply: @escaping (FileHandle?) -> Void)

    ///  Get the metadata for the specified URL
    /// - Parameters:
    ///   - url: The file URL
    ///   - reply: Either a ``FileNode`` or `nil`
    func getFileMetadata(withURL url: NSURL, reply: @escaping (FileNode?) -> Void)
    
    /// Get the immediate children of the specified ``FileNode``
    /// - Parameters:
    ///   - fileNode: A `FileNode` representing a directory
    ///   - reply: On success callback will have an array of `FileNode`s, otherwise an empty array
    func getChildren(of fileNode: FileNode, reply: @escaping ([FileNode]) -> Void)
}
