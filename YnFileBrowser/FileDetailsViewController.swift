import Cocoa
import YnFileBrowserShared

class FileDetailsViewController: NSViewController {
    @IBOutlet private var fileIcon: NSImageView!
    @IBOutlet private var fileName: NSTextField!
    @IBOutlet private var fileSize: NSTextField!
    @IBOutlet private var creationDate: NSTextField!
    @IBOutlet private var modifiedDate: NSTextField!
    @IBOutlet private var fileKind: NSTextField!

    var fileNode: FileNode? {
        didSet {
            guard let fileNode = fileNode else { return }

            fileIcon.image = fileNode.icon
            fileName.stringValue = fileNode.url.lastPathComponent
            fileSize.stringValue = fileNode.fileSize
            creationDate.stringValue = fileNode.creationDate?.description ?? "-"
            modifiedDate.stringValue = fileNode.modificationDate?.description ?? "-"
            fileKind.stringValue = fileNode.fileType
        }
    }
}
