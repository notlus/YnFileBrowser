import Cocoa

class TableViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!

    private var viewModel: AppViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

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
        splitViewController.handleSelectionChange(for: viewModel.root.children[tableView.selectedRow])
    }
}
