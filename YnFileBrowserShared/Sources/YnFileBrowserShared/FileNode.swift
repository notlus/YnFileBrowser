//
//  FileNode.swift
//  YnFileBrowser
//
//  Created by Jeffrey Sulton on 6/18/22.
//

import Foundation

/// A type that represents a file or folder
public final class FileNode: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true

    public let url: URL
    public var children: [FileNode]

    public init(url: NSURL, children: [FileNode] = []) {
        self.url = url as URL
        self.children = children
    }

    public required init?(coder aDecoder: NSCoder) {
        guard let url = aDecoder.decodeObject(of: NSURL.self, forKey: "url"),
              let children = aDecoder.decodeObject(of: [NSArray.self, FileNode.self], forKey: "children") as? [FileNode]
        else {
            return nil
        }
        self.url = url as URL
        self.children = children
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(children, forKey: "children")
    }
}

public extension FileNode {
    override var description: String {
        "URL: \(url)\nDirectory: \(isDirectory)\nHidden: \(isHidden)\nSize: \(fileSize)\nChildren: \(children.count)"
    }
}

public extension FileNode {
    // TODO: Implement
    var kind: Bool {
        false
    }

    // TODO: Determine how bundles/packages should be treated.
    var isDirectory: Bool {
        guard let directory = try? url.resourceValues(forKeys: [.isDirectoryKey]),
              let isDirectory = directory.isDirectory else {
            return false
        }

        return isDirectory
    }

    var isHidden: Bool {
        guard let hiddenResource = try? url.resourceValues(forKeys: [.isHiddenKey]),
              let isHidden = hiddenResource.isHidden else {
            return false
        }

        return isHidden
    }

    var fileSize: String {
        var fileSize = "-"
        if let sizeResource = try? url.resourceValues(forKeys: [.totalFileAllocatedSizeKey]) {
            if let allocatedSize = sizeResource.totalFileAllocatedSize {
                let formattedNumberStr = ByteCountFormatter.string(fromByteCount: Int64(allocatedSize), countStyle: .file)
                let fileSizeTitle = NSLocalizedString("on disk", comment: "")
                fileSize = "\(fileSizeTitle) \(formattedNumberStr)"
            }
        }

        return fileSize
    }

    var creationDate: Date? {
        var creationDate: Date?
        if let fileCreationDateResource = try? url.resourceValues(forKeys: [.creationDateKey]) {
            creationDate = fileCreationDateResource.creationDate
        }

        return creationDate
    }

    var modificationDate: Date? {
        var modificationDate: Date?
        if let modDateResource = try? url.resourceValues(forKeys: [.contentModificationDateKey]) {
            modificationDate = modDateResource.contentModificationDate
        }

        return modificationDate
    }
}
