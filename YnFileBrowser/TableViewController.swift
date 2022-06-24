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
}

extension TableViewController: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return viewModel.root.children.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = tableView.makeView(
            withIdentifier: tableColumn!.identifier,
            owner: self) as? NSTableCellView else { return nil }

        cellView.textField?.stringValue = viewModel.root.children[row].url.lastPathComponent
        cellView.imageView?.image = viewModel.root.children[row].icon

        return cellView
    }
}

extension TableViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_: Notification) {
        guard tableView.selectedRow != -1 else { return }

        guard let splitViewController = parent as? SplitViewController else { return }
        let fileNode = viewModel.root.children[tableView.selectedRow]

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
