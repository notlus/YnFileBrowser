import Cocoa
import Foundation

public final class FileNode: NSObject, NSSecureCoding {
    public static var supportsSecureCoding = true

    public var url: URL
    public var children: [FileNode] = []
    public var isDirectory: Bool = false
    public var isHidden: Bool = false
    public var isImage: Bool = false
    public var fileSize: String = ""
    public var creationDate: Date?
    public var modificationDate: Date?
    public var icon: NSImage?
    public var fileType: String = ""

    public init(url: URL) {
        self.url = url

        super.init()
        initializeFromURL(url)
    }

    public required init?(coder aDecoder: NSCoder) {
        guard let url = aDecoder.decodeObject(of: NSURL.self, forKey: "url"),
              let children = aDecoder.decodeObject(of: [NSArray.self, FileNode.self], forKey: "children") as? [FileNode],
              let isDirectory = aDecoder.decodeObject(of: NSNumber.self, forKey: "isDirectory") as? Bool,
              let isHidden = aDecoder.decodeObject(of: NSNumber.self, forKey: "isHidden") as? Bool,
              let isImage = aDecoder.decodeObject(of: NSNumber.self, forKey: "isImage") as? Bool,
              let fileSize = aDecoder.decodeObject(of: NSString.self, forKey: "fileSize") as? String,
              let creationDate = aDecoder.decodeObject(of: NSDate.self, forKey: "creationDate") as? Date,
              let modificationDate = aDecoder.decodeObject(of: NSDate.self, forKey: "modificationDate") as? Date,
              let icon = aDecoder.decodeObject(of: NSImage.self, forKey: "icon"),
              let fileType = aDecoder.decodeObject(of: NSString.self, forKey: "fileType") as? String
        else {
            return nil
        }

        self.url = url as URL
        self.children = children
        self.isDirectory = isDirectory
        self.isHidden = isHidden
        self.isImage = isImage
        self.fileSize = fileSize
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.icon = icon
        self.fileType = fileType
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(children, forKey: "children")
        aCoder.encode(isDirectory, forKey: "isDirectory")
        aCoder.encode(isHidden, forKey: "isHidden")
        aCoder.encode(isImage, forKey: "isImage")
        aCoder.encode(fileSize, forKey: "fileSize")
        aCoder.encode(creationDate, forKey: "creationDate")
        aCoder.encode(modificationDate, forKey: "modificationDate")
        aCoder.encode(icon, forKey: "icon")
        aCoder.encode(fileType, forKey: "fileType")
    }
}

extension FileNode {
    func initializeFromURL(_ url: URL) {
        // File type
        if let resource = try? url.resourceValues(forKeys: [.typeIdentifierKey]) {
            fileType = resource.typeIdentifier ?? ""
        }

        // Directory
        // TODO: Determine how bundles/packages should be treated.
        if let directory = try? url.resourceValues(forKeys: [.isDirectoryKey]),
           let isDirectory = directory.isDirectory {
            self.isDirectory = isDirectory
        }
        else {
            isDirectory = false
        }

        // Hidden
        if let hiddenResource = try? url.resourceValues(forKeys: [.isHiddenKey]),
           let isHidden = hiddenResource.isHidden {
            self.isHidden = isHidden
        }
        else {
            isHidden = false
        }

        // Image
        isImage = false
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

        // File size
        fileSize = "-"
        if let sizeResource = try? url.resourceValues(forKeys: [.totalFileAllocatedSizeKey]) {
            if let allocatedSize = sizeResource.totalFileAllocatedSize {
                let formattedNumberStr = ByteCountFormatter.string(fromByteCount: Int64(allocatedSize), countStyle: .file)
                let fileSizeTitle = NSLocalizedString("on disk", comment: "")
                fileSize = "\(fileSizeTitle) \(formattedNumberStr)"
            }
        }

        // Creation date
        if let fileCreationDateResource = try? url.resourceValues(forKeys: [.creationDateKey]) {
            creationDate = fileCreationDateResource.creationDate
        }

        // Modified date
        if let modDateResource = try? url.resourceValues(forKeys: [.contentModificationDateKey]) {
            modificationDate = modDateResource.contentModificationDate
        }

        // Icon
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
    }
}

public extension FileNode {
    override var description: String {
        "URL: \(url)\nDirectory: \(isDirectory)\nHidden: \(isHidden)\nSize: \(fileSize)\nChildren: \(children.count)"
    }
}
