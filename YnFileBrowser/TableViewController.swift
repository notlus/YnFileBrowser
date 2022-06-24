import Cocoa
import YnFileBrowserShared

class TableViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!
    private var viewModel: AppViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let splitViewController = parent as? SplitViewController else {
            fatalError("Failed to get parent split view")
        }

        viewModel = splitViewController.viewModel
    }
    
    override func viewWillAppear() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.absoluteString
        viewModel.fileBrowser.getFileMetadata(path: homeDirectory) {
            self.viewModel.root = $0
        }
    }
}

extension TableViewController: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        guard let root = viewModel.root else { return 0 }
        return root.children.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = tableView.makeView(
            withIdentifier: tableColumn!.identifier,
            owner: self) as? NSTableCellView else { return nil }

        guard let root = viewModel.root else { return nil }
        
        cellView.textField?.stringValue = root.children[row].url.lastPathComponent
        cellView.imageView?.image = root.children[row].icon

        return cellView
    }
}

extension TableViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_: Notification) {
        guard tableView.selectedRow != -1 else { return }
        guard let root = viewModel.root else { return }

        guard let splitViewController = parent as? SplitViewController else { return }
        let fileNode = root.children[tableView.selectedRow]

        if fileNode.isDirectory, fileNode.children.isEmpty {
            // Fetch children
            viewModel.fileBrowser.getFileMetadata(path: fileNode.url.path, completion: { childNode in
                fileNode.children = childNode!.children

                splitViewController.handleSelectionChange(for: fileNode, from: self)
            })
        }
        else {
            splitViewController.handleSelectionChange(for: fileNode, from: self)
        }
    }
}
