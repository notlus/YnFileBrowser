import Cocoa
import YnFileBrowserShared

class DetailViewContainer: NSView {
    override var acceptsFirstResponder: Bool { return true }
}

class SplitViewController: NSSplitViewController {
    var viewModel: AppViewModel!
    var imageViewController: ImageViewController!
    var fileMetadataViewController: FileDetailsViewController!
    var fileCollectionViewController: FileCollectionViewController!

    var tableViewController: TableViewController {
        splitViewItems[0].viewController as! TableViewController
    }

    var detailViewController: NSViewController {
        splitViewItems[1].viewController
    }

    override func viewDidLoad() {
        viewModel = AppViewModel(splitViewController: self)
        super.viewDidLoad()

        imageViewController = storyboard!.instantiateController(
            withIdentifier: "ImageViewController") as? ImageViewController

        fileMetadataViewController = storyboard!.instantiateController(
            withIdentifier: "MetadataViewController") as? FileDetailsViewController

        fileCollectionViewController = storyboard!.instantiateController(
            withIdentifier: "FileCollectionViewController") as? FileCollectionViewController

        fileCollectionViewController.delegate = self
        fileCollectionViewController.viewModel = viewModel

        do {
            let authHelper = try AuthorizationHelper()
            if !authHelper.isHelperInstalled() {
                NSLog("Installing helper tool")
                try authHelper.installHelper()
                NSLog("Helper tool installed successfully")
            }
            else {
                NSLog("Helper tool already installed")
            }
        }
        catch {
            NSLog("Failed to install helper tool: \(error)")
        }
    }

    override func viewWillAppear() {
        let toolbar = NSToolbar(identifier: "toolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconOnly
        toolbar.allowsUserCustomization = false
        view.window?.toolbar = toolbar
    }

    func handleSelectionChange(for fileNode: FileNode, from source: NSViewController) {
        if fileNode.isImage {
            addChildToDetailViewController(imageViewController)
            viewModel.fileBrowser.getContents(of: fileNode, completion: { data in
                guard let data = data else {
                    NSLog("Failed to get file data")
                    return
                }

                self.imageViewController.imageView.image = NSImage(data: data)
            })
        }
        else if fileNode.isDirectory {
            // Show the child files and folders
            addChildToDetailViewController(fileCollectionViewController)
            fileCollectionViewController.fileNodes = fileNode.children
            if source is FileCollectionViewController {
                viewModel.root = fileNode
                tableViewController.tableView.reloadData()
            }
        }
        else {
            // Show file metadata
            addChildToDetailViewController(fileMetadataViewController)
            fileMetadataViewController.fileNode = fileNode
        }
    }

    private func addChildToDetailViewController(_ childViewController: NSViewController) {
        if !detailViewController.children.isEmpty {
            let currentDetailViewController = detailViewController
            if currentDetailViewController.children[0] == childViewController {
                return
            }

            // Remove existing child
            detailViewController.removeChild(at: 0)
            detailViewController.view.subviews[0].removeFromSuperview()
        }

        detailViewController.addChild(childViewController)
        detailViewController.view.addSubview(childViewController.view)

        NSLayoutConstraint.activate([
            childViewController.view.topAnchor.constraint(equalTo: detailViewController.view.topAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: detailViewController.view.bottomAnchor),
            childViewController.view.leadingAnchor.constraint(equalTo: detailViewController.view.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: detailViewController.view.trailingAnchor)
        ])
    }

    @objc func openFolder(_: AnyObject) {
        let dialog = NSOpenPanel()

        dialog.title = "Choose a starting folder| Yn File Browser"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url

            if let result = result {
                viewModel.fileBrowser.getFileMetadata(path: result.path) { fileNode in
                    self.viewModel.root = fileNode
                }
            }
        }
    }
}

private extension NSToolbarItem.Identifier {
    static let openFolder: NSToolbarItem.Identifier = NSToolbarItem.Identifier(rawValue: "openFolder")
}

extension SplitViewController: NSToolbarDelegate {
    func toolbar(_: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar _: Bool) -> NSToolbarItem? {
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)

        /// Create a new NSToolbarItem, and then go through the process of setting up its attributes.
        if itemIdentifier == NSToolbarItem.Identifier.openFolder {
            let image = NSImage(named: NSImage.folderName)!

            toolbarItem.action = #selector(openFolder)
            toolbarItem.label = "Open"
            toolbarItem.image = image
        }

        return toolbarItem
    }

    func toolbarDefaultItemIdentifiers(_: NSToolbar) -> [NSToolbarItem.Identifier] {
        var toolbarItemIdentifiers = [NSToolbarItem.Identifier]()
        toolbarItemIdentifiers.append(.openFolder)
        return toolbarItemIdentifiers
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
}
