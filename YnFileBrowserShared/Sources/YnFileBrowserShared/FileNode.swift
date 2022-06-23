import Cocoa
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

    public func getFileContents() -> NSImage? {
        let image = NSImage(contentsOf: url)
        return image
    }

    public func getIcon() -> NSImage? {
        icon
    }
}

public extension FileNode {
    override var description: String {
        "URL: \(url)\nDirectory: \(isDirectory)\nHidden: \(isHidden)\nSize: \(fileSize)\nChildren: \(children.count)"
    }
}

public extension FileNode {
    var fileType: String {
        var fileType = ""
        if url.isFileURL {
            print("file URL")
        }

        print(url.standardizedFileURL)
        if let resource = try? url.resourceValues(forKeys: [.typeIdentifierKey]) {
            fileType = resource.typeIdentifier!
        }
        return fileType
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

    var isImage: Bool {
        var isImage = false
        if let resource = try? url.resourceValues(forKeys: [.typeIdentifierKey]),
           let typeIdentifier = resource.typeIdentifier {
            if let imageTypes = CGImageSourceCopyTypeIdentifiers() as? [String] {
                for imageType in imageTypes {
                    if UTTypeConformsTo(typeIdentifier as CFString, imageType as CFString) {
                        isImage = true
                        break
                    }
                }
            }
        }
        
        return isImage
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

    var icon: NSImage {
        var icon: NSImage!
        if let iconValues = try? url.resourceValues(forKeys: [.customIconKey, .effectiveIconKey]) {
            if let customIcon = iconValues.customIcon {
                icon = customIcon
            }
            else if let effectiveIcon = iconValues.effectiveIcon as? NSImage {
                icon = effectiveIcon
            }
        }
        else {
            let osType = isDirectory ? kGenericFolderIcon : kGenericDocumentIcon
            let iconType = NSFileTypeForHFSTypeCode(OSType(osType))
            icon = NSWorkspace.shared.icon(forFileType: iconType!)
        }
        
        return icon
    }
}
